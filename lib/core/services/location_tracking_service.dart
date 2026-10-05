import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/database/app_database.dart';
import '../../data/repositories/student_repository.dart';
import 'local_notification_service.dart';

final locationTrackingServiceProvider = Provider<LocationTrackingService>(
  (ref) => LocationTrackingService(),
);

enum LocationPollingTier {
  far(Duration(minutes: 15), LocationAccuracy.low),
  approach(Duration(minutes: 10), LocationAccuracy.medium),
  near(Duration(minutes: 2), LocationAccuracy.high),
  inside(Duration(minutes: 5), LocationAccuracy.high);

  const LocationPollingTier(this.interval, this.accuracy);

  final Duration interval;
  final LocationAccuracy accuracy;

  static LocationPollingTier forDistance({
    required double distanceMeters,
    required bool hasActiveSession,
    required int? geofenceRadiusMeters,
  }) {
    if (hasActiveSession) return inside;
    if (geofenceRadiusMeters != null &&
        distanceMeters <= geofenceRadiusMeters) {
      return inside;
    }
    if (distanceMeters <= 100) return near;
    if (distanceMeters <= 500) return approach;
    return far;
  }
}

class LocationTrackingService {
  LocationTrackingService({FlutterBackgroundService? service})
    : _service = service ?? FlutterBackgroundService();

  final FlutterBackgroundService _service;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<bool> isRunning() async {
    if (!isSupported) return false;
    return _service.isRunning();
  }

  Future<void> start() async {
    if (!isSupported) {
      throw UnsupportedError(
        'Background tuition location tracking is currently supported on Android.',
      );
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Location services are turned off on this device.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always) {
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
      throw StateError(
        'Allow location access all the time to track tuition in the background.',
      );
    }

    final notifications = LocalNotificationService();
    await notifications.initialize();
    final notificationPermissionGranted =
        await notifications.requestPermission();
    if (!notificationPermissionGranted) {
      throw StateError(
        'Allow notifications so arrival and completed-day alerts can be shown.',
      );
    }

    final configured = await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: locationServiceEntrypoint,
        autoStart: false,
        autoStartOnBoot: false,
        isForegroundMode: true,
        notificationChannelId: 'tuition_tracking',
        initialNotificationTitle: 'Tuition Tracker',
        initialNotificationContent: 'Monitoring saved tuition locations',
        foregroundServiceNotificationId: 6101,
        foregroundServiceTypes: const [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: locationServiceEntrypoint,
      ),
    );
    if (!configured) {
      throw StateError('The location service could not be configured.');
    }
    final started = await _service.startService();
    if (!started) {
      throw StateError('The background location service did not start.');
    }
  }

  Future<void> stop() async {
    if (isSupported) _service.invoke('stopTracking');
  }
}

