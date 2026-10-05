import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tuition Tracker'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @completedDays.
  ///
  /// In en, this message translates to:
  /// **'Completed days'**
  String get completedDays;

  /// No description provided for @expectedIncome.
  ///
  /// In en, this message translates to:
  /// **'Expected income'**
  String get expectedIncome;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @noStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No students yet'**
  String get noStudentsTitle;

  /// No description provided for @noStudentsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a student to start tracking tuition.'**
  String get noStudentsMessage;

  /// No description provided for @addStudent.
  ///
  /// In en, this message translates to:
  /// **'Add student'**
  String get addStudent;

  /// No description provided for @studentName.
  ///
  /// In en, this message translates to:
  /// **'Student name'**
  String get studentName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @locationCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Location coordinates (optional)'**
  String get locationCoordinates;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @geofenceRadius.
  ///
  /// In en, this message translates to:
  /// **'Location radius'**
  String get geofenceRadius;

  /// No description provided for @sessionDuration.
  ///
  /// In en, this message translates to:
  /// **'Expected session duration (minutes)'**
  String get sessionDuration;

  /// No description provided for @tuitionThreshold.
  ///
  /// In en, this message translates to:
  /// **'Completed-day threshold (minutes)'**
  String get tuitionThreshold;

  /// No description provided for @paymentRate.
  ///
  /// In en, this message translates to:
  /// **'Payment per completed day (BDT)'**
  String get paymentRate;

  /// No description provided for @saveStudent.
  ///
  /// In en, this message translates to:
  /// **'Save student'**
  String get saveStudent;

  /// No description provided for @studentSaved.
  ///
  /// In en, this message translates to:
  /// **'Student saved'**
  String get studentSaved;

  /// No description provided for @studentNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a student name.'**
  String get studentNameRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number.'**
  String get invalidNumber;

  /// No description provided for @invalidCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Enter valid latitude and longitude values.'**
  String get invalidCoordinates;

  /// No description provided for @studentDetails.
  ///
  /// In en, this message translates to:
  /// **'Student details'**
  String get studentDetails;

  /// No description provided for @activeStudents.
  ///
  /// In en, this message translates to:
  /// **'Active students'**
  String get activeStudents;

  /// No description provided for @studentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No students} =1{1 student} other{{count} students}}'**
  String studentCount(num count);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Preference updated'**
  String get settingsSaved;

  /// No description provided for @archiveStudent.
  ///
  /// In en, this message translates to:
  /// **'Archive student'**
  String get archiveStudent;

  /// No description provided for @archiveStudentPrompt.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}? Their saved history will remain on this device.'**
  String archiveStudentPrompt(Object name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @studentArchived.
  ///
  /// In en, this message translates to:
  /// **'Student archived'**
  String get studentArchived;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No address added'**
  String get noAddress;

  /// No description provided for @ratePerDay.
  ///
  /// In en, this message translates to:
  /// **'Rate per completed day'**
  String get ratePerDay;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutes(Object count);

  /// No description provided for @minuteUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minuteUnit;

  /// No description provided for @meterShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get meterShort;

  /// No description provided for @editTuitionLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit tuition location'**
  String get editTuitionLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @paymentTargetDays.
  ///
  /// In en, this message translates to:
  /// **'Completed days before payment reminder'**
  String get paymentTargetDays;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @locationBackgroundNote.
  ///
  /// In en, this message translates to:
  /// **'Background tracking needs Location access set to Allow all the time and notifications enabled. GPS works without internet; Android may delay updates to save battery.'**
  String get locationBackgroundNote;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location services and try again.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Allow location access in Settings.'**
  String get locationPermissionDenied;

  /// No description provided for @locationReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read your current location.'**
  String get locationReadFailed;

  /// No description provided for @locationTracking.
  ///
  /// In en, this message translates to:
  /// **'Location tracking'**
  String get locationTracking;

  /// No description provided for @startLocationTracking.
  ///
  /// In en, this message translates to:
  /// **'Enable background tracking'**
  String get startLocationTracking;

  /// No description provided for @stopLocationTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop background tracking'**
  String get stopLocationTracking;

  /// No description provided for @locationTrackingOn.
  ///
  /// In en, this message translates to:
  /// **'Location monitoring is active.'**
  String get locationTrackingOn;

  /// No description provided for @locationTrackingOff.
  ///
  /// In en, this message translates to:
  /// **'Location monitoring is stopped.'**
  String get locationTrackingOff;

  /// No description provided for @trackingAndroidOnly.
  ///
  /// In en, this message translates to:
  /// **'Background tracking is currently available on Android only.'**
  String get trackingAndroidOnly;

  /// No description provided for @trackingPermissionNote.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking enabled to receive arrival prompts. Android requires persistent location and notification permissions.'**
  String get trackingPermissionNote;

  /// No description provided for @locationTrackingStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start background tracking. Check location and notification permissions.'**
  String get locationTrackingStartFailed;

  /// No description provided for @locationTrackingStopFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not stop background tracking. Try again.'**
  String get locationTrackingStopFailed;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly schedule'**
  String get weeklySchedule;

  /// No description provided for @editWeeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit weekly schedule'**
  String get editWeeklySchedule;

  /// No description provided for @scheduleSaved.
  ///
  /// In en, this message translates to:
  /// **'Weekly schedule saved'**
  String get scheduleSaved;

  /// No description provided for @noSchedule.
  ///
  /// In en, this message translates to:
  /// **'No weekly schedule added'**
  String get noSchedule;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose time'**
  String get chooseTime;

  /// No description provided for @saveSchedule.
  ///
  /// In en, this message translates to:
  /// **'Save schedule'**
  String get saveSchedule;

  /// No description provided for @scheduleSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the weekly schedule.'**
  String get scheduleSaveFailed;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your tuition at a glance'**
  String get dashboardSubtitle;

  /// No description provided for @studentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your tuition students'**
  String get studentsSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize your app'**
  String get settingsSubtitle;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknownError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
