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
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    await _database.into(_database.students).insert(
      StudentsCompanion.insert(
        id: _uuid.v4(),
        name: name.trim(),
        phone: Value(_optionalText(phone)),
        address: Value(_optionalText(address)),
        latitude: Value(latitude),
        longitude: Value(longitude),
        geofenceRadiusMeters: Value(geofenceRadiusMeters),
        sessionDurationMinutes: Value(sessionDurationMinutes),
        tuitionDayThresholdMinutes: Value(tuitionDayThresholdMinutes),
        paymentRate: Value(paymentRate),
        notes: Value(_optionalText(notes)),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> archiveStudent(String id) async {
    final now = DateTime.now().toUtc();
    await (_database.update(_database.students)..where(
      (student) => student.id.equals(id),
    )).write(
      StudentsCompanion(
        active: const Value(false),
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  String? _optionalText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
