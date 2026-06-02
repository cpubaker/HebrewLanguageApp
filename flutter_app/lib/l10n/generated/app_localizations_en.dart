// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Learn Hebrew';

  @override
  String get localeNameUk => 'Ukrainian';

  @override
  String get localeNameEn => 'English';

  @override
  String get profileLanguageTitle => 'Language';

  @override
  String get profileLanguageBody =>
      'Switches the interface between Ukrainian and English.';

  @override
  String get homeGreetingNight => 'Good night';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingDay => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';
}
