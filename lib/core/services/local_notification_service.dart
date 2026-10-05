import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/local/database/app_database.dart';
import '../../data/repositories/student_repository.dart';

const _arrivalChannelId = 'tuition_arrivals';
const _trackingChannelId = 'tuition_tracking';

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          handleBackgroundNotificationResponse,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _arrivalChannelId,
        'Tuition arrivals',
        description: 'Arrival prompts and tuition-day alerts',
        importance: Importance.max,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _trackingChannelId,
        'Location tracking',
        description: 'Shows when tuition location monitoring is active',
        importance: Importance.low,
      ),
    );
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<void> showArrivalPrompt({
    required ArrivalPrompt prompt,
    required String studentName,
    required String languageCode,
  }) async {
    final bangla = languageCode == 'bn';
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _arrivalChannelId,
        'Tuition arrivals',
        channelDescription: 'Arrival prompts and tuition-day alerts',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        actions: [
          AndroidNotificationAction(
            'start_session',
            bangla ? 'সেশন শুরু' : 'Start session',
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            'skip_session',
            bangla ? 'এখন নয়' : 'Not now',
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: prompt.id.hashCode,
      title: bangla ? 'টিউশনের স্থানে পৌঁছেছেন' : 'Tuition location reached',
      body: bangla
          ? '$studentName-এর টিউশনে সেশন শুরু করবেন?'
          : 'Start a tuition session with $studentName?',
      notificationDetails: details,
      payload: jsonEncode({'type': 'arrival', 'promptId': prompt.id}),
    );
  }

  Future<void> showTuitionDayCompleted({
    required String studentName,
    required int activeSeconds,
    required String languageCode,
  }) async {
    final bangla = languageCode == 'bn';
    final duration = _formatDuration(activeSeconds, bangla);
    await _plugin.show(
      id: 4001 + studentName.hashCode.abs() % 500000,
      title: bangla ? 'টিউশন দিন সম্পন্ন' : 'Tuition day completed',
      body: bangla
          ? '$studentName-এর জন্য নির্ধারিত সময় পূর্ণ হয়েছে। সময়: $duration'
          : 'Required tuition time for $studentName is complete. Time: $duration',
      notificationDetails: _standardDetails(bangla),
    );
  }

  Future<void> showPaymentThreshold({
    required String studentName,
    required int completedDays,
    required int targetDays,
    required int paymentAmount,
    required String languageCode,
  }) async {
    final bangla = languageCode == 'bn';
    await _plugin.show(
      id: 500001 + studentName.hashCode.abs() % 500000,
      title: bangla ? 'পেমেন্ট সংগ্রহের সময়' : 'Payment may be due',
      body: bangla
          ? '$studentName-এর $completedDays দিন পূর্ণ হয়েছে। পেমেন্ট: ৳$paymentAmount'
          : '$studentName reached $completedDays of $targetDays days. Payment: ৳$paymentAmount',
      notificationDetails: _standardDetails(bangla),
    );
  }

  Future<void> showSessionEnded({
    required String studentName,
    required bool completed,
    required String languageCode,
  }) async {
    final bangla = languageCode == 'bn';
    await _plugin.show(
      id: 1000001 + studentName.hashCode.abs() % 500000,
      title: bangla ? 'টিউশন সেশন শেষ' : 'Tuition session ended',
      body: bangla
          ? (completed
                ? '$studentName-এর টিউশন দিন সম্পন্ন হয়েছে।'
                : '$studentName-এর সেশন নির্ধারিত সময়ের আগে শেষ হয়েছে।')
          : (completed
                ? 'Tuition day completed for $studentName.'
                : '$studentName left before the required tuition time.'),
      notificationDetails: _standardDetails(bangla),
    );
  }

  NotificationDetails _standardDetails(bool bangla) => NotificationDetails(
    android: AndroidNotificationDetails(
      _arrivalChannelId,
      bangla ? 'টিউশনের বিজ্ঞপ্তি' : 'Tuition alerts',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  String _formatDuration(int seconds, bool bangla) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (bangla) return '$hours ঘণ্টা $minutes মিনিট';
    return '$hours h $minutes min';
  }
}

@pragma('vm:entry-point')
void handleBackgroundNotificationResponse(NotificationResponse response) {
  _handleArrivalAction(response);
}

void handleNotificationResponse(NotificationResponse response) {
  _handleArrivalAction(response);
}

Future<void> _handleArrivalAction(NotificationResponse response) async {
  if (response.actionId != 'start_session' &&
      response.actionId != 'skip_session') {
    return;
  }
  final payload = response.payload;
  if (payload == null) return;

  final decoded = jsonDecode(payload);
  if (decoded is! Map<String, dynamic> || decoded['type'] != 'arrival') return;
  final promptId = decoded['promptId'];
  if (promptId is! String) return;

  final database = AppDatabase();
  try {
    final repository = StudentRepository(database);
    if (response.actionId == 'start_session') {
      await repository.acceptArrivalPrompt(promptId);
    } else {
      await repository.declineArrivalPrompt(promptId);
    }
  } finally {
    await database.close();
  }
}
