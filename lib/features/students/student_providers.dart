import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database/app_database.dart';
import '../../data/local/database/database_provider.dart';
import '../../data/repositories/student_repository.dart';

final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepository(ref.watch(databaseProvider)),
);

final activeStudentsProvider = StreamProvider<List<Student>>(
  (ref) => ref.watch(studentRepositoryProvider).watchActiveStudents(),
);
