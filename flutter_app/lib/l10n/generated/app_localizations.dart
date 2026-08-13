import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('uk'),
  ];

  /// Application title shown by the OS task switcher.
  ///
  /// In uk, this message translates to:
  /// **'Вчимо іврит'**
  String get appTitle;

  /// Display name of the Ukrainian locale shown in the language picker.
  ///
  /// In uk, this message translates to:
  /// **'Українська'**
  String get localeNameUk;

  /// Display name of the English locale shown in the language picker.
  ///
  /// In uk, this message translates to:
  /// **'English'**
  String get localeNameEn;

  /// Title of the language switcher tile in the profile settings.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get profileLanguageTitle;

  /// Subtitle of the language switcher tile.
  ///
  /// In uk, this message translates to:
  /// **'Перемикає мову інтерфейсу між українською та англійською.'**
  String get profileLanguageBody;

  /// Greeting on the home screen between midnight and 5 AM.
  ///
  /// In uk, this message translates to:
  /// **'Доброї ночі'**
  String get homeGreetingNight;

  /// Greeting on the home screen between 5 AM and noon.
  ///
  /// In uk, this message translates to:
  /// **'Доброго ранку'**
  String get homeGreetingMorning;

  /// Greeting on the home screen between noon and 6 PM.
  ///
  /// In uk, this message translates to:
  /// **'Доброго дня'**
  String get homeGreetingDay;

  /// Greeting on the home screen between 6 PM and midnight.
  ///
  /// In uk, this message translates to:
  /// **'Доброго вечора'**
  String get homeGreetingEvening;

  /// No description provided for @navHome.
  ///
  /// In uk, this message translates to:
  /// **'Головна'**
  String get navHome;

  /// No description provided for @navLearn.
  ///
  /// In uk, this message translates to:
  /// **'Вчитись'**
  String get navLearn;

  /// No description provided for @navPractice.
  ///
  /// In uk, this message translates to:
  /// **'Практика'**
  String get navPractice;

  /// No description provided for @navProfile.
  ///
  /// In uk, this message translates to:
  /// **'Профіль'**
  String get navProfile;

  /// No description provided for @learnWorkspaceSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Оберіть, з чого продовжити навчання.'**
  String get learnWorkspaceSubtitle;

  /// No description provided for @workspaceWordsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Слова'**
  String get workspaceWordsTitle;

  /// No description provided for @workspaceWordsSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Словник з пошуком, фільтрами й прогресом.'**
  String get workspaceWordsSubtitle;

  /// No description provided for @workspaceVerbsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Дієслова'**
  String get workspaceVerbsTitle;

  /// No description provided for @workspaceVerbsSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Уроки з поясненнями та озвученням.'**
  String get workspaceVerbsSubtitle;

  /// No description provided for @workspaceGuideTitle.
  ///
  /// In uk, this message translates to:
  /// **'Довідник'**
  String get workspaceGuideTitle;

  /// No description provided for @workspaceGuideSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Граматика з поясненнями та прикладами.'**
  String get workspaceGuideSubtitle;

  /// No description provided for @workspaceReadingTitle.
  ///
  /// In uk, this message translates to:
  /// **'Читання'**
  String get workspaceReadingTitle;

  /// No description provided for @workspaceReadingSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Тексти за рівнями складності.'**
  String get workspaceReadingSubtitle;

  /// No description provided for @practiceWorkspaceSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Оберіть формат тренування і відкрийте його окремим повноекранним сеансом.'**
  String get practiceWorkspaceSubtitle;

  /// No description provided for @workspaceReviewTitle.
  ///
  /// In uk, this message translates to:
  /// **'Повторення'**
  String get workspaceReviewTitle;

  /// No description provided for @workspaceReviewSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Нові слова й останні помилки для спокійного повторення.'**
  String get workspaceReviewSubtitle;

  /// No description provided for @workspaceFlashcardsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Картки'**
  String get workspaceFlashcardsTitle;

  /// No description provided for @workspaceFlashcardsSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Швидке повторення перекладу, контексту і наборів на повторення.'**
  String get workspaceFlashcardsSubtitle;

  /// No description provided for @workspaceWritingTitle.
  ///
  /// In uk, this message translates to:
  /// **'Написання'**
  String get workspaceWritingTitle;

  /// No description provided for @workspaceWritingSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Написання слів івритом без підказок.'**
  String get workspaceWritingSubtitle;

  /// No description provided for @workspaceConstructorTitle.
  ///
  /// In uk, this message translates to:
  /// **'Конструктор'**
  String get workspaceConstructorTitle;

  /// No description provided for @workspaceConstructorSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Складання слова з блоків у правильному порядку.'**
  String get workspaceConstructorSubtitle;

  /// No description provided for @workspaceSprintTitle.
  ///
  /// In uk, this message translates to:
  /// **'Спринт'**
  String get workspaceSprintTitle;

  /// No description provided for @workspaceSprintSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Хвилинний режим на швидкість: для кожного слова є два варіанти перекладу.'**
  String get workspaceSprintSubtitle;

  /// No description provided for @workspaceAiTextTitle.
  ///
  /// In uk, this message translates to:
  /// **'Текст зі словами'**
  String get workspaceAiTextTitle;

  /// No description provided for @workspaceAiTextSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Короткий ШІ-текст з вашими словами, перекладом і швидким переходом до практики.'**
  String get workspaceAiTextSubtitle;

  /// No description provided for @wordOfDay.
  ///
  /// In uk, this message translates to:
  /// **'Слово дня'**
  String get wordOfDay;

  /// No description provided for @wordOfDayAudioChecking.
  ///
  /// In uk, this message translates to:
  /// **'Перевіряємо озвучку'**
  String get wordOfDayAudioChecking;

  /// No description provided for @wordOfDayAudioStop.
  ///
  /// In uk, this message translates to:
  /// **'Зупинити озвучку'**
  String get wordOfDayAudioStop;

  /// No description provided for @wordOfDayAudioPlay.
  ///
  /// In uk, this message translates to:
  /// **'Увімкнути озвучку'**
  String get wordOfDayAudioPlay;

  /// No description provided for @wordOfDayAudioUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Озвучка ще недоступна'**
  String get wordOfDayAudioUnavailable;

  /// No description provided for @wordOfDayAudioFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося відтворити озвучку слова.'**
  String get wordOfDayAudioFailure;

  /// No description provided for @wordOfDayEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Слова з’являться після завантаження навчальної бази.'**
  String get wordOfDayEmpty;

  /// No description provided for @homeActionFirstStep.
  ///
  /// In uk, this message translates to:
  /// **'Перший крок'**
  String get homeActionFirstStep;

  /// No description provided for @homeActionToday.
  ///
  /// In uk, this message translates to:
  /// **'Сьогодні'**
  String get homeActionToday;

  /// No description provided for @homeActionWelcomeTitle.
  ///
  /// In uk, this message translates to:
  /// **'Привіт! Готовий почати?'**
  String get homeActionWelcomeTitle;

  /// No description provided for @homeActionWelcomeSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Відкрий перші картки, щоб познайомитись зі словами івриту й заробити перший день у серії.'**
  String get homeActionWelcomeSubtitle;

  /// No description provided for @homeActionTry.
  ///
  /// In uk, this message translates to:
  /// **'Спробувати'**
  String get homeActionTry;

  /// No description provided for @homeActionReviewTitle.
  ///
  /// In uk, this message translates to:
  /// **'Продовжити повторення'**
  String get homeActionReviewTitle;

  /// No description provided for @homeActionReviewSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'{count} слів чекають у картках на повторення.'**
  String homeActionReviewSubtitle(int count);

  /// No description provided for @homeActionGoToReview.
  ///
  /// In uk, this message translates to:
  /// **'До повторення'**
  String get homeActionGoToReview;

  /// No description provided for @homeActionNewWordsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Готовий до нового?'**
  String get homeActionNewWordsTitle;

  /// No description provided for @homeActionNewWordsSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'{count} слів ще чекають свого першого знайомства.'**
  String homeActionNewWordsSubtitle(int count);

  /// No description provided for @homeActionGoToNewWords.
  ///
  /// In uk, this message translates to:
  /// **'До нових слів'**
  String get homeActionGoToNewWords;

  /// No description provided for @homeActionReadingTitle.
  ///
  /// In uk, this message translates to:
  /// **'Усе повторено — почитаємо?'**
  String get homeActionReadingTitle;

  /// No description provided for @homeActionReadingSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'У бібліотеці чекають тексти, з якими можна підняти рівень.'**
  String get homeActionReadingSubtitle;

  /// No description provided for @homeActionGoToReading.
  ///
  /// In uk, this message translates to:
  /// **'До читання'**
  String get homeActionGoToReading;

  /// No description provided for @homeActionFallbackTitle.
  ///
  /// In uk, this message translates to:
  /// **'Заглянь у словник'**
  String get homeActionFallbackTitle;

  /// No description provided for @homeActionFallbackSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Перегляньте слова, щоб обрати наступний напрям навчання.'**
  String get homeActionFallbackSubtitle;

  /// No description provided for @homeActionGoToWords.
  ///
  /// In uk, this message translates to:
  /// **'До слів'**
  String get homeActionGoToWords;

  /// No description provided for @wordsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Слова'**
  String get wordsTitle;

  /// No description provided for @wordsSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Шукайте українською, англійською, івритом або за транскрипцією.'**
  String get wordsSubtitle;

  /// No description provided for @wordsSearchHint.
  ///
  /// In uk, this message translates to:
  /// **'Шукати слова'**
  String get wordsSearchHint;

  /// No description provided for @wordsFilterAll.
  ///
  /// In uk, this message translates to:
  /// **'Усі'**
  String get wordsFilterAll;

  /// No description provided for @wordsFilterNew.
  ///
  /// In uk, this message translates to:
  /// **'Нові'**
  String get wordsFilterNew;

  /// No description provided for @wordsFilterLearned.
  ///
  /// In uk, this message translates to:
  /// **'Вивчені'**
  String get wordsFilterLearned;

  /// No description provided for @wordsFilterReview.
  ///
  /// In uk, this message translates to:
  /// **'Повторити'**
  String get wordsFilterReview;

  /// No description provided for @wordsVisible.
  ///
  /// In uk, this message translates to:
  /// **'Видимі'**
  String get wordsVisible;

  /// No description provided for @wordsTotal.
  ///
  /// In uk, this message translates to:
  /// **'Усього'**
  String get wordsTotal;

  /// No description provided for @wordsSearchTooltip.
  ///
  /// In uk, this message translates to:
  /// **'Пошук по словнику'**
  String get wordsSearchTooltip;

  /// No description provided for @wordsNoResultsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Нічого не знайдено'**
  String get wordsNoResultsTitle;

  /// No description provided for @wordsNoResultsAll.
  ///
  /// In uk, this message translates to:
  /// **'Спробуйте інший запит: слово українською чи англійською, форму івритом або транскрипцію.'**
  String get wordsNoResultsAll;

  /// No description provided for @wordsNoResultsFilter.
  ///
  /// In uk, this message translates to:
  /// **'У поточному зрізі «{filter}» поки немає результатів. Спробуйте інший фільтр або запит.'**
  String wordsNoResultsFilter(String filter);

  /// No description provided for @wordOpenTooltip.
  ///
  /// In uk, this message translates to:
  /// **'Відкрити слово'**
  String get wordOpenTooltip;

  /// No description provided for @wordChangeStatusTooltip.
  ///
  /// In uk, this message translates to:
  /// **'Змінити статус слова'**
  String get wordChangeStatusTooltip;

  /// No description provided for @wordStatusUnknown.
  ///
  /// In uk, this message translates to:
  /// **'Не знаю'**
  String get wordStatusUnknown;

  /// No description provided for @wordStatusLearning.
  ///
  /// In uk, this message translates to:
  /// **'Вчу'**
  String get wordStatusLearning;

  /// No description provided for @wordStatusKnown.
  ///
  /// In uk, this message translates to:
  /// **'Знаю'**
  String get wordStatusKnown;

  /// No description provided for @wordStatCorrect.
  ///
  /// In uk, this message translates to:
  /// **'Правильно'**
  String get wordStatCorrect;

  /// No description provided for @wordStatMistakes.
  ///
  /// In uk, this message translates to:
  /// **'Помилки'**
  String get wordStatMistakes;

  /// No description provided for @wordContexts.
  ///
  /// In uk, this message translates to:
  /// **'Контексти'**
  String get wordContexts;

  /// No description provided for @wordContextLoading.
  ///
  /// In uk, this message translates to:
  /// **'Шукаємо новий контекст...'**
  String get wordContextLoading;

  /// No description provided for @wordContextEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Для цього слова ще немає контексту.'**
  String get wordContextEmpty;

  /// No description provided for @wordAudioChecking.
  ///
  /// In uk, this message translates to:
  /// **'Перевіряємо аудіо слова'**
  String get wordAudioChecking;

  /// No description provided for @wordAudioUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Аудіо для слова ще недоступне'**
  String get wordAudioUnavailable;

  /// No description provided for @wordAudioStop.
  ///
  /// In uk, this message translates to:
  /// **'Зупинити вимову слова'**
  String get wordAudioStop;

  /// No description provided for @wordAudioPlay.
  ///
  /// In uk, this message translates to:
  /// **'Увімкнути вимову слова'**
  String get wordAudioPlay;

  /// No description provided for @wordAudioPlaybackFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося відтворити вимову слова.'**
  String get wordAudioPlaybackFailure;

  /// No description provided for @flashcardsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Картки'**
  String get flashcardsTitle;

  /// No description provided for @flashcardsDeckMode.
  ///
  /// In uk, this message translates to:
  /// **'Режим'**
  String get flashcardsDeckMode;

  /// No description provided for @flashcardsDeckAll.
  ///
  /// In uk, this message translates to:
  /// **'Усі'**
  String get flashcardsDeckAll;

  /// No description provided for @flashcardsDeckContexts.
  ///
  /// In uk, this message translates to:
  /// **'Контекст'**
  String get flashcardsDeckContexts;

  /// No description provided for @flashcardsDeckReview.
  ///
  /// In uk, this message translates to:
  /// **'Повторення'**
  String get flashcardsDeckReview;

  /// No description provided for @flashcardsEmptySubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Зараз тут порожньо. Оберіть інший режим або поверніться трохи пізніше.'**
  String get flashcardsEmptySubtitle;

  /// No description provided for @flashcardsEmptyAllTitle.
  ///
  /// In uk, this message translates to:
  /// **'Слова ще не завантажені.'**
  String get flashcardsEmptyAllTitle;

  /// No description provided for @flashcardsEmptyAllBody.
  ///
  /// In uk, this message translates to:
  /// **'Щойно слова з’являться, тут можна буде почати тренування.'**
  String get flashcardsEmptyAllBody;

  /// No description provided for @flashcardsEmptyContextsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Карток із прикладами поки немає.'**
  String get flashcardsEmptyContextsTitle;

  /// No description provided for @flashcardsEmptyContextsBody.
  ///
  /// In uk, this message translates to:
  /// **'Коли для слів з’являться приклади, цей режим стане доступним.'**
  String get flashcardsEmptyContextsBody;

  /// No description provided for @flashcardsEmptyReviewTitle.
  ///
  /// In uk, this message translates to:
  /// **'На повторенні поки порожньо.'**
  String get flashcardsEmptyReviewTitle;

  /// No description provided for @flashcardsEmptyReviewBody.
  ///
  /// In uk, this message translates to:
  /// **'Позначайте слова як «Ще раз», і вони з’являться тут окремо.'**
  String get flashcardsEmptyReviewBody;

  /// No description provided for @flashcardsCompletedSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Цю колоду вже пройдено. Можна почати ще раз або перейти далі.'**
  String get flashcardsCompletedSubtitle;

  /// No description provided for @flashcardsDone.
  ///
  /// In uk, this message translates to:
  /// **'Готово'**
  String get flashcardsDone;

  /// No description provided for @flashcardsCompletedTitle.
  ///
  /// In uk, this message translates to:
  /// **'{count} карток пройдено'**
  String flashcardsCompletedTitle(int count);

  /// No description provided for @flashcardsRepeat.
  ///
  /// In uk, this message translates to:
  /// **'Ще раз'**
  String get flashcardsRepeat;

  /// No description provided for @flashcardsRestart.
  ///
  /// In uk, this message translates to:
  /// **'Почати ще раз'**
  String get flashcardsRestart;

  /// No description provided for @flashcardsGoToReview.
  ///
  /// In uk, this message translates to:
  /// **'До повторення'**
  String get flashcardsGoToReview;

  /// No description provided for @flashcardsCompletionAllWithReview.
  ///
  /// In uk, this message translates to:
  /// **'На повторення чекають {count} карток.'**
  String flashcardsCompletionAllWithReview(int count);

  /// No description provided for @flashcardsCompletionAll.
  ///
  /// In uk, this message translates to:
  /// **'Усі слова з цієї колоди вже переглянуті.'**
  String get flashcardsCompletionAll;

  /// No description provided for @flashcardsCompletionContextsWithReview.
  ///
  /// In uk, this message translates to:
  /// **'Після цього проходу {count} карток перейшли на повторення.'**
  String flashcardsCompletionContextsWithReview(int count);

  /// No description provided for @flashcardsCompletionContexts.
  ///
  /// In uk, this message translates to:
  /// **'Усі картки з прикладами вже пройдені.'**
  String get flashcardsCompletionContexts;

  /// No description provided for @flashcardsCompletionReview.
  ///
  /// In uk, this message translates to:
  /// **'Ви вже все повторили.'**
  String get flashcardsCompletionReview;

  /// No description provided for @flashcardsContextEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Для цього слова ще немає прикладу в реченні.'**
  String get flashcardsContextEmpty;

  /// No description provided for @flashcardsContextTitle.
  ///
  /// In uk, this message translates to:
  /// **'Контекст'**
  String get flashcardsContextTitle;

  /// No description provided for @aiContextNew.
  ///
  /// In uk, this message translates to:
  /// **'Нове!'**
  String get aiContextNew;

  /// No description provided for @aiContext.
  ///
  /// In uk, this message translates to:
  /// **'ШІ'**
  String get aiContext;

  /// No description provided for @repetitionTitle.
  ///
  /// In uk, this message translates to:
  /// **'Повторення'**
  String get repetitionTitle;

  /// No description provided for @repetitionEmptySubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Коли з’являться нові слова або останні помилки, вони будуть тут.'**
  String get repetitionEmptySubtitle;

  /// No description provided for @repetitionCompletedSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Сесію завершено. Можна одразу пройти її ще раз.'**
  String get repetitionCompletedSubtitle;

  /// No description provided for @repetitionActiveSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Одне слово на екран, без таймера і без варіантів.'**
  String get repetitionActiveSubtitle;

  /// No description provided for @repetitionNext.
  ///
  /// In uk, this message translates to:
  /// **'Далі'**
  String get repetitionNext;

  /// No description provided for @repetitionFinish.
  ///
  /// In uk, this message translates to:
  /// **'Завершити'**
  String get repetitionFinish;

  /// No description provided for @repetitionEmptyTitle.
  ///
  /// In uk, this message translates to:
  /// **'Список повторення поки порожній.'**
  String get repetitionEmptyTitle;

  /// No description provided for @repetitionEmptyBody.
  ///
  /// In uk, this message translates to:
  /// **'Спочатку відкрийте нові слова або зробіть кілька спроб у практиці.'**
  String get repetitionEmptyBody;

  /// No description provided for @repetitionDone.
  ///
  /// In uk, this message translates to:
  /// **'Готово'**
  String get repetitionDone;

  /// No description provided for @repetitionCompletedTitle.
  ///
  /// In uk, this message translates to:
  /// **'{count} слів переглянуто'**
  String repetitionCompletedTitle(int count);

  /// No description provided for @repetitionAfterMistake.
  ///
  /// In uk, this message translates to:
  /// **'Після помилки'**
  String get repetitionAfterMistake;

  /// No description provided for @repetitionReinforcement.
  ///
  /// In uk, this message translates to:
  /// **'Закріплення пройденого'**
  String get repetitionReinforcement;

  /// No description provided for @repetitionRestart.
  ///
  /// In uk, this message translates to:
  /// **'Почати ще раз'**
  String get repetitionRestart;

  /// No description provided for @repetitionTranslation.
  ///
  /// In uk, this message translates to:
  /// **'Переклад'**
  String get repetitionTranslation;

  /// No description provided for @repetitionLastMistake.
  ///
  /// In uk, this message translates to:
  /// **'Остання спроба з помилкою'**
  String get repetitionLastMistake;

  /// No description provided for @repetitionReinforcementWord.
  ///
  /// In uk, this message translates to:
  /// **'Слово для закріплення'**
  String get repetitionReinforcementWord;

  /// No description provided for @repetitionContextEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Контекст для цього слова ще не додано.'**
  String get repetitionContextEmpty;

  /// No description provided for @repetitionContextTitle.
  ///
  /// In uk, this message translates to:
  /// **'Контекст'**
  String get repetitionContextTitle;

  /// No description provided for @writingTitle.
  ///
  /// In uk, this message translates to:
  /// **'Написання'**
  String get writingTitle;

  /// No description provided for @writingPromptTitle.
  ///
  /// In uk, this message translates to:
  /// **'Слово для перекладу'**
  String get writingPromptTitle;

  /// No description provided for @writingNoHints.
  ///
  /// In uk, this message translates to:
  /// **'Без підказок: спробуйте пригадати слово самостійно.'**
  String get writingNoHints;

  /// No description provided for @writingAnswerHint.
  ///
  /// In uk, this message translates to:
  /// **'Введіть слово івритом'**
  String get writingAnswerHint;

  /// No description provided for @writingFillAllTiles.
  ///
  /// In uk, this message translates to:
  /// **'Заповніть усі склади, а потім перевіряйте відповідь.'**
  String get writingFillAllTiles;

  /// No description provided for @writingEnterAnswer.
  ///
  /// In uk, this message translates to:
  /// **'Введіть слово івритом, щоб перевірити відповідь.'**
  String get writingEnterAnswer;

  /// No description provided for @writingBuildAnswer.
  ///
  /// In uk, this message translates to:
  /// **'Складіть слово з блоків, щоб перевірити відповідь.'**
  String get writingBuildAnswer;

  /// No description provided for @writingReadyToCheck.
  ///
  /// In uk, this message translates to:
  /// **'Натисніть «Перевірити», коли будете готові.'**
  String get writingReadyToCheck;

  /// No description provided for @writingCurrentSession.
  ///
  /// In uk, this message translates to:
  /// **'Поточна сесія'**
  String get writingCurrentSession;

  /// No description provided for @writingCheckedAnswers.
  ///
  /// In uk, this message translates to:
  /// **'Перевірено відповідей: {count}'**
  String writingCheckedAnswers(int count);

  /// No description provided for @writingAvailableWords.
  ///
  /// In uk, this message translates to:
  /// **'{count} слів доступні для письма на цьому пристрої'**
  String writingAvailableWords(int count);

  /// No description provided for @writingCorrect.
  ///
  /// In uk, this message translates to:
  /// **'Правильно'**
  String get writingCorrect;

  /// No description provided for @writingCorrectAnswer.
  ///
  /// In uk, this message translates to:
  /// **'Ось правильний варіант'**
  String get writingCorrectAnswer;

  /// No description provided for @writingCorrectBody.
  ///
  /// In uk, this message translates to:
  /// **'Слово записано правильно. Можна переходити далі.'**
  String get writingCorrectBody;

  /// No description provided for @writingIncorrectBody.
  ///
  /// In uk, this message translates to:
  /// **'Нічого страшного. Повернемось до цього слова пізніше.'**
  String get writingIncorrectBody;

  /// No description provided for @writingUnknown.
  ///
  /// In uk, this message translates to:
  /// **'Не знаю'**
  String get writingUnknown;

  /// No description provided for @writingCheck.
  ///
  /// In uk, this message translates to:
  /// **'Перевірити'**
  String get writingCheck;

  /// No description provided for @writingNext.
  ///
  /// In uk, this message translates to:
  /// **'Далі'**
  String get writingNext;

  /// No description provided for @writingEmptySubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Коли слова завантажаться, тут можна буде тренувати написання івритом або складати слова з блоків.'**
  String get writingEmptySubtitle;

  /// No description provided for @writingEmptyBody.
  ///
  /// In uk, this message translates to:
  /// **'Щойно у наборі з’являться доступні слова, тут можна буде тренувати письмо окремою сесією.'**
  String get writingEmptyBody;

  /// No description provided for @writingBuildWord.
  ///
  /// In uk, this message translates to:
  /// **'Складіть слово'**
  String get writingBuildWord;

  /// No description provided for @writingBuildWordSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Перетягніть блоки у правильному порядку. Натискання на блок теж працює.'**
  String get writingBuildWordSubtitle;

  /// No description provided for @writingAvailableTiles.
  ///
  /// In uk, this message translates to:
  /// **'Доступні блоки'**
  String get writingAvailableTiles;

  /// No description provided for @readingLevelBeginner.
  ///
  /// In uk, this message translates to:
  /// **'Початковий'**
  String get readingLevelBeginner;

  /// No description provided for @readingLevelPreIntermediate.
  ///
  /// In uk, this message translates to:
  /// **'Нижче середнього'**
  String get readingLevelPreIntermediate;

  /// No description provided for @readingLevelIntermediate.
  ///
  /// In uk, this message translates to:
  /// **'Середній'**
  String get readingLevelIntermediate;

  /// No description provided for @readingLevelUpperIntermediate.
  ///
  /// In uk, this message translates to:
  /// **'Вище середнього'**
  String get readingLevelUpperIntermediate;

  /// No description provided for @readingLevelAdvanced.
  ///
  /// In uk, this message translates to:
  /// **'Просунутий'**
  String get readingLevelAdvanced;

  /// No description provided for @readingLevelProficient.
  ///
  /// In uk, this message translates to:
  /// **'Вільний'**
  String get readingLevelProficient;

  /// No description provided for @readingLevelFallback.
  ///
  /// In uk, this message translates to:
  /// **'Читання'**
  String get readingLevelFallback;

  /// No description provided for @audioPlay.
  ///
  /// In uk, this message translates to:
  /// **'Озвучка'**
  String get audioPlay;

  /// No description provided for @featureNightModeTitle.
  ///
  /// In uk, this message translates to:
  /// **'Нічний режим'**
  String get featureNightModeTitle;

  /// No description provided for @featureAdvancedPracticeTitle.
  ///
  /// In uk, this message translates to:
  /// **'Розширена практика'**
  String get featureAdvancedPracticeTitle;

  /// No description provided for @featureExtraLessonsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Додаткові уроки'**
  String get featureExtraLessonsTitle;

  /// No description provided for @featureAiContextsTitle.
  ///
  /// In uk, this message translates to:
  /// **'ШІ-контексти слів'**
  String get featureAiContextsTitle;

  /// No description provided for @featureAiTextsTitle.
  ///
  /// In uk, this message translates to:
  /// **'ШІ-тексти для практики'**
  String get featureAiTextsTitle;

  /// No description provided for @featureNightModeDescription.
  ///
  /// In uk, this message translates to:
  /// **'Нічний режим доступний у Pro-версії.'**
  String get featureNightModeDescription;

  /// No description provided for @featureAdvancedPracticeDescription.
  ///
  /// In uk, this message translates to:
  /// **'Розширені режими практики доступні у Pro-версії.'**
  String get featureAdvancedPracticeDescription;

  /// No description provided for @featureExtraLessonsDescription.
  ///
  /// In uk, this message translates to:
  /// **'Додаткові набори уроків доступні у Pro-версії.'**
  String get featureExtraLessonsDescription;

  /// No description provided for @featureAiDescription.
  ///
  /// In uk, this message translates to:
  /// **'AI-функції готуються до запуску. Скоро з\'являться.'**
  String get featureAiDescription;

  /// No description provided for @featureUpgradePro.
  ///
  /// In uk, this message translates to:
  /// **'Перейти на Pro'**
  String get featureUpgradePro;

  /// No description provided for @audioVolumeMuted.
  ///
  /// In uk, this message translates to:
  /// **'Звук вимкнений. Підніміть гучність медіа кнопками збоку.'**
  String get audioVolumeMuted;

  /// No description provided for @guidePreviousTopic.
  ///
  /// In uk, this message translates to:
  /// **'Попередня тема'**
  String get guidePreviousTopic;

  /// No description provided for @guideNextTopic.
  ///
  /// In uk, this message translates to:
  /// **'Наступна тема'**
  String get guideNextTopic;

  /// No description provided for @guideNoTopic.
  ///
  /// In uk, this message translates to:
  /// **'Немає'**
  String get guideNoTopic;

  /// No description provided for @guideRelatedLoading.
  ///
  /// In uk, this message translates to:
  /// **'Підбираємо пов’язані теми для швидких переходів.'**
  String get guideRelatedLoading;

  /// No description provided for @guideRelatedTitle.
  ///
  /// In uk, this message translates to:
  /// **'Пов’язані теми'**
  String get guideRelatedTitle;

  /// No description provided for @guideRelatedEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Усі найближчі пов’язані теми вже є в навігації вище.'**
  String get guideRelatedEmpty;

  /// No description provided for @guideOutlineTitle.
  ///
  /// In uk, this message translates to:
  /// **'У цій статті'**
  String get guideOutlineTitle;

  /// No description provided for @themeLight.
  ///
  /// In uk, this message translates to:
  /// **'Світла'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In uk, this message translates to:
  /// **'Темна'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In uk, this message translates to:
  /// **'Системна'**
  String get themeSystem;

  /// No description provided for @shellGuideSaveFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося зберегти прогрес довідника. Спробуйте ще раз.'**
  String get shellGuideSaveFailure;

  /// No description provided for @shellReadingSaveFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося зберегти прогрес читання. Спробуйте ще раз.'**
  String get shellReadingSaveFailure;

  /// No description provided for @shellContextsLoadFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося завантажити контексти слів. Спробуйте ще раз.'**
  String get shellContextsLoadFailure;

  /// No description provided for @shellAiTextsDisabled.
  ///
  /// In uk, this message translates to:
  /// **'Увімкніть ШІ-тексти для практики в налаштуваннях.'**
  String get shellAiTextsDisabled;

  /// No description provided for @shellNoWordsForText.
  ///
  /// In uk, this message translates to:
  /// **'Поки немає слів для генерації тексту.'**
  String get shellNoWordsForText;

  /// No description provided for @shellWordSaveFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося зберегти прогрес слова. Спробуйте ще раз.'**
  String get shellWordSaveFailure;

  /// No description provided for @shellLoadingMaterials.
  ///
  /// In uk, this message translates to:
  /// **'Завантажуємо навчальні матеріали...'**
  String get shellLoadingMaterials;

  /// No description provided for @shellMaterialsLoadFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося завантажити навчальні матеріали.'**
  String get shellMaterialsLoadFailure;

  /// No description provided for @retry.
  ///
  /// In uk, this message translates to:
  /// **'Спробувати ще раз'**
  String get retry;

  /// No description provided for @readingTitle.
  ///
  /// In uk, this message translates to:
  /// **'Читання'**
  String get readingTitle;

  /// No description provided for @readingSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Тексти для читання, розкладені за рівнями.'**
  String get readingSubtitle;

  /// No description provided for @verbsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Дієслова'**
  String get verbsTitle;

  /// No description provided for @verbsSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Основні дієслова з поясненнями, вимовою та ілюстраціями.'**
  String get verbsSubtitle;

  /// No description provided for @verbsOpenSearch.
  ///
  /// In uk, this message translates to:
  /// **'Показати пошук'**
  String get verbsOpenSearch;

  /// No description provided for @verbsOpenFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося відкрити цей урок.'**
  String get verbsOpenFailure;

  /// No description provided for @verbsSearchHint.
  ///
  /// In uk, this message translates to:
  /// **'Шукайте за назвою уроку'**
  String get verbsSearchHint;

  /// No description provided for @verbsFound.
  ///
  /// In uk, this message translates to:
  /// **'Знайдено'**
  String get verbsFound;

  /// No description provided for @verbsLessons.
  ///
  /// In uk, this message translates to:
  /// **'Уроків'**
  String get verbsLessons;

  /// No description provided for @verbsTotal.
  ///
  /// In uk, this message translates to:
  /// **'Усього'**
  String get verbsTotal;

  /// No description provided for @verbsLoadingTitles.
  ///
  /// In uk, this message translates to:
  /// **'Оновлюємо назви'**
  String get verbsLoadingTitles;

  /// No description provided for @verbsEmptyTitle.
  ///
  /// In uk, this message translates to:
  /// **'Нічого не знайдено.'**
  String get verbsEmptyTitle;

  /// No description provided for @verbsEmptyBody.
  ///
  /// In uk, this message translates to:
  /// **'Спробуйте інший запит: назву дієслова або тему уроку.'**
  String get verbsEmptyBody;

  /// No description provided for @verbsAudioFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося відтворити вимову.'**
  String get verbsAudioFailure;

  /// No description provided for @verbsCheckingAudio.
  ///
  /// In uk, this message translates to:
  /// **'Перевіряємо аудіо'**
  String get verbsCheckingAudio;

  /// No description provided for @verbsStopAudio.
  ///
  /// In uk, this message translates to:
  /// **'Зупинити вимову'**
  String get verbsStopAudio;

  /// No description provided for @verbsPlayAudio.
  ///
  /// In uk, this message translates to:
  /// **'Увімкнути вимову'**
  String get verbsPlayAudio;

  /// No description provided for @verbsAudioUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Аудіо поки недоступне'**
  String get verbsAudioUnavailable;

  /// No description provided for @verbsImageUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Ілюстрацію для цього дієслова ще не додано.'**
  String get verbsImageUnavailable;

  /// No description provided for @sprintAvailableWords.
  ///
  /// In uk, this message translates to:
  /// **'Слів на вивченні для спринту: {count}'**
  String sprintAvailableWords(Object count);

  /// No description provided for @sprintCorrectAnswers.
  ///
  /// In uk, this message translates to:
  /// **'Правильних відповідей: {count}'**
  String sprintCorrectAnswers(Object count);

  /// No description provided for @sprintWrongAnswers.
  ///
  /// In uk, this message translates to:
  /// **'Неправильних відповідей: {count}'**
  String sprintWrongAnswers(Object count);

  /// No description provided for @guideTitle.
  ///
  /// In uk, this message translates to:
  /// **'Довідник'**
  String get guideTitle;

  /// No description provided for @guideSectionFilterTitle.
  ///
  /// In uk, this message translates to:
  /// **'Секція довідника'**
  String get guideSectionFilterTitle;

  /// No description provided for @guideSectionFilterBody.
  ///
  /// In uk, this message translates to:
  /// **'Можна лишити весь каталог або вибрати кілька секцій.'**
  String get guideSectionFilterBody;

  /// No description provided for @guideAllTopics.
  ///
  /// In uk, this message translates to:
  /// **'Усі теми'**
  String get guideAllTopics;

  /// No description provided for @guideOpenFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося відкрити цей урок.'**
  String get guideOpenFailure;

  /// No description provided for @guideSectionScript.
  ///
  /// In uk, this message translates to:
  /// **'Письмо і читання'**
  String get guideSectionScript;

  /// No description provided for @guideSectionFoundations.
  ///
  /// In uk, this message translates to:
  /// **'Базові моделі'**
  String get guideSectionFoundations;

  /// No description provided for @guideSectionVerbs.
  ///
  /// In uk, this message translates to:
  /// **'Дієслівна система'**
  String get guideSectionVerbs;

  /// No description provided for @guideSectionGrammar.
  ///
  /// In uk, this message translates to:
  /// **'Розширена граматика'**
  String get guideSectionGrammar;

  /// No description provided for @guideSectionCommunication.
  ///
  /// In uk, this message translates to:
  /// **'Живе спілкування'**
  String get guideSectionCommunication;

  /// No description provided for @guideSectionDiscourse.
  ///
  /// In uk, this message translates to:
  /// **'Аргументація і письмо'**
  String get guideSectionDiscourse;

  /// No description provided for @readingOpenFilter.
  ///
  /// In uk, this message translates to:
  /// **'Відкрити фільтр'**
  String get readingOpenFilter;

  /// No description provided for @readingChangeFilter.
  ///
  /// In uk, this message translates to:
  /// **'Змінити фільтр'**
  String get readingChangeFilter;

  /// No description provided for @readingLevelFilterTitle.
  ///
  /// In uk, this message translates to:
  /// **'Рівень читання'**
  String get readingLevelFilterTitle;

  /// No description provided for @readingLevelFilterBody.
  ///
  /// In uk, this message translates to:
  /// **'Можна лишити весь каталог або вибрати один рівень.'**
  String get readingLevelFilterBody;

  /// No description provided for @readingAllLevels.
  ///
  /// In uk, this message translates to:
  /// **'Усі рівні'**
  String get readingAllLevels;

  /// No description provided for @readingLevel.
  ///
  /// In uk, this message translates to:
  /// **'Рівень'**
  String get readingLevel;

  /// No description provided for @readingLessonsCount.
  ///
  /// In uk, this message translates to:
  /// **'{count} уроків'**
  String readingLessonsCount(Object count);

  /// No description provided for @catalogFound.
  ///
  /// In uk, this message translates to:
  /// **'Знайдено: {visible} із {total}'**
  String catalogFound(Object total, Object visible);

  /// No description provided for @catalogGuideCount.
  ///
  /// In uk, this message translates to:
  /// **'Тем: {count}'**
  String catalogGuideCount(Object count);

  /// No description provided for @catalogReadingCount.
  ///
  /// In uk, this message translates to:
  /// **'Уроків: {count}'**
  String catalogReadingCount(Object count);

  /// No description provided for @catalogReadCount.
  ///
  /// In uk, this message translates to:
  /// **'Прочитано {read} із {total} тем'**
  String catalogReadCount(Object read, Object total);

  /// No description provided for @catalogSection.
  ///
  /// In uk, this message translates to:
  /// **'Секція: {section} · Прочитано {read} із {total}'**
  String catalogSection(Object read, Object section, Object total);

  /// No description provided for @catalogSections.
  ///
  /// In uk, this message translates to:
  /// **'Секції: {count} · Прочитано {read} із {total}'**
  String catalogSections(Object count, Object read, Object total);

  /// No description provided for @catalogOpenSectionFilter.
  ///
  /// In uk, this message translates to:
  /// **'Відкрити фільтр секцій'**
  String get catalogOpenSectionFilter;

  /// No description provided for @catalogChangeSectionFilter.
  ///
  /// In uk, this message translates to:
  /// **'Змінити фільтр секцій'**
  String get catalogChangeSectionFilter;

  /// No description provided for @catalogHideSearch.
  ///
  /// In uk, this message translates to:
  /// **'Сховати пошук'**
  String get catalogHideSearch;

  /// No description provided for @catalogShowSearch.
  ///
  /// In uk, this message translates to:
  /// **'Показати пошук'**
  String get catalogShowSearch;

  /// No description provided for @catalogGuideSearchHint.
  ///
  /// In uk, this message translates to:
  /// **'Шукати тему в довіднику'**
  String get catalogGuideSearchHint;

  /// No description provided for @catalogReadingSearchHint.
  ///
  /// In uk, this message translates to:
  /// **'Шукати урок за назвою'**
  String get catalogReadingSearchHint;

  /// No description provided for @catalogLoadingGuideTitles.
  ///
  /// In uk, this message translates to:
  /// **'Підтягуємо короткі описи та заголовки для точнішого пошуку.'**
  String get catalogLoadingGuideTitles;

  /// No description provided for @catalogLoadingReadingTitles.
  ///
  /// In uk, this message translates to:
  /// **'Підтягуємо заголовки уроків для точнішого пошуку.'**
  String get catalogLoadingReadingTitles;

  /// No description provided for @catalogTopicsCount.
  ///
  /// In uk, this message translates to:
  /// **'{count} тем'**
  String catalogTopicsCount(Object count);

  /// No description provided for @catalogNothingFound.
  ///
  /// In uk, this message translates to:
  /// **'Нічого не знайдено.'**
  String get catalogNothingFound;

  /// No description provided for @catalogGuideEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Спробуйте інший запит або скиньте фільтр секції.'**
  String get catalogGuideEmpty;

  /// No description provided for @catalogReadingEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Спробуйте інший запит або скиньте фільтр рівня.'**
  String get catalogReadingEmpty;

  /// No description provided for @lessonStatusUnread.
  ///
  /// In uk, this message translates to:
  /// **'Не прочитано'**
  String get lessonStatusUnread;

  /// No description provided for @lessonStatusLearning.
  ///
  /// In uk, this message translates to:
  /// **'Вивчається'**
  String get lessonStatusLearning;

  /// No description provided for @lessonStatusRead.
  ///
  /// In uk, this message translates to:
  /// **'Прочитано'**
  String get lessonStatusRead;

  /// No description provided for @lessonStatusChange.
  ///
  /// In uk, this message translates to:
  /// **'Змінити статус уроку'**
  String get lessonStatusChange;

  /// No description provided for @aiTextTitle.
  ///
  /// In uk, this message translates to:
  /// **'Текст зі словами'**
  String get aiTextTitle;

  /// No description provided for @aiTextSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Короткий текст на івриті з поточними словами, перекладом і переходом до вправ.'**
  String get aiTextSubtitle;

  /// No description provided for @aiTextWords.
  ///
  /// In uk, this message translates to:
  /// **'Слова для тексту'**
  String get aiTextWords;

  /// No description provided for @aiTextFallbackTitle.
  ///
  /// In uk, this message translates to:
  /// **'Текст для практики'**
  String get aiTextFallbackTitle;

  /// No description provided for @aiTextInText.
  ///
  /// In uk, this message translates to:
  /// **'У тексті'**
  String get aiTextInText;

  /// No description provided for @aiTextFlashcards.
  ///
  /// In uk, this message translates to:
  /// **'Картки'**
  String get aiTextFlashcards;

  /// No description provided for @aiTextWriting.
  ///
  /// In uk, this message translates to:
  /// **'Написання'**
  String get aiTextWriting;

  /// No description provided for @aiTextRefresh.
  ///
  /// In uk, this message translates to:
  /// **'Оновити текст'**
  String get aiTextRefresh;

  /// No description provided for @aiTextNew.
  ///
  /// In uk, this message translates to:
  /// **'Нове!'**
  String get aiTextNew;

  /// No description provided for @aiTextNotGenerated.
  ///
  /// In uk, this message translates to:
  /// **'Текст ще не згенеровано'**
  String get aiTextNotGenerated;

  /// No description provided for @aiTextNotGeneratedBody.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося оновити текст. Спробуйте ще раз пізніше.'**
  String get aiTextNotGeneratedBody;

  /// No description provided for @aiTextRetry.
  ///
  /// In uk, this message translates to:
  /// **'Спробувати ще раз'**
  String get aiTextRetry;

  /// No description provided for @aiTextFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося отримати текст'**
  String get aiTextFailure;

  /// No description provided for @aiTextFailureBody.
  ///
  /// In uk, this message translates to:
  /// **'Збережена практика лишається доступною. Спробуйте ще раз.'**
  String get aiTextFailureBody;

  /// No description provided for @aiTextRepeat.
  ///
  /// In uk, this message translates to:
  /// **'Повторити'**
  String get aiTextRepeat;

  /// No description provided for @profileSystem.
  ///
  /// In uk, this message translates to:
  /// **'У системі'**
  String get profileSystem;

  /// No description provided for @profileProgress.
  ///
  /// In uk, this message translates to:
  /// **'Прогрес'**
  String get profileProgress;

  /// No description provided for @profileSettings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get profileSettings;

  /// No description provided for @profileWords.
  ///
  /// In uk, this message translates to:
  /// **'Слова'**
  String get profileWords;

  /// No description provided for @profileGuide.
  ///
  /// In uk, this message translates to:
  /// **'Довідник'**
  String get profileGuide;

  /// No description provided for @profileReading.
  ///
  /// In uk, this message translates to:
  /// **'Читання'**
  String get profileReading;

  /// No description provided for @profileVerbs.
  ///
  /// In uk, this message translates to:
  /// **'Дієслова'**
  String get profileVerbs;

  /// No description provided for @profileWordsOpened.
  ///
  /// In uk, this message translates to:
  /// **'Слова відкрито'**
  String get profileWordsOpened;

  /// No description provided for @profileWritingPracticed.
  ///
  /// In uk, this message translates to:
  /// **'Письмо відпрацьовано'**
  String get profileWritingPracticed;

  /// No description provided for @profileGuideCompleted.
  ///
  /// In uk, this message translates to:
  /// **'Довідник завершено'**
  String get profileGuideCompleted;

  /// No description provided for @profileReadingCompleted.
  ///
  /// In uk, this message translates to:
  /// **'Читання завершено'**
  String get profileReadingCompleted;

  /// No description provided for @profileKnownWords.
  ///
  /// In uk, this message translates to:
  /// **'Знайомі слова'**
  String get profileKnownWords;

  /// No description provided for @profileReview.
  ///
  /// In uk, this message translates to:
  /// **'Повторити'**
  String get profileReview;

  /// No description provided for @profileAutoHideNav.
  ///
  /// In uk, this message translates to:
  /// **'Автоматично ховати нижню панель'**
  String get profileAutoHideNav;

  /// No description provided for @profileAutoHideNavBody.
  ///
  /// In uk, this message translates to:
  /// **'Під час довгого перегляду сторінки вниз нижня панель тимчасово ховається, щоб звільнити більше місця на екрані.'**
  String get profileAutoHideNavBody;

  /// No description provided for @profileAiContexts.
  ///
  /// In uk, this message translates to:
  /// **'ШІ-контексти для вправ'**
  String get profileAiContexts;

  /// No description provided for @profileAiContextsBody.
  ///
  /// In uk, this message translates to:
  /// **'Приклади і ситуації з урахуванням ваших слів.'**
  String get profileAiContextsBody;

  /// No description provided for @profileAiTexts.
  ///
  /// In uk, this message translates to:
  /// **'ШІ-тексти для практики'**
  String get profileAiTexts;

  /// No description provided for @profileAiTextsBody.
  ///
  /// In uk, this message translates to:
  /// **'Короткі тексти під ваш рівень.'**
  String get profileAiTextsBody;

  /// No description provided for @profileTheme.
  ///
  /// In uk, this message translates to:
  /// **'Тема'**
  String get profileTheme;

  /// No description provided for @profileThemeBody.
  ///
  /// In uk, this message translates to:
  /// **'Перемикає світлу, темну та системну.'**
  String get profileThemeBody;

  /// No description provided for @sprintTitle.
  ///
  /// In uk, this message translates to:
  /// **'Спринт'**
  String get sprintTitle;

  /// No description provided for @sprintUnavailableTitle.
  ///
  /// In uk, this message translates to:
  /// **'Спринт поки недоступний'**
  String get sprintUnavailableTitle;

  /// No description provided for @sprintUnavailableBody.
  ///
  /// In uk, this message translates to:
  /// **'Для цієї вправи потрібно щонайменше два слова на вивченні з різними перекладами. Зараз доступно {count} слів.'**
  String sprintUnavailableBody(Object count);

  /// No description provided for @sprintIntroUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Хвилинна вправа з двома варіантами перекладу. Потрібно хоча б два слова на вивченні з різними перекладами.'**
  String get sprintIntroUnavailable;

  /// No description provided for @sprintIntro.
  ///
  /// In uk, this message translates to:
  /// **'За 60 секунд потрібно вибрати якомога більше правильних перекладів. Кожне слово на вивченні трапляється один раз.'**
  String get sprintIntro;

  /// No description provided for @sprintTimeStarted.
  ///
  /// In uk, this message translates to:
  /// **'Час пішов. Обирайте правильний переклад якомога швидше.'**
  String get sprintTimeStarted;

  /// No description provided for @sprintFirstPromptFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося підготувати перше завдання для спринту.'**
  String get sprintFirstPromptFailure;

  /// No description provided for @sprintStatsSaveFailure.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося зберегти статистику спринту.'**
  String get sprintStatsSaveFailure;

  /// No description provided for @sprintAnswerCorrect.
  ///
  /// In uk, this message translates to:
  /// **'Правильно: {translation}'**
  String sprintAnswerCorrect(Object translation);

  /// No description provided for @sprintAnswerWrong.
  ///
  /// In uk, this message translates to:
  /// **'Неправильно. Правильна відповідь: {translation}'**
  String sprintAnswerWrong(Object translation);

  /// No description provided for @sprintEarlyCompletion.
  ///
  /// In uk, this message translates to:
  /// **'Усі слова на вивченні пройдено. Спринт завершено достроково, гарний темп.'**
  String get sprintEarlyCompletion;

  /// No description provided for @sprintCompleted.
  ///
  /// In uk, this message translates to:
  /// **'Спринт завершено. Можна одразу почати нову хвилину.'**
  String get sprintCompleted;

  /// No description provided for @sprintSession.
  ///
  /// In uk, this message translates to:
  /// **'Поточна сесія'**
  String get sprintSession;

  /// No description provided for @sprintLoadingStats.
  ///
  /// In uk, this message translates to:
  /// **'Статистика спринту завантажується...'**
  String get sprintLoadingStats;

  /// No description provided for @sprintNoStats.
  ///
  /// In uk, this message translates to:
  /// **'Рекорд і середній результат зʼявляться після першого завершеного спринту.'**
  String get sprintNoStats;

  /// No description provided for @sprintBest.
  ///
  /// In uk, this message translates to:
  /// **'Найкращий результат: {count} вірних відповідей'**
  String sprintBest(Object count);

  /// No description provided for @sprintAverage.
  ///
  /// In uk, this message translates to:
  /// **'Середній результат: {count} вірних відповідей'**
  String sprintAverage(Object count);

  /// No description provided for @sprintAttempts.
  ///
  /// In uk, this message translates to:
  /// **'{count} відповідей'**
  String sprintAttempts(Object count);

  /// No description provided for @sprintRestart.
  ///
  /// In uk, this message translates to:
  /// **'Почати спочатку'**
  String get sprintRestart;

  /// No description provided for @sprintChoose.
  ///
  /// In uk, this message translates to:
  /// **'Оберіть правильний переклад'**
  String get sprintChoose;

  /// No description provided for @sprintAwaitingAnswer.
  ///
  /// In uk, this message translates to:
  /// **'Після відповіді тут одразу з’явиться короткий результат.'**
  String get sprintAwaitingAnswer;

  /// No description provided for @sprintCorrect.
  ///
  /// In uk, this message translates to:
  /// **'Правильно'**
  String get sprintCorrect;

  /// No description provided for @sprintMistakes.
  ///
  /// In uk, this message translates to:
  /// **'Помилки'**
  String get sprintMistakes;

  /// No description provided for @sprintTimeUp.
  ///
  /// In uk, this message translates to:
  /// **'Час вийшов'**
  String get sprintTimeUp;

  /// No description provided for @sprintCorrectCount.
  ///
  /// In uk, this message translates to:
  /// **'{count} вірних відповідей'**
  String sprintCorrectCount(Object count);

  /// No description provided for @sprintTotal.
  ///
  /// In uk, this message translates to:
  /// **'Всього'**
  String get sprintTotal;

  /// No description provided for @sprintRecord.
  ///
  /// In uk, this message translates to:
  /// **'Рекорд'**
  String get sprintRecord;

  /// No description provided for @sprintStartAgain.
  ///
  /// In uk, this message translates to:
  /// **'Почати ще раз'**
  String get sprintStartAgain;

  /// No description provided for @sprintFirstRecord.
  ///
  /// In uk, this message translates to:
  /// **'Перший рекорд'**
  String get sprintFirstRecord;

  /// No description provided for @sprintNewRecord.
  ///
  /// In uk, this message translates to:
  /// **'Новий рекорд'**
  String get sprintNewRecord;

  /// No description provided for @sprintRecordMatched.
  ///
  /// In uk, this message translates to:
  /// **'Рекорд досягнуто'**
  String get sprintRecordMatched;

  /// No description provided for @sprintAboveAverage.
  ///
  /// In uk, this message translates to:
  /// **'Це на {count} вище вашого середнього.'**
  String sprintAboveAverage(Object count);

  /// No description provided for @sprintFirstRecordBody.
  ///
  /// In uk, this message translates to:
  /// **'Перший рекорд: {count} вірних відповідей.'**
  String sprintFirstRecordBody(Object count);

  /// No description provided for @sprintNewRecordBody.
  ///
  /// In uk, this message translates to:
  /// **'Ви побили рекорд: {count} вірних відповідей. Попередній був {previous}.'**
  String sprintNewRecordBody(Object count, Object previous);

  /// No description provided for @sprintRecordMatchedBody.
  ///
  /// In uk, this message translates to:
  /// **'Ви досягли свого рекорду: {count} вірних відповідей.'**
  String sprintRecordMatchedBody(Object count);
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
