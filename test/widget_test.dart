import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuition_time_tracker/core/settings/app_settings.dart';
import 'package:tuition_time_tracker/data/local/database/app_database.dart';
import 'package:tuition_time_tracker/data/local/database/database_provider.dart';
import 'package:tuition_time_tracker/features/students/add_student_screen.dart';
import 'package:tuition_time_tracker/main.dart';

void main() {
  late AppDatabase database;
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('student can be added and appears in the local list', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          databaseProvider.overrideWithValue(database),
        ],
        child: const TuitionTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Students'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.text('Add student'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AddStudentScreen), findsOneWidget);
    expect(find.text('Save student'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Amina Rahman');
    await tester.tap(find.text('Save student'));
    await tester.pumpAndSettle();

    expect(find.text('Amina Rahman'), findsOneWidget);
    final savedStudents = await database.select(database.students).get();
    expect(savedStudents, hasLength(1));
    expect(savedStudents.single.name, 'Amina Rahman');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 2));
  });

  testWidgets('settings can switch language immediately', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          databaseProvider.overrideWithValue(database),
        ],
        child: const TuitionTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('বাংলা').last);
    await tester.pumpAndSettle();

    expect(find.text('সেটিংস'), findsNWidgets(2));
    expect(preferences.getString('language'), 'bn');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 2));
  });
}
