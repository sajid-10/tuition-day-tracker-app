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
  String get dashboardSubtitle => 'আপনার টিউশনের সংক্ষিপ্ত বিবরণ';

  @override
  String get studentsSubtitle => 'আপনার টিউশন শিক্ষার্থীদের পরিচালনা করুন';

  @override
  String get settingsSubtitle => 'অ্যাপটি নিজের মতো সাজান';

  @override
  String get unknownError => 'একটি সমস্যা হয়েছে। আবার চেষ্টা করুন।';
}
