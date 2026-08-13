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

  @override
  String get navHome => 'Головна';

  @override
  String get navLearn => 'Вчитись';

  @override
  String get navPractice => 'Практика';

  @override
  String get navProfile => 'Профіль';

  @override
  String get learnWorkspaceSubtitle => 'Оберіть, з чого продовжити навчання.';

  @override
  String get workspaceWordsTitle => 'Слова';

  @override
  String get workspaceWordsSubtitle =>
      'Словник з пошуком, фільтрами й прогресом.';

  @override
  String get workspaceVerbsTitle => 'Дієслова';

  @override
  String get workspaceVerbsSubtitle => 'Уроки з поясненнями та озвученням.';

  @override
  String get workspaceGuideTitle => 'Довідник';

  @override
  String get workspaceGuideSubtitle => 'Граматика з поясненнями та прикладами.';

  @override
  String get workspaceReadingTitle => 'Читання';

  @override
  String get workspaceReadingSubtitle => 'Тексти за рівнями складності.';

  @override
  String get practiceWorkspaceSubtitle =>
      'Оберіть формат тренування і відкрийте його окремим повноекранним сеансом.';

  @override
  String get workspaceReviewTitle => 'Повторення';

  @override
  String get workspaceReviewSubtitle =>
      'Нові слова й останні помилки для спокійного повторення.';

  @override
  String get workspaceFlashcardsTitle => 'Картки';

  @override
  String get workspaceFlashcardsSubtitle =>
      'Швидке повторення перекладу, контексту і наборів на повторення.';

  @override
  String get workspaceWritingTitle => 'Написання';

  @override
  String get workspaceWritingSubtitle => 'Написання слів івритом без підказок.';

  @override
  String get workspaceConstructorTitle => 'Конструктор';

  @override
  String get workspaceConstructorSubtitle =>
      'Складання слова з блоків у правильному порядку.';

  @override
  String get workspaceSprintTitle => 'Спринт';

  @override
  String get workspaceSprintSubtitle =>
      'Хвилинний режим на швидкість: для кожного слова є два варіанти перекладу.';

  @override
  String get workspaceAiTextTitle => 'Текст зі словами';

  @override
  String get workspaceAiTextSubtitle =>
      'Короткий ШІ-текст з вашими словами, перекладом і швидким переходом до практики.';

  @override
  String get wordOfDay => 'Слово дня';

  @override
  String get wordOfDayAudioChecking => 'Перевіряємо озвучку';

  @override
  String get wordOfDayAudioStop => 'Зупинити озвучку';

  @override
  String get wordOfDayAudioPlay => 'Увімкнути озвучку';

  @override
  String get wordOfDayAudioUnavailable => 'Озвучка ще недоступна';

  @override
  String get wordOfDayAudioFailure => 'Не вдалося відтворити озвучку слова.';

  @override
  String get wordOfDayEmpty =>
      'Слова з’являться після завантаження навчальної бази.';

  @override
  String get homeActionFirstStep => 'Перший крок';

  @override
  String get homeActionToday => 'Сьогодні';

  @override
  String get homeActionWelcomeTitle => 'Привіт! Готовий почати?';

  @override
  String get homeActionWelcomeSubtitle =>
      'Відкрий перші картки, щоб познайомитись зі словами івриту й заробити перший день у серії.';

  @override
  String get homeActionTry => 'Спробувати';

  @override
  String get homeActionReviewTitle => 'Продовжити повторення';

  @override
  String homeActionReviewSubtitle(int count) {
    return '$count слів чекають у картках на повторення.';
  }

  @override
  String get homeActionGoToReview => 'До повторення';

  @override
  String get homeActionNewWordsTitle => 'Готовий до нового?';

  @override
  String homeActionNewWordsSubtitle(int count) {
    return '$count слів ще чекають свого першого знайомства.';
  }

  @override
  String get homeActionGoToNewWords => 'До нових слів';

  @override
  String get homeActionReadingTitle => 'Усе повторено — почитаємо?';

  @override
  String get homeActionReadingSubtitle =>
      'У бібліотеці чекають тексти, з якими можна підняти рівень.';

  @override
  String get homeActionGoToReading => 'До читання';

  @override
  String get homeActionFallbackTitle => 'Заглянь у словник';

  @override
  String get homeActionFallbackSubtitle =>
      'Перегляньте слова, щоб обрати наступний напрям навчання.';

  @override
  String get homeActionGoToWords => 'До слів';

  @override
  String get wordsTitle => 'Слова';

  @override
  String get wordsSubtitle =>
      'Шукайте українською, англійською, івритом або за транскрипцією.';

  @override
  String get wordsSearchHint => 'Шукати слова';

  @override
  String get wordsFilterAll => 'Усі';

  @override
  String get wordsFilterNew => 'Нові';

  @override
  String get wordsFilterLearned => 'Вивчені';

  @override
  String get wordsFilterReview => 'Повторити';

  @override
  String get wordsVisible => 'Видимі';

  @override
  String get wordsTotal => 'Усього';

  @override
  String get wordsSearchTooltip => 'Пошук по словнику';

  @override
  String get wordsNoResultsTitle => 'Нічого не знайдено';

  @override
  String get wordsNoResultsAll =>
      'Спробуйте інший запит: слово українською чи англійською, форму івритом або транскрипцію.';

  @override
  String wordsNoResultsFilter(String filter) {
    return 'У поточному зрізі «$filter» поки немає результатів. Спробуйте інший фільтр або запит.';
  }

  @override
  String get wordOpenTooltip => 'Відкрити слово';

  @override
  String get wordChangeStatusTooltip => 'Змінити статус слова';

  @override
  String get wordStatusUnknown => 'Не знаю';

  @override
  String get wordStatusLearning => 'Вчу';

  @override
  String get wordStatusKnown => 'Знаю';

  @override
  String get wordStatCorrect => 'Правильно';

  @override
  String get wordStatMistakes => 'Помилки';

  @override
  String get wordContexts => 'Контексти';

  @override
  String get wordContextLoading => 'Шукаємо новий контекст...';

  @override
  String get wordContextEmpty => 'Для цього слова ще немає контексту.';

  @override
  String get wordAudioChecking => 'Перевіряємо аудіо слова';

  @override
  String get wordAudioUnavailable => 'Аудіо для слова ще недоступне';

  @override
  String get wordAudioStop => 'Зупинити вимову слова';

  @override
  String get wordAudioPlay => 'Увімкнути вимову слова';

  @override
  String get wordAudioPlaybackFailure => 'Не вдалося відтворити вимову слова.';

  @override
  String get flashcardsTitle => 'Картки';

  @override
  String get flashcardsDeckMode => 'Режим';

  @override
  String get flashcardsDeckAll => 'Усі';

  @override
  String get flashcardsDeckContexts => 'Контекст';

  @override
  String get flashcardsDeckReview => 'Повторення';

  @override
  String get flashcardsEmptySubtitle =>
      'Зараз тут порожньо. Оберіть інший режим або поверніться трохи пізніше.';

  @override
  String get flashcardsEmptyAllTitle => 'Слова ще не завантажені.';

  @override
  String get flashcardsEmptyAllBody =>
      'Щойно слова з’являться, тут можна буде почати тренування.';

  @override
  String get flashcardsEmptyContextsTitle => 'Карток із прикладами поки немає.';

  @override
  String get flashcardsEmptyContextsBody =>
      'Коли для слів з’являться приклади, цей режим стане доступним.';

  @override
  String get flashcardsEmptyReviewTitle => 'На повторенні поки порожньо.';

  @override
  String get flashcardsEmptyReviewBody =>
      'Позначайте слова як «Ще раз», і вони з’являться тут окремо.';

  @override
  String get flashcardsCompletedSubtitle =>
      'Цю колоду вже пройдено. Можна почати ще раз або перейти далі.';

  @override
  String get flashcardsDone => 'Готово';

  @override
  String flashcardsCompletedTitle(int count) {
    return '$count карток пройдено';
  }

  @override
  String get flashcardsRepeat => 'Ще раз';

  @override
  String get flashcardsRestart => 'Почати ще раз';

  @override
  String get flashcardsGoToReview => 'До повторення';

  @override
  String flashcardsCompletionAllWithReview(int count) {
    return 'На повторення чекають $count карток.';
  }

  @override
  String get flashcardsCompletionAll =>
      'Усі слова з цієї колоди вже переглянуті.';

  @override
  String flashcardsCompletionContextsWithReview(int count) {
    return 'Після цього проходу $count карток перейшли на повторення.';
  }

  @override
  String get flashcardsCompletionContexts =>
      'Усі картки з прикладами вже пройдені.';

  @override
  String get flashcardsCompletionReview => 'Ви вже все повторили.';

  @override
  String get flashcardsContextEmpty =>
      'Для цього слова ще немає прикладу в реченні.';

  @override
  String get flashcardsContextTitle => 'Контекст';

  @override
  String get aiContextNew => 'Нове!';

  @override
  String get aiContext => 'ШІ';

  @override
  String get repetitionTitle => 'Повторення';

  @override
  String get repetitionEmptySubtitle =>
      'Коли з’являться нові слова або останні помилки, вони будуть тут.';

  @override
  String get repetitionCompletedSubtitle =>
      'Сесію завершено. Можна одразу пройти її ще раз.';

  @override
  String get repetitionActiveSubtitle =>
      'Одне слово на екран, без таймера і без варіантів.';

  @override
  String get repetitionNext => 'Далі';

  @override
  String get repetitionFinish => 'Завершити';

  @override
  String get repetitionEmptyTitle => 'Список повторення поки порожній.';

  @override
  String get repetitionEmptyBody =>
      'Спочатку відкрийте нові слова або зробіть кілька спроб у практиці.';

  @override
  String get repetitionDone => 'Готово';

  @override
  String repetitionCompletedTitle(int count) {
    return '$count слів переглянуто';
  }

  @override
  String get repetitionAfterMistake => 'Після помилки';

  @override
  String get repetitionReinforcement => 'Закріплення пройденого';

  @override
  String get repetitionRestart => 'Почати ще раз';

  @override
  String get repetitionTranslation => 'Переклад';

  @override
  String get repetitionLastMistake => 'Остання спроба з помилкою';

  @override
  String get repetitionReinforcementWord => 'Слово для закріплення';

  @override
  String get repetitionContextEmpty => 'Контекст для цього слова ще не додано.';

  @override
  String get repetitionContextTitle => 'Контекст';

  @override
  String get writingTitle => 'Написання';

  @override
  String get writingPromptTitle => 'Слово для перекладу';

  @override
  String get writingNoHints =>
      'Без підказок: спробуйте пригадати слово самостійно.';

  @override
  String get writingAnswerHint => 'Введіть слово івритом';

  @override
  String get writingFillAllTiles =>
      'Заповніть усі склади, а потім перевіряйте відповідь.';

  @override
  String get writingEnterAnswer =>
      'Введіть слово івритом, щоб перевірити відповідь.';

  @override
  String get writingBuildAnswer =>
      'Складіть слово з блоків, щоб перевірити відповідь.';

  @override
  String get writingReadyToCheck =>
      'Натисніть «Перевірити», коли будете готові.';

  @override
  String get writingCurrentSession => 'Поточна сесія';

  @override
  String writingCheckedAnswers(int count) {
    return 'Перевірено відповідей: $count';
  }

  @override
  String writingAvailableWords(int count) {
    return '$count слів доступні для письма на цьому пристрої';
  }

  @override
  String get writingCorrect => 'Правильно';

  @override
  String get writingCorrectAnswer => 'Ось правильний варіант';

  @override
  String get writingCorrectBody =>
      'Слово записано правильно. Можна переходити далі.';

  @override
  String get writingIncorrectBody =>
      'Нічого страшного. Повернемось до цього слова пізніше.';

  @override
  String get writingUnknown => 'Не знаю';

  @override
  String get writingCheck => 'Перевірити';

  @override
  String get writingNext => 'Далі';

  @override
  String get writingEmptySubtitle =>
      'Коли слова завантажаться, тут можна буде тренувати написання івритом або складати слова з блоків.';

  @override
  String get writingEmptyBody =>
      'Щойно у наборі з’являться доступні слова, тут можна буде тренувати письмо окремою сесією.';

  @override
  String get writingBuildWord => 'Складіть слово';

  @override
  String get writingBuildWordSubtitle =>
      'Перетягніть блоки у правильному порядку. Натискання на блок теж працює.';

  @override
  String get writingAvailableTiles => 'Доступні блоки';

  @override
  String get readingLevelBeginner => 'Початковий';

  @override
  String get readingLevelPreIntermediate => 'Нижче середнього';

  @override
  String get readingLevelIntermediate => 'Середній';

  @override
  String get readingLevelUpperIntermediate => 'Вище середнього';

  @override
  String get readingLevelAdvanced => 'Просунутий';

  @override
  String get readingLevelProficient => 'Вільний';

  @override
  String get readingLevelFallback => 'Читання';

  @override
  String get audioPlay => 'Озвучка';

  @override
  String get featureNightModeTitle => 'Нічний режим';

  @override
  String get featureAdvancedPracticeTitle => 'Розширена практика';

  @override
  String get featureExtraLessonsTitle => 'Додаткові уроки';

  @override
  String get featureAiContextsTitle => 'ШІ-контексти слів';

  @override
  String get featureAiTextsTitle => 'ШІ-тексти для практики';

  @override
  String get featureNightModeDescription =>
      'Нічний режим доступний у Pro-версії.';

  @override
  String get featureAdvancedPracticeDescription =>
      'Розширені режими практики доступні у Pro-версії.';

  @override
  String get featureExtraLessonsDescription =>
      'Додаткові набори уроків доступні у Pro-версії.';

  @override
  String get featureAiDescription =>
      'AI-функції готуються до запуску. Скоро з\'являться.';

  @override
  String get featureUpgradePro => 'Перейти на Pro';

  @override
  String get audioVolumeMuted =>
      'Звук вимкнений. Підніміть гучність медіа кнопками збоку.';

  @override
  String get guidePreviousTopic => 'Попередня тема';

  @override
  String get guideNextTopic => 'Наступна тема';

  @override
  String get guideNoTopic => 'Немає';

  @override
  String get guideRelatedLoading =>
      'Підбираємо пов’язані теми для швидких переходів.';

  @override
  String get guideRelatedTitle => 'Пов’язані теми';

  @override
  String get guideRelatedEmpty =>
      'Усі найближчі пов’язані теми вже є в навігації вище.';

  @override
  String get guideOutlineTitle => 'У цій статті';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get themeSystem => 'Системна';

  @override
  String get shellGuideSaveFailure =>
      'Не вдалося зберегти прогрес довідника. Спробуйте ще раз.';

  @override
  String get shellReadingSaveFailure =>
      'Не вдалося зберегти прогрес читання. Спробуйте ще раз.';

  @override
  String get shellContextsLoadFailure =>
      'Не вдалося завантажити контексти слів. Спробуйте ще раз.';

  @override
  String get shellAiTextsDisabled =>
      'Увімкніть ШІ-тексти для практики в налаштуваннях.';

  @override
  String get shellNoWordsForText => 'Поки немає слів для генерації тексту.';

  @override
  String get shellWordSaveFailure =>
      'Не вдалося зберегти прогрес слова. Спробуйте ще раз.';

  @override
  String get shellLoadingMaterials => 'Завантажуємо навчальні матеріали...';

  @override
  String get shellMaterialsLoadFailure =>
      'Не вдалося завантажити навчальні матеріали.';

  @override
  String get retry => 'Спробувати ще раз';

  @override
  String get readingTitle => 'Читання';

  @override
  String get readingSubtitle => 'Тексти для читання, розкладені за рівнями.';

  @override
  String get verbsTitle => 'Дієслова';

  @override
  String get verbsSubtitle =>
      'Основні дієслова з поясненнями, вимовою та ілюстраціями.';

  @override
  String get verbsOpenSearch => 'Показати пошук';

  @override
  String get verbsOpenFailure => 'Не вдалося відкрити цей урок.';

  @override
  String get verbsSearchHint => 'Шукайте за назвою уроку';

  @override
  String get verbsFound => 'Знайдено';

  @override
  String get verbsLessons => 'Уроків';

  @override
  String get verbsTotal => 'Усього';

  @override
  String get verbsLoadingTitles => 'Оновлюємо назви';

  @override
  String get verbsEmptyTitle => 'Нічого не знайдено.';

  @override
  String get verbsEmptyBody =>
      'Спробуйте інший запит: назву дієслова або тему уроку.';

  @override
  String get verbsAudioFailure => 'Не вдалося відтворити вимову.';

  @override
  String get verbsCheckingAudio => 'Перевіряємо аудіо';

  @override
  String get verbsStopAudio => 'Зупинити вимову';

  @override
  String get verbsPlayAudio => 'Увімкнути вимову';

  @override
  String get verbsAudioUnavailable => 'Аудіо поки недоступне';

  @override
  String get verbsImageUnavailable =>
      'Ілюстрацію для цього дієслова ще не додано.';

  @override
  String sprintAvailableWords(Object count) {
    return 'Слів на вивченні для спринту: $count';
  }

  @override
  String sprintCorrectAnswers(Object count) {
    return 'Правильних відповідей: $count';
  }

  @override
  String sprintWrongAnswers(Object count) {
    return 'Неправильних відповідей: $count';
  }

  @override
  String get guideTitle => 'Довідник';

  @override
  String get guideSectionFilterTitle => 'Секція довідника';

  @override
  String get guideSectionFilterBody =>
      'Можна лишити весь каталог або вибрати кілька секцій.';

  @override
  String get guideAllTopics => 'Усі теми';

  @override
  String get guideOpenFailure => 'Не вдалося відкрити цей урок.';

  @override
  String get guideSectionScript => 'Письмо і читання';

  @override
  String get guideSectionFoundations => 'Базові моделі';

  @override
  String get guideSectionVerbs => 'Дієслівна система';

  @override
  String get guideSectionGrammar => 'Розширена граматика';

  @override
  String get guideSectionCommunication => 'Живе спілкування';

  @override
  String get guideSectionDiscourse => 'Аргументація і письмо';

  @override
  String get readingOpenFilter => 'Відкрити фільтр';

  @override
  String get readingChangeFilter => 'Змінити фільтр';

  @override
  String get readingLevelFilterTitle => 'Рівень читання';

  @override
  String get readingLevelFilterBody =>
      'Можна лишити весь каталог або вибрати один рівень.';

  @override
  String get readingAllLevels => 'Усі рівні';

  @override
  String get readingLevel => 'Рівень';

  @override
  String readingLessonsCount(Object count) {
    return '$count уроків';
  }

  @override
  String catalogFound(Object total, Object visible) {
    return 'Знайдено: $visible із $total';
  }

  @override
  String catalogGuideCount(Object count) {
    return 'Тем: $count';
  }

  @override
  String catalogReadingCount(Object count) {
    return 'Уроків: $count';
  }

  @override
  String catalogReadCount(Object read, Object total) {
    return 'Прочитано $read із $total тем';
  }

  @override
  String catalogSection(Object read, Object section, Object total) {
    return 'Секція: $section · Прочитано $read із $total';
  }

  @override
  String catalogSections(Object count, Object read, Object total) {
    return 'Секції: $count · Прочитано $read із $total';
  }

  @override
  String get catalogOpenSectionFilter => 'Відкрити фільтр секцій';

  @override
  String get catalogChangeSectionFilter => 'Змінити фільтр секцій';

  @override
  String get catalogHideSearch => 'Сховати пошук';

  @override
  String get catalogShowSearch => 'Показати пошук';

  @override
  String get catalogGuideSearchHint => 'Шукати тему в довіднику';

  @override
  String get catalogReadingSearchHint => 'Шукати урок за назвою';

  @override
  String get catalogLoadingGuideTitles =>
      'Підтягуємо короткі описи та заголовки для точнішого пошуку.';

  @override
  String get catalogLoadingReadingTitles =>
      'Підтягуємо заголовки уроків для точнішого пошуку.';

  @override
  String catalogTopicsCount(Object count) {
    return '$count тем';
  }

  @override
  String get catalogNothingFound => 'Нічого не знайдено.';

  @override
  String get catalogGuideEmpty =>
      'Спробуйте інший запит або скиньте фільтр секції.';

  @override
  String get catalogReadingEmpty =>
      'Спробуйте інший запит або скиньте фільтр рівня.';

  @override
  String get lessonStatusUnread => 'Не прочитано';

  @override
  String get lessonStatusLearning => 'Вивчається';

  @override
  String get lessonStatusRead => 'Прочитано';

  @override
  String get lessonStatusChange => 'Змінити статус уроку';

  @override
  String get aiTextTitle => 'Текст зі словами';

  @override
  String get aiTextSubtitle =>
      'Короткий текст на івриті з поточними словами, перекладом і переходом до вправ.';

  @override
  String get aiTextWords => 'Слова для тексту';

  @override
  String get aiTextFallbackTitle => 'Текст для практики';

  @override
  String get aiTextInText => 'У тексті';

  @override
  String get aiTextFlashcards => 'Картки';

  @override
  String get aiTextWriting => 'Написання';

  @override
  String get aiTextRefresh => 'Оновити текст';

  @override
  String get aiTextNew => 'Нове!';

  @override
  String get aiTextNotGenerated => 'Текст ще не згенеровано';

  @override
  String get aiTextNotGeneratedBody =>
      'Не вдалося оновити текст. Спробуйте ще раз пізніше.';

  @override
  String get aiTextRetry => 'Спробувати ще раз';

  @override
  String get aiTextFailure => 'Не вдалося отримати текст';

  @override
  String get aiTextFailureBody =>
      'Збережена практика лишається доступною. Спробуйте ще раз.';

  @override
  String get aiTextRepeat => 'Повторити';

  @override
  String get profileSystem => 'У системі';

  @override
  String get profileProgress => 'Прогрес';

  @override
  String get profileSettings => 'Налаштування';

  @override
  String get profileWords => 'Слова';

  @override
  String get profileGuide => 'Довідник';

  @override
  String get profileReading => 'Читання';

  @override
  String get profileVerbs => 'Дієслова';

  @override
  String get profileWordsOpened => 'Слова відкрито';

  @override
  String get profileWritingPracticed => 'Письмо відпрацьовано';

  @override
  String get profileGuideCompleted => 'Довідник завершено';

  @override
  String get profileReadingCompleted => 'Читання завершено';

  @override
  String get profileKnownWords => 'Знайомі слова';

  @override
  String get profileReview => 'Повторити';

  @override
  String get profileAutoHideNav => 'Автоматично ховати нижню панель';

  @override
  String get profileAutoHideNavBody =>
      'Під час довгого перегляду сторінки вниз нижня панель тимчасово ховається, щоб звільнити більше місця на екрані.';

  @override
  String get profileAiContexts => 'ШІ-контексти для вправ';

  @override
  String get profileAiContextsBody =>
      'Приклади і ситуації з урахуванням ваших слів.';

  @override
  String get profileAiTexts => 'ШІ-тексти для практики';

  @override
  String get profileAiTextsBody => 'Короткі тексти під ваш рівень.';

  @override
  String get profileTheme => 'Тема';

  @override
  String get profileThemeBody => 'Перемикає світлу, темну та системну.';

  @override
  String get sprintTitle => 'Спринт';

  @override
  String get sprintUnavailableTitle => 'Спринт поки недоступний';

  @override
  String sprintUnavailableBody(Object count) {
    return 'Для цієї вправи потрібно щонайменше два слова на вивченні з різними перекладами. Зараз доступно $count слів.';
  }

  @override
  String get sprintIntroUnavailable =>
      'Хвилинна вправа з двома варіантами перекладу. Потрібно хоча б два слова на вивченні з різними перекладами.';

  @override
  String get sprintIntro =>
      'За 60 секунд потрібно вибрати якомога більше правильних перекладів. Кожне слово на вивченні трапляється один раз.';

  @override
  String get sprintTimeStarted =>
      'Час пішов. Обирайте правильний переклад якомога швидше.';

  @override
  String get sprintFirstPromptFailure =>
      'Не вдалося підготувати перше завдання для спринту.';

  @override
  String get sprintStatsSaveFailure =>
      'Не вдалося зберегти статистику спринту.';

  @override
  String sprintAnswerCorrect(Object translation) {
    return 'Правильно: $translation';
  }

  @override
  String sprintAnswerWrong(Object translation) {
    return 'Неправильно. Правильна відповідь: $translation';
  }

  @override
  String get sprintEarlyCompletion =>
      'Усі слова на вивченні пройдено. Спринт завершено достроково, гарний темп.';

  @override
  String get sprintCompleted =>
      'Спринт завершено. Можна одразу почати нову хвилину.';

  @override
  String get sprintSession => 'Поточна сесія';

  @override
  String get sprintLoadingStats => 'Статистика спринту завантажується...';

  @override
  String get sprintNoStats =>
      'Рекорд і середній результат зʼявляться після першого завершеного спринту.';

  @override
  String sprintBest(Object count) {
    return 'Найкращий результат: $count вірних відповідей';
  }

  @override
  String sprintAverage(Object count) {
    return 'Середній результат: $count вірних відповідей';
  }

  @override
  String sprintAttempts(Object count) {
    return '$count відповідей';
  }

  @override
  String get sprintRestart => 'Почати спочатку';

  @override
  String get sprintChoose => 'Оберіть правильний переклад';

  @override
  String get sprintAwaitingAnswer =>
      'Після відповіді тут одразу з’явиться короткий результат.';

  @override
  String get sprintCorrect => 'Правильно';

  @override
  String get sprintMistakes => 'Помилки';

  @override
  String get sprintTimeUp => 'Час вийшов';

  @override
  String sprintCorrectCount(Object count) {
    return '$count вірних відповідей';
  }

  @override
  String get sprintTotal => 'Всього';

  @override
  String get sprintRecord => 'Рекорд';

  @override
  String get sprintStartAgain => 'Почати ще раз';

  @override
  String get sprintFirstRecord => 'Перший рекорд';

  @override
  String get sprintNewRecord => 'Новий рекорд';

  @override
  String get sprintRecordMatched => 'Рекорд досягнуто';

  @override
  String sprintAboveAverage(Object count) {
    return 'Це на $count вище вашого середнього.';
  }

  @override
  String sprintFirstRecordBody(Object count) {
    return 'Перший рекорд: $count вірних відповідей.';
  }

  @override
  String sprintNewRecordBody(Object count, Object previous) {
    return 'Ви побили рекорд: $count вірних відповідей. Попередній був $previous.';
  }

  @override
  String sprintRecordMatchedBody(Object count) {
    return 'Ви досягли свого рекорду: $count вірних відповідей.';
  }
}
