// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tuition Tracker';

  @override
  String get home => 'Home';

  @override
  String get students => 'Students';

  @override
  String get settings => 'Settings';

  @override
  String get today => 'Today';

  @override
  String get thisMonth => 'This month';

  @override
  String get completedDays => 'Completed days';

  @override
  String get expectedIncome => 'Expected income';

  @override
  String get pending => 'Pending';

  @override
  String get noStudentsTitle => 'No students yet';

  @override
  String get noStudentsMessage => 'Add a student to start tracking tuition.';

  @override
  String get addStudent => 'Add student';

  @override
  String get studentName => 'Student name';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get notes => 'Notes';

  @override
  String get locationCoordinates => 'Location coordinates (optional)';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get geofenceRadius => 'Location radius';

  @override
  String get sessionDuration => 'Expected session duration (minutes)';

  @override
  String get tuitionThreshold => 'Completed-day threshold (minutes)';

  @override
  String get paymentRate => 'Payment per completed day (BDT)';

  @override
  String get saveStudent => 'Save student';

  @override
  String get studentSaved => 'Student saved';

  @override
  String get studentNameRequired => 'Enter a student name.';

  @override
  String get invalidNumber => 'Enter a valid number.';

  @override
  String get invalidCoordinates => 'Enter valid latitude and longitude values.';

  @override
  String get studentDetails => 'Student details';

  @override
  String get activeStudents => 'Active students';

  @override
  String studentCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
      zero: 'No students',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get settingsSaved => 'Preference updated';

  @override
  String get archiveStudent => 'Archive student';

  @override
  String archiveStudentPrompt(Object name) {
    return 'Archive $name? Their saved history will remain on this device.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get archive => 'Archive';

  @override
  String get studentArchived => 'Student archived';

  @override
  String get noAddress => 'No address added';

  @override
  String get ratePerDay => 'Rate per completed day';

  @override
  String minutes(Object count) {
    return '$count min';
  }

  @override
  String get minuteUnit => 'min';

  @override
  String get meterShort => 'm';

  @override
  String get dashboardSubtitle => 'Your tuition at a glance';

  @override
  String get studentsSubtitle => 'Manage your tuition students';

  @override
  String get settingsSubtitle => 'Personalize your app';

  @override
  String get unknownError => 'Something went wrong. Please try again.';
}
