import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuition_time_tracker/core/services/location_tracking_service.dart';
import 'package:tuition_time_tracker/data/local/database/app_database.dart';
import 'package:tuition_time_tracker/data/repositories/student_repository.dart';

void main() {
  late AppDatabase database;
  late StudentRepository repository;
  late Student student;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = StudentRepository(database);
    await repository.addStudent(
      name: 'Amina Rahman',
      latitude: 23.78,
      longitude: 90.41,
      geofenceRadiusMeters: 50,
      sessionDurationMinutes: 60,
      tuitionDayThresholdMinutes: 60,
      paymentRate: 500,
      completedDaysTarget: 12,
    );
    student = (await repository.watchActiveStudents().first).single;
  });

  tearDown(() async {
    await database.close();
  });

  test('location tiers use the configured conservative polling intervals', () {
    expect(
      LocationPollingTier.forDistance(
        distanceMeters: 501,
        hasActiveSession: false,
        geofenceRadiusMeters: 50,
      ).interval,
      const Duration(minutes: 15),
    );
    expect(
      LocationPollingTier.forDistance(
        distanceMeters: 500,
        hasActiveSession: false,
        geofenceRadiusMeters: 50,
      ).interval,
      const Duration(minutes: 10),
    );
    expect(
      LocationPollingTier.forDistance(
        distanceMeters: 100,
        hasActiveSession: false,
        geofenceRadiusMeters: 50,
      ).interval,
      const Duration(minutes: 2),
    );
    expect(
      LocationPollingTier.forDistance(
        distanceMeters: 25,
        hasActiveSession: false,
        geofenceRadiusMeters: 50,
      ).interval,
      const Duration(minutes: 5),
    );
    expect(
      LocationPollingTier.forDistance(
        distanceMeters: 900,
        hasActiveSession: true,
        geofenceRadiusMeters: 50,
      ).interval,
      const Duration(minutes: 5),
    );
  });

  test(
    'a confirmed arrival can be accepted and completes at its time threshold',
    () async {
      final startedAt = DateTime.now().toUtc();
      final arrival = await repository.processLocationFix(
        student: student,
        latitude: 23.78,
        longitude: 90.41,
        accuracyMeters: 5,
        distanceMeters: 10,
        recordedAt: startedAt,
      );
      expect(arrival.arrivalPrompt, isNotNull);
      final sessionId = await repository.acceptArrivalPrompt(
        arrival.arrivalPrompt!.id,
      );

      PositionProcessingResult? finalResult;
      final sessionStart =
          (await (database.select(
                database.sessions,
              )..where((session) => session.id.equals(sessionId))).getSingle())
              .startedAt;
      for (var sample = 1; sample <= 12; sample++) {
        finalResult = await repository.processLocationFix(
          student: student,
          latitude: 23.78,
          longitude: 90.41,
          accuracyMeters: 5,
          distanceMeters: 10,
          recordedAt: sessionStart.add(Duration(minutes: sample * 5)),
        );
      }

      expect(finalResult!.thresholdReached, isTrue);
      final completedSession = await (database.select(
        database.sessions,
      )..where((session) => session.id.equals(sessionId))).getSingle();
      expect(completedSession.completed, isTrue);
      expect(completedSession.activeSeconds, 3600);
      expect(await repository.completedDaysSinceLastPayment(student.id), 1);
      expect(await database.select(database.locationLogs).get(), hasLength(13));
    },
  );

  test(
    'brief GPS drift is tolerated and a sustained exit closes the session',
    () async {
      final startedAt = DateTime.now().toUtc();
      final arrival = await repository.processLocationFix(
        student: student,
        latitude: 23.78,
        longitude: 90.41,
        accuracyMeters: 5,
        distanceMeters: 10,
        recordedAt: startedAt,
      );
      final sessionId = await repository.acceptArrivalPrompt(
        arrival.arrivalPrompt!.id,
      );
      final sessionStart =
          (await (database.select(
                database.sessions,
              )..where((session) => session.id.equals(sessionId))).getSingle())
              .startedAt;

      for (var sample = 1; sample <= 2; sample++) {
        await repository.processLocationFix(
          student: student,
          latitude: 23.78,
          longitude: 90.41,
          accuracyMeters: 5,
          distanceMeters: 10,
          recordedAt: sessionStart.add(Duration(minutes: sample * 5)),
        );
      }
      final lastInside = sessionStart.add(const Duration(minutes: 10));
      final firstOutside = lastInside.add(const Duration(minutes: 5));

      final drift = await repository.processLocationFix(
        student: student,
        latitude: 23.781,
        longitude: 90.41,
        accuracyMeters: 5,
        distanceMeters: 80,
        recordedAt: firstOutside,
      );
      expect(drift.sessionEnded, isFalse);

      final returnedInside = await repository.processLocationFix(
        student: student,
        latitude: 23.78,
        longitude: 90.41,
        accuracyMeters: 5,
        distanceMeters: 10,
        recordedAt: firstOutside.add(const Duration(minutes: 5)),
      );
      expect(returnedInside.sessionEnded, isFalse);

      final secondExit = firstOutside.add(const Duration(minutes: 10));
      final ended = await repository.processLocationFix(
        student: student,
        latitude: 23.781,
        longitude: 90.41,
        accuracyMeters: 5,
        distanceMeters: 80,
        recordedAt: secondExit,
      );
      expect(ended.sessionEnded, isFalse);
      final finished = await repository.processLocationFix(
        student: student,
        latitude: 23.781,
        longitude: 90.41,
        accuracyMeters: 5,
        distanceMeters: 80,
        recordedAt: secondExit.add(const Duration(minutes: 10)),
      );
      expect(finished.sessionEnded, isTrue);
      final session = await (database.select(
        database.sessions,
      )..where((row) => row.id.equals(sessionId))).getSingle();
      expect(session.endedAt, secondExit);
      expect(session.durationSeconds, 15 * 60);
    },
  );

  test(
    'weekly schedule saves weekday and local time without duplicate days',
    () async {
      await repository.saveWeeklySchedule(
        studentId: student.id,
        dayToStartTime: {1: '17:30', 4: '18:00'},
        expectedDurationMinutes: 60,
      );
      await repository.saveWeeklySchedule(
        studentId: student.id,
        dayToStartTime: {1: '17:45', 5: '19:00'},
        expectedDurationMinutes: 75,
      );

      final schedules = await repository.getSchedules(student.id);
      expect(schedules, hasLength(2));
      expect(schedules.map((schedule) => schedule.dayOfWeek), [1, 5]);
      expect(schedules.first.startTime, '17:45');
      expect(schedules.first.expectedDurationMinutes, 75);
      expect(
        await (database.select(
          database.schedules,
        )..where((schedule) => schedule.deletedAt.isNotNull())).get(),
        hasLength(1),
      );
    },
  );
}
