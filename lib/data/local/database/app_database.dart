import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Students extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get geofenceRadiusMeters =>
      integer().withDefault(const Constant(100))();
  IntColumn get sessionDurationMinutes =>
      integer().withDefault(const Constant(120))();
  IntColumn get tuitionDayThresholdMinutes =>
      integer().withDefault(const Constant(120))();
  IntColumn get paymentRate => integer().withDefault(const Constant(0))();
  TextColumn get paymentTriggerType =>
      text().withDefault(const Constant('tuition_days'))();
  IntColumn get paymentTriggerValue =>
      integer().withDefault(const Constant(30))();
  IntColumn get completedDaysTarget =>
      integer().withDefault(const Constant(12))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Schedules extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayOfWeek => integer()();
  TextColumn get startTime => text()();
  IntColumn get expectedDurationMinutes => integer()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get requiredDurationSeconds => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  IntColumn get activeSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastInsideAt => dateTime().nullable()();
  DateTimeColumn get outsideSinceAt => dateTime().nullable()();
  RealColumn get startLatitude => real().nullable()();
  RealColumn get startLongitude => real().nullable()();
  RealColumn get endLatitude => real().nullable()();
  RealColumn get endLongitude => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get amount => integer()();
  IntColumn get tuitionDays => integer()();
  DateTimeColumn get periodStart => dateTime().nullable()();
  DateTimeColumn get periodEnd => dateTime().nullable()();
  DateTimeColumn get paymentDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocationLogs extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  TextColumn get sessionId =>
      text().nullable().references(Sessions, #id, onDelete: KeyAction.setNull)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get accuracyMeters => real()();
  RealColumn get distanceMeters => real()();
  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ArrivalPrompts extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get detectedAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get decidedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Students,
    Schedules,
    Sessions,
    Payments,
    SyncQueue,
    LocationLogs,
    ArrivalPrompts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'tuition_tracker',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await customStatement(
          'ALTER TABLE students ADD COLUMN completed_days_target INTEGER NOT NULL DEFAULT 12',
        );
        await customStatement(
          'ALTER TABLE sessions ADD COLUMN active_seconds INTEGER NOT NULL DEFAULT 0',
        );
        await customStatement(
          'ALTER TABLE sessions ADD COLUMN last_inside_at INTEGER NULL',
        );
        await customStatement(
          'ALTER TABLE sessions ADD COLUMN outside_since_at INTEGER NULL',
        );
        await migrator.createTable(locationLogs);
        await migrator.createTable(arrivalPrompts);
      }
    },
  );
}