@pragma('vm:entry-point')
void locationServiceEntrypoint(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final repository = StudentRepository(database);
  final notifications = LocalNotificationService();
  await notifications.initialize();
  final preferences = await SharedPreferences.getInstance();
  final languageCode = preferences.getString('language') ?? 'en';
  Timer? nextPoll;
  var isPolling = false;
  var nextInterval = LocationPollingTier.far.interval;
  var stopped = false;

  service.on('stopTracking').listen((event) async {
    stopped = true;
    nextPoll?.cancel();
    await database.close();
    await service.stopSelf();
  });

  Future<void> poll() async {
    if (isPolling || stopped) return;
    isPolling = true;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        service.invoke('trackingStatus', {'status': 'location_disabled'});
        nextInterval = const Duration(minutes: 15);
        return;
      }

      final students = await repository.getActiveStudentsWithLocations();
      if (students.isEmpty) {
        service.invoke('trackingStatus', {'status': 'no_locations'});
        nextInterval = const Duration(minutes: 15);
        return;
      }

      final activeSessions = await repository.getActiveSessions();
      final previousDistance = preferences.getDouble('last_location_distance');
      final activeStudentIds = activeSessions
          .map((session) => session.studentId)
          .toSet();
      final previousNearestId = preferences.getString(
        'last_nearest_student_id',
      );
      final previousNearest = students.where(
        (student) => student.id == previousNearestId,
      );
      final previousRadius = previousNearest.isEmpty
          ? null
          : previousNearest.first.geofenceRadiusMeters;
      final prePollTier = LocationPollingTier.forDistance(
        distanceMeters: previousDistance ?? 501,
        hasActiveSession: activeSessions.isNotEmpty,
        geofenceRadiusMeters: previousRadius,
      );
      final position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: prePollTier.accuracy,
          intervalDuration: prePollTier.interval,
          timeLimit: const Duration(seconds: 30),
        ),
      );

      final distances = <String, double>{};
      for (final student in students) {
        distances[student.id] = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          student.latitude!,
          student.longitude!,
        );
      }

      final nearest = students.reduce(
        (left, right) => distances[left.id]! <= distances[right.id]!
            ? left
            : right,
      );
      final nearestDistance = distances[nearest.id]!;
      await preferences.setDouble('last_location_distance', nearestDistance);
      await preferences.setString('last_nearest_student_id', nearest.id);
      final tier = LocationPollingTier.forDistance(
        distanceMeters: nearestDistance,
        hasActiveSession: activeSessions.isNotEmpty,
        geofenceRadiusMeters: nearest.geofenceRadiusMeters,
      );
      nextInterval = tier.interval;

      final processIds = <String>{
        ...activeStudentIds,
        if (nearestDistance <= nearest.geofenceRadiusMeters) nearest.id,
      };
      for (final student in students.where(
        (item) => processIds.contains(item.id),
      )) {
        final distance = distances[student.id]!;
        final result = await repository.processLocationFix(
          student: student,
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          distanceMeters: distance,
          recordedAt: position.timestamp,
        );

        final prompt = result.arrivalPrompt;
        if (prompt != null) {
          await notifications.showArrivalPrompt(
            prompt: prompt,
            studentName: student.name,
            languageCode: languageCode,
          );
        }
        if (result.thresholdReached) {
          await notifications.showTuitionDayCompleted(
            studentName: student.name,
            activeSeconds: result.activeSeconds,
            languageCode: languageCode,
          );
          final completedDays = await repository.completedDaysSinceLastPayment(
            student.id,
          );
          final targetDays = student.completedDaysTarget;
          if (targetDays > 0 && completedDays % targetDays == 0) {
            await notifications.showPaymentThreshold(
              studentName: student.name,
              completedDays: completedDays,
              targetDays: targetDays,
              paymentAmount: completedDays * student.paymentRate,
              languageCode: languageCode,
            );
          }
        }
        if (result.sessionEnded) {
          await notifications.showSessionEnded(
            studentName: student.name,
            completed: result.activeSeconds >=
                student.tuitionDayThresholdMinutes * 60,
            languageCode: languageCode,
          );
        }
      }

      service.invoke('trackingStatus', {
        'status': 'running',
        'tier': tier.name,
        'intervalSeconds': tier.interval.inSeconds,
      });
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('Location check timed out: $error\n$stackTrace');
      service.invoke('trackingError', {'reason': 'location_timeout'});
      nextInterval = const Duration(minutes: 2);
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Location check failed: $error\n$stackTrace');
      service.invoke('trackingError', {'reason': error.code});
      nextInterval = const Duration(minutes: 10);
    } on Exception catch (error, stackTrace) {
      debugPrint('Location polling failed: $error\n$stackTrace');
      service.invoke('trackingError', {'reason': 'poll_failed'});
      nextInterval = const Duration(minutes: 10);
    } finally {
      isPolling = false;
      if (!stopped) {
        nextPoll?.cancel();
        nextPoll = Timer(nextInterval, poll);
      }
    }
  }

  service.on('pollNow').listen((event) {
    nextPoll?.cancel();
    unawaited(poll());
  });

  await poll();
}
