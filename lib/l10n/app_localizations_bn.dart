// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'টিউশন ট্র্যাকার';

  @override
  String get home => 'হোম';

  @override
  String get students => 'শিক্ষার্থী';

  @override
  String get settings => 'সেটিংস';

  @override
  String get today => 'আজ';

  @override
  String get thisMonth => 'এই মাস';

  @override
  String get completedDays => 'সম্পন্ন দিন';

  @override
  String get expectedIncome => 'প্রত্যাশিত আয়';

  @override
  String get pending => 'বকেয়া';

  @override
  String get noStudentsTitle => 'এখনও কোনো শিক্ষার্থী নেই';

  @override
  String get noStudentsMessage =>
      'টিউশন ট্র্যাক করতে একজন শিক্ষার্থী যোগ করুন।';

  @override
  String get addStudent => 'শিক্ষার্থী যোগ করুন';

  @override
  String get studentName => 'শিক্ষার্থীর নাম';

  @override
  String get phone => 'ফোন';

  @override
  String get address => 'ঠিকানা';

  @override
  String get notes => 'নোট';

  @override
  String get locationCoordinates => 'অবস্থানের স্থানাঙ্ক (ঐচ্ছিক)';

  @override
  String get latitude => 'অক্ষাংশ';

  @override
  String get longitude => 'দ্রাঘিমাংশ';

  @override
  String get geofenceRadius => 'অবস্থানের ব্যাসার্ধ';

  @override
  String get sessionDuration => 'প্রত্যাশিত সেশনের সময় (মিনিট)';

  @override
  String get tuitionThreshold => 'সম্পন্ন দিনের সীমা (মিনিট)';

  @override
  String get paymentRate => 'প্রতি সম্পন্ন দিনের পেমেন্ট (টাকা)';

  @override
  String get saveStudent => 'শিক্ষার্থী সংরক্ষণ করুন';

  @override
  String get studentSaved => 'শিক্ষার্থীর তথ্য সংরক্ষিত হয়েছে';

  @override
  String get studentNameRequired => 'শিক্ষার্থীর নাম লিখুন।';

  @override
  String get invalidNumber => 'একটি সঠিক সংখ্যা লিখুন।';

  @override
  String get invalidCoordinates => 'অক্ষাংশ ও দ্রাঘিমাংশের সঠিক মান লিখুন।';

  @override
  String get studentDetails => 'শিক্ষার্থীর বিবরণ';

  @override
  String get activeStudents => 'সক্রিয় শিক্ষার্থী';

  @override
  String studentCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count জন শিক্ষার্থী',
      one: '১ জন শিক্ষার্থী',
      zero: 'কোনো শিক্ষার্থী নেই',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'অ্যাপের ধরন';

  @override
  String get language => 'ভাষা';

  @override
  String get systemDefault => 'সিস্টেম অনুযায়ী';

  @override
  String get light => 'লাইট';

  @override
  String get dark => 'ডার্ক';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get settingsSaved => 'পছন্দ সংরক্ষণ করা হয়েছে';

  @override
  String get archiveStudent => 'শিক্ষার্থী আর্কাইভ করুন';

  @override
  String archiveStudentPrompt(Object name) {
    return '$name-কে আর্কাইভ করবেন? তাঁর সংরক্ষিত ইতিহাস এই ডিভাইসে থাকবে।';
  }

  @override
  String get cancel => 'বাতিল';

  @override
  String get archive => 'আর্কাইভ';

  @override
  String get studentArchived => 'শিক্ষার্থী আর্কাইভ করা হয়েছে';

  @override
  String get noAddress => 'ঠিকানা যোগ করা হয়নি';

  @override
  String get ratePerDay => 'প্রতি সম্পন্ন দিনের হার';

  @override
  String minutes(Object count) {
    return '$count মিনিট';
  }

  @override
  String get minuteUnit => 'মিনিট';

  @override
  String get meterShort => 'মি';

  @override
  String get editTuitionLocation => 'টিউশনের অবস্থান সম্পাদনা';

  @override
  String get useCurrentLocation => 'বর্তমান অবস্থান ব্যবহার করুন';

  @override
  String get paymentTargetDays => 'পেমেন্ট বিজ্ঞপ্তির আগে সম্পন্ন দিন';

  @override
  String get daysUnit => 'দিন';

  @override
  String get locationBackgroundNote =>
      'ব্যাকগ্রাউন্ড ট্র্যাকিংয়ের জন্য লোকেশন অনুমতি \'সব সময় অনুমতি দিন\' এবং বিজ্ঞপ্তি চালু রাখুন। জিপিএস ইন্টারনেট ছাড়াই কাজ করে; ব্যাটারি বাঁচাতে অ্যান্ড্রয়েড আপডেট দেরি করাতে পারে।';

  @override
  String get locationServicesDisabled =>
      'লোকেশন সেবা চালু করে আবার চেষ্টা করুন।';

  @override
  String get locationPermissionDenied =>
      'লোকেশন অনুমতি দেওয়া হয়নি। সেটিংসে লোকেশন অনুমতি দিন।';

  @override
  String get locationReadFailed => 'বর্তমান অবস্থান পড়া যায়নি।';

  @override
  String get locationTracking => 'লোকেশন ট্র্যাকিং';

  @override
  String get startLocationTracking => 'ব্যাকগ্রাউন্ড ট্র্যাকিং চালু করুন';

  @override
  String get stopLocationTracking => 'ব্যাকগ্রাউন্ড ট্র্যাকিং বন্ধ করুন';

  @override
  String get locationTrackingOn => 'লোকেশন পর্যবেক্ষণ চালু আছে।';

  @override
  String get locationTrackingOff => 'লোকেশন পর্যবেক্ষণ বন্ধ আছে।';

  @override
  String get trackingAndroidOnly =>
      'ব্যাকগ্রাউন্ড ট্র্যাকিং বর্তমানে শুধু অ্যান্ড্রয়েডে উপলভ্য।';

  @override
  String get trackingPermissionNote =>
      'অবস্থান বিজ্ঞপ্তি পেতে ট্র্যাকিং চালু রাখুন। অ্যান্ড্রয়েডে লোকেশন ও বিজ্ঞপ্তির স্থায়ী অনুমতি প্রয়োজন।';

  @override
  String get locationTrackingStartFailed =>
      'ব্যাকগ্রাউন্ড ট্র্যাকিং শুরু হয়নি। লোকেশন ও বিজ্ঞপ্তির অনুমতি যাচাই করুন।';

  @override
  String get locationTrackingStopFailed =>
      'ব্যাকগ্রাউন্ড ট্র্যাকিং বন্ধ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get weeklySchedule => 'সাপ্তাহিক সময়সূচি';

  @override
  String get editWeeklySchedule => 'সাপ্তাহিক সময়সূচি সম্পাদনা';

  @override
  String get scheduleSaved => 'সাপ্তাহিক সময়সূচি সংরক্ষিত হয়েছে';

  @override
  String get noSchedule => 'কোনো সাপ্তাহিক সময়সূচি যোগ করা হয়নি';

  @override
  String get sunday => 'রবিবার';

  @override
  String get monday => 'সোমবার';

  @override
  String get tuesday => 'মঙ্গলবার';

  @override
  String get wednesday => 'বুধবার';

  @override
  String get thursday => 'বৃহস্পতিবার';

  @override
  String get friday => 'শুক্রবার';

  @override
  String get saturday => 'শনিবার';

  @override
  String get chooseTime => 'সময় নির্বাচন করুন';

  @override
  String get saveSchedule => 'সময়সূচি সংরক্ষণ করুন';

  @override
  String get scheduleSaveFailed => 'সাপ্তাহিক সময়সূচি সংরক্ষণ করা যায়নি।';

  @override
  String get dashboardSubtitle => 'আপনার টিউশনের সংক্ষিপ্ত বিবরণ';

  @override
  String get studentsSubtitle => 'আপনার টিউশন শিক্ষার্থীদের পরিচালনা করুন';

  @override
  String get settingsSubtitle => 'অ্যাপটি নিজের মতো সাজান';

  @override
  String get unknownError => 'একটি সমস্যা হয়েছে। আবার চেষ্টা করুন।';
}
