import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database/app_database.dart';

class StudentRepository {
  StudentRepository(this._database);

  static const _uuid = Uuid();
  final AppDatabase _database;

  Stream<List<Student>> watchActiveStudents() {
    return (_database.select(_database.students)
          ..where((student) => student.active & student.deletedAt.isNull())
          ..orderBy([(student) => OrderingTerm.asc(student.name)]))
        .watch();
  }

  Future<List<Student>> getActiveStudentsWithLocations() {
    return (_database.select(_database.students)..where(
          (student) =>
              student.active &
              student.deletedAt.isNull() &
              student.latitude.isNotNull() &
              student.longitude.isNotNull(),
        ))
        .get();
  }

  Future<Student?> getStudentById(String id) {
    return (_database.select(
      _database.students,
    )..where((student) => student.id.equals(id))).getSingleOrNull();
  }

  Future<void> addStudent({
    required String name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    required int geofenceRadiusMeters,
    required int sessionDurationMinutes,
    required int tuitionDayThresholdMinutes,
    required int paymentRate,
    int completedDaysTarget = 12,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _database
        .into(_database.students)
        .insert(
          StudentsCompanion.insert(
            id: id,
            name: name.trim(),
            phone: Value(_optionalText(phone)),
            address: Value(_optionalText(address)),
            latitude: Value(latitude),
            longitude: Value(longitude),
            geofenceRadiusMeters: Value(geofenceRadiusMeters),
            sessionDurationMinutes: Value(sessionDurationMinutes),
            tuitionDayThresholdMinutes: Value(tuitionDayThresholdMinutes),
            paymentRate: Value(paymentRate),
            completedDaysTarget: Value(completedDaysTarget),
            notes: Value(_optionalText(notes)),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await _enqueue('student', id);
  }

  Future<void> updateStudent({
    required String id,
    required String name,
    String? phone,
    String? address,
    required double? latitude,
    required double? longitude,
    required int geofenceRadiusMeters,
    required int sessionDurationMinutes,
    required int tuitionDayThresholdMinutes,
    required int paymentRate,
    required int completedDaysTarget,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final changed =
        await (_database.update(
          _database.students,
        )..where((student) => student.id.equals(id))).write(
          StudentsCompanion(
            name: Value(name.trim()),
            phone: Value(_optionalText(phone)),
            address: Value(_optionalText(address)),
            latitude: Value(latitude),
            longitude: Value(longitude),
            geofenceRadiusMeters: Value(geofenceRadiusMeters),
            sessionDurationMinutes: Value(sessionDurationMinutes),
            tuitionDayThresholdMinutes: Value(tuitionDayThresholdMinutes),
            paymentRate: Value(paymentRate),
            completedDaysTarget: Value(completedDaysTarget),
            notes: Value(_optionalText(notes)),
            updatedAt: Value(now),
          ),
        );
    if (changed != 1) {
      throw StateError('Student $id was not found while updating.');
    }
    await _enqueue('student', id);
  }

  Future<void> archiveStudent(String id) async {
    final now = DateTime.now().toUtc();
    await (_database.update(
      _database.students,
    )..where((student) => student.id.equals(id))).write(
      StudentsCompanion(
        active: const Value(false),
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _enqueue('student', id);
  }

  Future<List<Schedule>> getSchedules(String studentId) {
    return (_database.select(_database.schedules)
          ..where(
            (schedule) =>
                schedule.studentId.equals(studentId) &
                schedule.active &
                schedule.deletedAt.isNull(),
          )
          ..orderBy([(schedule) => OrderingTerm.asc(schedule.dayOfWeek)]))
        .get();
  }

  Future<void> saveWeeklySchedule({
    required String studentId,
    required Map<int, String> dayToStartTime,
    required int expectedDurationMinutes,
  }) async {
    if (dayToStartTime.keys.any((day) => day < 1 || day > 7)) {
      throw ArgumentError.value(dayToStartTime.keys, 'dayToStartTime');
    }
    if (expectedDurationMinutes <= 0) {
      throw ArgumentError.value(
        expectedDurationMinutes,
        'expectedDurationMinutes',
      );
    }
    for (final time in dayToStartTime.values) {
      if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(time)) {
        throw ArgumentError.value(time, 'startTime');
      }
    }

    await _database.transaction(() async {
      final now = DateTime.now().toUtc();
      final existing = await getSchedules(studentId);
      final existingByDay = <int, Schedule>{};
      for (final schedule in existing) {
        final duplicate = existingByDay[schedule.dayOfWeek];
        if (duplicate == null) {
          existingByDay[schedule.dayOfWeek] = schedule;
        } else {
          await _softDeleteSchedule(schedule.id, now);
        }
      }

      for (final entry in existingByDay.entries) {
        final newTime = dayToStartTime[entry.key];
        if (newTime == null) {
          await _softDeleteSchedule(entry.value.id, now);
          continue;
        }
        await (_database.update(
          _database.schedules,
        )..where((schedule) => schedule.id.equals(entry.value.id))).write(
          SchedulesCompanion(
            startTime: Value(newTime),
            expectedDurationMinutes: Value(expectedDurationMinutes),
            updatedAt: Value(now),
          ),
        );
        await _enqueue('schedule', entry.value.id);
      }

      for (final entry in dayToStartTime.entries) {
        if (existingByDay.containsKey(entry.key)) continue;
        final id = _uuid.v4();
        await _database
            .into(_database.schedules)
            .insert(
              SchedulesCompanion.insert(
                id: id,
                studentId: studentId,
                dayOfWeek: entry.key,
                startTime: entry.value,
                expectedDurationMinutes: expectedDurationMinutes,
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
        await _enqueue('schedule', id);
      }
    });
  }

  Future<void> _softDeleteSchedule(String id, DateTime updatedAt) async {
    await (_database.update(
      _database.schedules,
    )..where((schedule) => schedule.id.equals(id))).write(
      SchedulesCompanion(
        active: const Value(false),
        deletedAt: Value(updatedAt),
        updatedAt: Value(updatedAt),
      ),
    );
    await _enqueue('schedule', id);
  }

  Future<bool> hasActiveSession(String studentId) async {
    final row =
        await (_database.select(_database.sessions)
              ..where(
                (session) =>
                    session.studentId.equals(studentId) &
                    session.endedAt.isNull() &
                    session.deletedAt.isNull(),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<List<Session>> getActiveSessions() {
    return (_database.select(_database.sessions)..where(
          (session) => session.endedAt.isNull() & session.deletedAt.isNull(),
        ))
        .get();
  }

  Future<ArrivalPrompt?> createArrivalPrompt({
    required String studentId,
    required double latitude,
    required double longitude,
    required DateTime detectedAt,
  }) async {
    final cooldownStart = detectedAt.toUtc().subtract(const Duration(hours: 6));
    final recentPrompt =
        await (_database.select(_database.arrivalPrompts)
              ..where(
                (prompt) =>
                    prompt.studentId.equals(studentId) &
                    prompt.detectedAt.isBiggerOrEqualValue(cooldownStart),
              )
              ..limit(1))
            .getSingleOrNull();
    if (recentPrompt != null) return null;

    final id = _uuid.v4();
    await _database
        .into(_database.arrivalPrompts)
        .insert(
          ArrivalPromptsCompanion.insert(
            id: id,
            studentId: studentId,
            latitude: latitude,
            longitude: longitude,
            detectedAt: detectedAt.toUtc(),
          ),
        );
    await _enqueue('arrival_prompt', id);
    return (_database.select(
      _database.arrivalPrompts,
    )..where((prompt) => prompt.id.equals(id))).getSingle();
  }

  Future<String> acceptArrivalPrompt(String promptId) {
    return _database.transaction(() async {
      final prompt =
          await (_database.select(_database.arrivalPrompts)
                ..where((item) => item.id.equals(promptId))
                ..limit(1))
              .getSingleOrNull();
      if (prompt == null || prompt.status != 'pending') {
        throw StateError('Arrival prompt is no longer pending.');
      }

      final activeSession =
          await (_database.select(_database.sessions)
                ..where(
                  (session) =>
                      session.studentId.equals(prompt.studentId) &
                      session.endedAt.isNull() &
                      session.deletedAt.isNull(),
                )
                ..limit(1))
              .getSingleOrNull();
      if (activeSession != null) {
        throw StateError('This student already has an active session.');
      }

      final student = await getStudentById(prompt.studentId);
      if (student == null || !student.active || student.deletedAt != null) {
        throw StateError('The student is no longer active.');
      }

      final now = DateTime.now().toUtc();
      final sessionId = _uuid.v4();
      await _database
          .into(_database.sessions)
          .insert(
            SessionsCompanion.insert(
              id: sessionId,
              studentId: student.id,
              startedAt: now,
              requiredDurationSeconds: student.tuitionDayThresholdMinutes * 60,
              source: const Value('automatic'),
              startLatitude: Value(prompt.latitude),
              startLongitude: Value(prompt.longitude),
              lastInsideAt: Value(now),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await (_database.update(
        _database.arrivalPrompts,
      )..where((item) => item.id.equals(promptId))).write(
        ArrivalPromptsCompanion(
          status: const Value('accepted'),
          decidedAt: Value(now),
        ),
      );
      await _enqueue('arrival_prompt', promptId);
      await _enqueue('session', sessionId);
      return sessionId;
    });
  }

  Future<void> declineArrivalPrompt(String promptId) async {
    final now = DateTime.now().toUtc();
    await (_database.update(_database.arrivalPrompts)..where(
          (prompt) =>
              prompt.id.equals(promptId) & prompt.status.equals('pending'),
        ))
        .write(
          ArrivalPromptsCompanion(
            status: const Value('declined'),
            decidedAt: Value(now),
          ),
        );
    await _enqueue('arrival_prompt', promptId);
  }

  Future<PositionProcessingResult> processLocationFix({
    required Student student,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required double distanceMeters,
    required DateTime recordedAt,
    Duration exitGracePeriod = const Duration(minutes: 10),
  }) async {
    final at = recordedAt.toUtc();
    if (accuracyMeters > _acceptableAccuracy(student.geofenceRadiusMeters)) {
      return const PositionProcessingResult();
    }

    return _database.transaction(() async {
      final session =
          await (_database.select(_database.sessions)
                ..where(
                  (row) =>
                      row.studentId.equals(student.id) &
                      row.endedAt.isNull() &
                      row.deletedAt.isNull(),
                )
                ..limit(1))
              .getSingleOrNull();

      final withinRadius = distanceMeters <= student.geofenceRadiusMeters;
      if (session == null) {
        if (!withinRadius) return const PositionProcessingResult();
        final prompt = await createArrivalPrompt(
          studentId: student.id,
          latitude: latitude,
          longitude: longitude,
          detectedAt: at,
        );
        if (prompt != null) {
          await _recordLocationLog(
            studentId: student.id,
            latitude: latitude,
            longitude: longitude,
            accuracyMeters: accuracyMeters,
            distanceMeters: distanceMeters,
            recordedAt: at,
          );
        }
        return PositionProcessingResult(arrivalPrompt: prompt);
      }

      var activeSeconds = session.activeSeconds;
      var outsideSinceAt = session.outsideSinceAt;
      var lastInsideAt = session.lastInsideAt ?? session.startedAt;
      var completedNow = false;
      var endedNow = false;

      if (withinRadius) {
        final elapsed = at.difference(lastInsideAt).inSeconds;
        if (outsideSinceAt == null && elapsed > 0 && elapsed <= 10 * 60) {
          activeSeconds += elapsed;
        }
        lastInsideAt = at;
        outsideSinceAt = null;
        completedNow =
            !session.completed &&
            activeSeconds >= session.requiredDurationSeconds;
      } else {
        outsideSinceAt ??= at;
        if (at.difference(outsideSinceAt) >= exitGracePeriod) {
          final lastConfirmedInside = session.lastInsideAt ?? session.startedAt;
          final graceToLastFix = outsideSinceAt.difference(lastConfirmedInside);
          if (graceToLastFix.inSeconds > 0 &&
              graceToLastFix.inSeconds <= 10 * 60) {
            activeSeconds += graceToLastFix.inSeconds;
          }
          endedNow = true;
          completedNow =
              !session.completed &&
              activeSeconds >= session.requiredDurationSeconds;
        }
      }

      final updated =
          await (_database.update(
            _database.sessions,
          )..where((row) => row.id.equals(session.id))).write(
            SessionsCompanion(
              activeSeconds: Value(activeSeconds),
              lastInsideAt: Value(lastInsideAt),
              outsideSinceAt: Value(outsideSinceAt),
              completed: Value(session.completed || completedNow),
              endedAt: endedNow ? Value(outsideSinceAt!) : const Value.absent(),
              durationSeconds: endedNow
                  ? Value(activeSeconds)
                  : const Value.absent(),
              endLatitude: endedNow ? Value(latitude) : const Value.absent(),
              endLongitude: endedNow ? Value(longitude) : const Value.absent(),
              updatedAt: Value(at),
            ),
          );
      if (updated != 1) {
        throw StateError('Active session ${session.id} could not be updated.');
      }

      await _recordLocationLog(
        studentId: student.id,
        sessionId: session.id,
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracyMeters,
        distanceMeters: distanceMeters,
        recordedAt: at,
      );

      if (completedNow || endedNow) await _enqueue('session', session.id);
      return PositionProcessingResult(
        thresholdReached: completedNow,
        sessionEnded: endedNow,
        sessionId: session.id,
        activeSeconds: activeSeconds,
      );
    });
  }

  Future<int> completedDaysSinceLastPayment(String studentId) async {
    final lastPayment =
        await (_database.select(_database.payments)
              ..where(
                (payment) =>
                    payment.studentId.equals(studentId) &
                    payment.status.equals('paid') &
                    payment.paymentDate.isNotNull(),
              )
              ..orderBy([(payment) => OrderingTerm.desc(payment.paymentDate)])
              ..limit(1))
            .getSingleOrNull();
    final sessions =
        await (_database.select(_database.sessions)..where(
              (session) =>
                  session.studentId.equals(studentId) &
                  session.completed &
                  session.deletedAt.isNull() &
                  (lastPayment == null
                      ? const Constant(true)
                      : session.startedAt.isBiggerThanValue(
                          lastPayment.paymentDate!,
                        )),
            ))
            .get();
    final localDates = sessions.map((session) {
      final local = session.startedAt.toLocal();
      return '${local.year}-${local.month}-${local.day}';
    }).toSet();
    return localDates.length;
  }

  Future<void> _enqueue(String entityType, String entityId) async {
    await _database
        .into(_database.syncQueue)
        .insertOnConflictUpdate(
          SyncQueueCompanion.insert(
            id: '$entityType:$entityId',
            entityType: entityType,
            entityId: entityId,
            operation: 'upsert',
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  Future<void> _recordLocationLog({
    required String studentId,
    String? sessionId,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required double distanceMeters,
    required DateTime recordedAt,
  }) async {
    final id = _uuid.v4();
    await _database
        .into(_database.locationLogs)
        .insert(
          LocationLogsCompanion.insert(
            id: id,
            studentId: studentId,
            sessionId: Value(sessionId),
            latitude: latitude,
            longitude: longitude,
            accuracyMeters: accuracyMeters,
            distanceMeters: distanceMeters,
            recordedAt: recordedAt,
          ),
        );
    await _enqueue('location_log', id);
  }

  double _acceptableAccuracy(int radius) =>
      (radius * 2).clamp(100, 250).toDouble();

  String? _optionalText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class PositionProcessingResult {
  const PositionProcessingResult({
    this.arrivalPrompt,
    this.thresholdReached = false,
    this.sessionEnded = false,
    this.sessionId,
    this.activeSeconds = 0,
  });

  final ArrivalPrompt? arrivalPrompt;
  final bool thresholdReached;
  final bool sessionEnded;
  final String? sessionId;
  final int activeSeconds;
}
