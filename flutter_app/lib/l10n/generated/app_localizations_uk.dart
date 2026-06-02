// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Вчимо іврит';

  @override
  String get localeNameUk => 'Українська';

  @override
  String get localeNameEn => 'English';

  @override
  String get profileLanguageTitle => 'Мова';

  @override
  String get profileLanguageBody =>
      'Перемикає мову інтерфейсу між українською та англійською.';

  @override
  String get homeGreetingNight => 'Доброї ночі';

  @override
  String get homeGreetingMorning => 'Доброго ранку';

  @override
  String get homeGreetingDay => 'Доброго дня';

  @override
  String get homeGreetingEvening => 'Доброго вечора';
}
