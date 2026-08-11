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

  @override
  String get navHome => 'Home';

  @override
  String get navLearn => 'Learn';

  @override
  String get navPractice => 'Practice';

  @override
  String get navProfile => 'Profile';

  @override
  String get learnWorkspaceSubtitle => 'Choose where to continue learning.';

  @override
  String get workspaceWordsTitle => 'Words';

  @override
  String get workspaceWordsSubtitle =>
      'A dictionary with search, filters, and progress.';

  @override
  String get workspaceVerbsTitle => 'Verbs';

  @override
  String get workspaceVerbsSubtitle => 'Lessons with explanations and audio.';

  @override
  String get workspaceGuideTitle => 'Guide';

  @override
  String get workspaceGuideSubtitle =>
      'Grammar with explanations and examples.';

  @override
  String get workspaceReadingTitle => 'Reading';

  @override
  String get workspaceReadingSubtitle => 'Texts grouped by difficulty.';

  @override
  String get practiceWorkspaceSubtitle =>
      'Choose a training format and open it in a dedicated full-screen session.';

  @override
  String get workspaceReviewTitle => 'Review';

  @override
  String get workspaceReviewSubtitle =>
      'New words and recent mistakes for a calm review.';

  @override
  String get workspaceFlashcardsTitle => 'Flashcards';

  @override
  String get workspaceFlashcardsSubtitle =>
      'Quick practice with translations, contexts, and review decks.';

  @override
  String get workspaceWritingTitle => 'Writing';

  @override
  String get workspaceWritingSubtitle => 'Write Hebrew words without hints.';

  @override
  String get workspaceConstructorTitle => 'Builder';

  @override
  String get workspaceConstructorSubtitle =>
      'Build a word from tiles in the correct order.';

  @override
  String get workspaceSprintTitle => 'Sprint';

  @override
  String get workspaceSprintSubtitle =>
      'A one-minute speed round with two translation choices for each word.';

  @override
  String get workspaceAiTextTitle => 'Text with your words';

  @override
  String get workspaceAiTextSubtitle =>
      'A short AI text with your words, a translation, and a quick route to practice.';

  @override
  String get wordOfDay => 'Word of the day';

  @override
  String get wordOfDayAudioChecking => 'Checking audio';

  @override
  String get wordOfDayAudioStop => 'Stop audio';

  @override
  String get wordOfDayAudioPlay => 'Play audio';

  @override
  String get wordOfDayAudioUnavailable => 'Audio is not available yet';

  @override
  String get wordOfDayAudioFailure => 'Could not play the word audio.';

  @override
  String get wordOfDayEmpty =>
      'Words will appear after the learning library loads.';

  @override
  String get homeActionFirstStep => 'First step';

  @override
  String get homeActionToday => 'Today';

  @override
  String get homeActionWelcomeTitle => 'Hi! Ready to get started?';

  @override
  String get homeActionWelcomeSubtitle =>
      'Open your first flashcards to meet Hebrew words and earn the first day of your streak.';

  @override
  String get homeActionTry => 'Try it';

  @override
  String get homeActionReviewTitle => 'Continue reviewing';

  @override
  String homeActionReviewSubtitle(int count) {
    return '$count words are waiting in your flashcards for review.';
  }

  @override
  String get homeActionGoToReview => 'Review';

  @override
  String get homeActionNewWordsTitle => 'Ready for something new?';

  @override
  String homeActionNewWordsSubtitle(int count) {
    return '$count words are waiting to be seen for the first time.';
  }

  @override
  String get homeActionGoToNewWords => 'New words';

  @override
  String get homeActionReadingTitle => 'Everything reviewed — shall we read?';

  @override
  String get homeActionReadingSubtitle =>
      'Texts are waiting in the library to help you level up.';

  @override
  String get homeActionGoToReading => 'Start reading';

  @override
  String get homeActionFallbackTitle => 'Explore the dictionary';

  @override
  String get homeActionFallbackSubtitle =>
      'Browse the words to choose what to learn next.';

  @override
  String get homeActionGoToWords => 'Words';

  @override
  String get wordsTitle => 'Words';

  @override
  String get wordsSubtitle =>
      'Search in Ukrainian, English, Hebrew, or by transliteration.';

  @override
  String get wordsSearchHint => 'Search words';

  @override
  String get wordsFilterAll => 'All';

  @override
  String get wordsFilterNew => 'New';

  @override
  String get wordsFilterLearned => 'Learned';

  @override
  String get wordsFilterReview => 'Review';

  @override
  String get wordsVisible => 'Visible';

  @override
  String get wordsTotal => 'Total';

  @override
  String get wordsSearchTooltip => 'Search the dictionary';

  @override
  String get wordsNoResultsTitle => 'Nothing found';

  @override
  String get wordsNoResultsAll =>
      'Try another query: a Ukrainian or English word, a Hebrew form, or transliteration.';

  @override
  String wordsNoResultsFilter(String filter) {
    return 'There are no results in the “$filter” view yet. Try another filter or query.';
  }

  @override
  String get wordOpenTooltip => 'Open word';

  @override
  String get wordChangeStatusTooltip => 'Change word status';

  @override
  String get wordStatusUnknown => 'Don\'t know';

  @override
  String get wordStatusLearning => 'Learning';

  @override
  String get wordStatusKnown => 'Know it';

  @override
  String get wordStatCorrect => 'Correct';

  @override
  String get wordStatMistakes => 'Mistakes';

  @override
  String get wordContexts => 'Contexts';

  @override
  String get wordContextLoading => 'Finding a new context...';

  @override
  String get wordContextEmpty => 'There is no context for this word yet.';

  @override
  String get wordAudioChecking => 'Checking word audio';

  @override
  String get wordAudioUnavailable => 'Word audio is not available yet';

  @override
  String get wordAudioStop => 'Stop word pronunciation';

  @override
  String get wordAudioPlay => 'Play word pronunciation';

  @override
  String get wordAudioPlaybackFailure =>
      'Could not play the word pronunciation.';

  @override
  String get flashcardsTitle => 'Flashcards';

  @override
  String get flashcardsDeckMode => 'Mode';

  @override
  String get flashcardsDeckAll => 'All';

  @override
  String get flashcardsDeckContexts => 'Context';

  @override
  String get flashcardsDeckReview => 'Review';

  @override
  String get flashcardsEmptySubtitle =>
      'There is nothing here right now. Choose another mode or come back later.';

  @override
  String get flashcardsEmptyAllTitle => 'Words have not loaded yet.';

  @override
  String get flashcardsEmptyAllBody =>
      'You will be able to start practicing here as soon as words are available.';

  @override
  String get flashcardsEmptyContextsTitle =>
      'There are no flashcards with examples yet.';

  @override
  String get flashcardsEmptyContextsBody =>
      'This mode will become available when examples are added to words.';

  @override
  String get flashcardsEmptyReviewTitle => 'Your review queue is empty.';

  @override
  String get flashcardsEmptyReviewBody =>
      'Mark words as “Again” and they will appear here separately.';

  @override
  String get flashcardsCompletedSubtitle =>
      'You have completed this deck. You can start again or move on.';

  @override
  String get flashcardsDone => 'Done';

  @override
  String flashcardsCompletedTitle(int count) {
    return '$count flashcards completed';
  }

  @override
  String get flashcardsRepeat => 'Again';

  @override
  String get flashcardsRestart => 'Start again';

  @override
  String get flashcardsGoToReview => 'Go to review';

  @override
  String flashcardsCompletionAllWithReview(int count) {
    return '$count flashcards are waiting for review.';
  }

  @override
  String get flashcardsCompletionAll =>
      'You have reviewed every word in this deck.';

  @override
  String flashcardsCompletionContextsWithReview(int count) {
    return 'After this round, $count flashcards moved to review.';
  }

  @override
  String get flashcardsCompletionContexts =>
      'You have completed all flashcards with examples.';

  @override
  String get flashcardsCompletionReview => 'You have reviewed everything.';

  @override
  String get flashcardsContextEmpty =>
      'There is no sentence example for this word yet.';

  @override
  String get flashcardsContextTitle => 'Context';

  @override
  String get aiContextNew => 'New!';

  @override
  String get aiContext => 'AI';

  @override
  String get repetitionTitle => 'Review';

  @override
  String get repetitionEmptySubtitle =>
      'New words and recent mistakes will appear here when they are available.';

  @override
  String get repetitionCompletedSubtitle =>
      'You have completed the session. You can go through it again right away.';

  @override
  String get repetitionActiveSubtitle =>
      'One word at a time, with no timer or options.';

  @override
  String get repetitionNext => 'Next';

  @override
  String get repetitionFinish => 'Finish';

  @override
  String get repetitionEmptyTitle => 'Your review queue is empty.';

  @override
  String get repetitionEmptyBody =>
      'Open new words first or make a few attempts in practice.';

  @override
  String get repetitionDone => 'Done';

  @override
  String repetitionCompletedTitle(int count) {
    return '$count words reviewed';
  }

  @override
  String get repetitionAfterMistake => 'After a mistake';

  @override
  String get repetitionReinforcement => 'Reinforce what you know';

  @override
  String get repetitionRestart => 'Start again';

  @override
  String get repetitionTranslation => 'Translation';

  @override
  String get repetitionLastMistake => 'Last attempt was incorrect';

  @override
  String get repetitionReinforcementWord => 'Word to reinforce';

  @override
  String get repetitionContextEmpty =>
      'A context has not been added for this word yet.';

  @override
  String get repetitionContextTitle => 'Context';

  @override
  String get writingTitle => 'Writing';

  @override
  String get writingPromptTitle => 'Word to translate';

  @override
  String get writingNoHints => 'No hints: try to recall the word on your own.';

  @override
  String get writingAnswerHint => 'Enter the word in Hebrew';

  @override
  String get writingFillAllTiles => 'Fill every tile, then check your answer.';

  @override
  String get writingEnterAnswer =>
      'Enter the word in Hebrew to check your answer.';

  @override
  String get writingBuildAnswer =>
      'Build the word from tiles to check your answer.';

  @override
  String get writingReadyToCheck => 'Tap “Check” when you are ready.';

  @override
  String get writingCurrentSession => 'Current session';

  @override
  String writingCheckedAnswers(int count) {
    return 'Answers checked: $count';
  }

  @override
  String writingAvailableWords(int count) {
    return '$count words are available for writing on this device';
  }

  @override
  String get writingCorrect => 'Correct';

  @override
  String get writingCorrectAnswer => 'Here is the correct answer';

  @override
  String get writingCorrectBody =>
      'The word is written correctly. You can move on.';

  @override
  String get writingIncorrectBody =>
      'No worries. We will return to this word later.';

  @override
  String get writingUnknown => 'Don\'t know';

  @override
  String get writingCheck => 'Check';

  @override
  String get writingNext => 'Next';

  @override
  String get writingEmptySubtitle =>
      'Once words load, you will be able to practice writing Hebrew or build words from tiles here.';

  @override
  String get writingEmptyBody =>
      'Once there are words available in the deck, you will be able to practice writing in a dedicated session.';

  @override
  String get writingBuildWord => 'Build the word';

  @override
  String get writingBuildWordSubtitle =>
      'Drag the tiles into the correct order. Tapping a tile works too.';

  @override
  String get writingAvailableTiles => 'Available tiles';

  @override
  String get readingLevelBeginner => 'Beginner';

  @override
  String get readingLevelPreIntermediate => 'Pre-intermediate';

  @override
  String get readingLevelIntermediate => 'Intermediate';

  @override
  String get readingLevelUpperIntermediate => 'Upper-intermediate';

  @override
  String get readingLevelAdvanced => 'Advanced';

  @override
  String get readingLevelProficient => 'Proficient';

  @override
  String get readingLevelFallback => 'Reading';

  @override
  String get audioPlay => 'Play audio';

  @override
  String get featureNightModeTitle => 'Night mode';

  @override
  String get featureAdvancedPracticeTitle => 'Advanced practice';

  @override
  String get featureExtraLessonsTitle => 'Extra lessons';

  @override
  String get featureAiContextsTitle => 'AI word contexts';

  @override
  String get featureAiTextsTitle => 'AI practice texts';

  @override
  String get featureNightModeDescription =>
      'Night mode is available in the Pro version.';

  @override
  String get featureAdvancedPracticeDescription =>
      'Advanced practice modes are available in the Pro version.';

  @override
  String get featureExtraLessonsDescription =>
      'Additional lesson sets are available in the Pro version.';

  @override
  String get featureAiDescription =>
      'AI features are being prepared for launch. They will be available soon.';

  @override
  String get featureUpgradePro => 'Upgrade to Pro';

  @override
  String get audioVolumeMuted =>
      'Sound is muted. Turn up media volume with the side buttons.';

  @override
  String get guidePreviousTopic => 'Previous topic';

  @override
  String get guideNextTopic => 'Next topic';

  @override
  String get guideNoTopic => 'None';

  @override
  String get guideRelatedLoading =>
      'Finding related topics for quick navigation.';

  @override
  String get guideRelatedTitle => 'Related topics';

  @override
  String get guideRelatedEmpty =>
      'All closest related topics are already available in the navigation above.';

  @override
  String get guideOutlineTitle => 'In this article';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get shellGuideSaveFailure =>
      'Could not save guide progress. Please try again.';

  @override
  String get shellReadingSaveFailure =>
      'Could not save reading progress. Please try again.';

  @override
  String get shellContextsLoadFailure =>
      'Could not load word contexts. Please try again.';

  @override
  String get shellAiTextsDisabled => 'Enable AI practice texts in settings.';

  @override
  String get shellNoWordsForText =>
      'There are no words available to generate a text yet.';

  @override
  String get shellWordSaveFailure =>
      'Could not save word progress. Please try again.';

  @override
  String get shellLoadingMaterials => 'Loading learning materials...';

  @override
  String get shellMaterialsLoadFailure => 'Could not load learning materials.';

  @override
  String get retry => 'Try again';

  @override
  String get readingTitle => 'Reading';

  @override
  String get readingSubtitle => 'Reading texts organized by level.';

  @override
  String get verbsTitle => 'Verbs';

  @override
  String get verbsSubtitle =>
      'Core verbs with explanations, pronunciation, and illustrations.';

  @override
  String get verbsOpenSearch => 'Show search';

  @override
  String get verbsOpenFailure => 'Could not open this lesson.';

  @override
  String get verbsSearchHint => 'Search by lesson title';

  @override
  String get verbsFound => 'Found';

  @override
  String get verbsLessons => 'Lessons';

  @override
  String get verbsTotal => 'Total';

  @override
  String get verbsLoadingTitles => 'Loading titles';

  @override
  String get verbsEmptyTitle => 'Nothing found.';

  @override
  String get verbsEmptyBody =>
      'Try another query: a verb name or lesson topic.';

  @override
  String get verbsAudioFailure => 'Could not play the pronunciation.';

  @override
  String get verbsCheckingAudio => 'Checking audio';

  @override
  String get verbsStopAudio => 'Stop pronunciation';

  @override
  String get verbsPlayAudio => 'Play pronunciation';

  @override
  String get verbsAudioUnavailable => 'Audio is not available yet';

  @override
  String get verbsImageUnavailable =>
      'An illustration for this verb has not been added yet.';

  @override
  String sprintAvailableWords(Object count) {
    return 'Words being learned for the sprint: $count';
  }

  @override
  String sprintCorrectAnswers(Object count) {
    return 'Correct answers: $count';
  }

  @override
  String sprintWrongAnswers(Object count) {
    return 'Incorrect answers: $count';
  }

  @override
  String get guideTitle => 'Guide';

  @override
  String get guideSectionFilterTitle => 'Guide section';

  @override
  String get guideSectionFilterBody =>
      'Keep the whole catalog or choose several sections.';

  @override
  String get guideAllTopics => 'All topics';

  @override
  String get guideOpenFailure => 'Could not open this lesson.';

  @override
  String get readingOpenFilter => 'Open filter';

  @override
  String get readingChangeFilter => 'Change filter';

  @override
  String get readingLevelFilterTitle => 'Reading level';

  @override
  String get readingLevelFilterBody =>
      'Keep the whole catalog or choose one level.';

  @override
  String get readingAllLevels => 'All levels';

  @override
  String get readingLevel => 'Level';

  @override
  String readingLessonsCount(Object count) {
    return '$count lessons';
  }

  @override
  String catalogFound(Object total, Object visible) {
    return 'Found: $visible of $total';
  }

  @override
  String catalogGuideCount(Object count) {
    return 'Topics: $count';
  }

  @override
  String catalogReadingCount(Object count) {
    return 'Lessons: $count';
  }

  @override
  String catalogReadCount(Object read, Object total) {
    return 'Read $read of $total topics';
  }

  @override
  String catalogSection(Object read, Object section, Object total) {
    return 'Section: $section · Read $read of $total';
  }

  @override
  String catalogSections(Object count, Object read, Object total) {
    return 'Sections: $count · Read $read of $total';
  }

  @override
  String get catalogOpenSectionFilter => 'Open section filter';

  @override
  String get catalogChangeSectionFilter => 'Change section filter';

  @override
  String get catalogHideSearch => 'Hide search';

  @override
  String get catalogShowSearch => 'Show search';

  @override
  String get catalogGuideSearchHint => 'Search topics in the guide';

  @override
  String get catalogReadingSearchHint => 'Search lessons by title';

  @override
  String get catalogLoadingGuideTitles =>
      'Loading summaries and lesson titles for more accurate search.';

  @override
  String get catalogLoadingReadingTitles =>
      'Loading lesson titles for more accurate search.';

  @override
  String catalogTopicsCount(Object count) {
    return '$count topics';
  }

  @override
  String get catalogNothingFound => 'Nothing found.';

  @override
  String get catalogGuideEmpty =>
      'Try another query or clear the section filter.';

  @override
  String get catalogReadingEmpty =>
      'Try another query or clear the level filter.';

  @override
  String get lessonStatusUnread => 'Unread';

  @override
  String get lessonStatusLearning => 'Learning';

  @override
  String get lessonStatusRead => 'Read';

  @override
  String get lessonStatusChange => 'Change lesson status';

  @override
  String get aiTextTitle => 'Text with your words';

  @override
  String get aiTextSubtitle =>
      'A short Hebrew text with your current words, a translation, and links to practice.';

  @override
  String get aiTextWords => 'Words for this text';

  @override
  String get aiTextFallbackTitle => 'Practice text';

  @override
  String get aiTextInText => 'In the text';

  @override
  String get aiTextFlashcards => 'Flashcards';

  @override
  String get aiTextWriting => 'Writing';

  @override
  String get aiTextRefresh => 'Refresh text';

  @override
  String get aiTextNew => 'New!';

  @override
  String get aiTextNotGenerated => 'A text has not been generated yet';

  @override
  String get aiTextNotGeneratedBody =>
      'Could not refresh the text. Please try again later.';

  @override
  String get aiTextRetry => 'Try again';

  @override
  String get aiTextFailure => 'Could not get a text';

  @override
  String get aiTextFailureBody =>
      'Saved practice remains available. Please try again.';

  @override
  String get aiTextRepeat => 'Retry';

  @override
  String get profileSystem => 'System';

  @override
  String get profileProgress => 'Progress';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileWords => 'Words';

  @override
  String get profileGuide => 'Guide';

  @override
  String get profileReading => 'Reading';

  @override
  String get profileVerbs => 'Verbs';

  @override
  String get profileWordsOpened => 'Words opened';

  @override
  String get profileWritingPracticed => 'Writing practiced';

  @override
  String get profileGuideCompleted => 'Guide completed';

  @override
  String get profileReadingCompleted => 'Reading completed';

  @override
  String get profileKnownWords => 'Known words';

  @override
  String get profileReview => 'Review';

  @override
  String get profileAutoHideNav => 'Automatically hide the bottom navigation';

  @override
  String get profileAutoHideNavBody =>
      'When you scroll down through a long page, the bottom navigation temporarily hides to free more screen space.';

  @override
  String get profileAiContexts => 'AI contexts for practice';

  @override
  String get profileAiContextsBody =>
      'Examples and situations based on your words.';

  @override
  String get profileAiTexts => 'AI texts for practice';

  @override
  String get profileAiTextsBody => 'Short texts tailored to your level.';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileThemeBody =>
      'Switches between light, dark, and system themes.';

  @override
  String get sprintTitle => 'Sprint';

  @override
  String get sprintUnavailableTitle => 'Sprint is not available yet';

  @override
  String sprintUnavailableBody(Object count) {
    return 'This exercise needs at least two words being learned with different translations. $count words are available now.';
  }

  @override
  String get sprintIntroUnavailable =>
      'A one-minute exercise with two translation choices. You need at least two words being learned with different translations.';

  @override
  String get sprintIntro =>
      'Choose as many correct translations as possible in 60 seconds. Each word being learned appears once.';

  @override
  String get sprintTimeStarted =>
      'Time has started. Choose the correct translation as quickly as you can.';

  @override
  String get sprintFirstPromptFailure =>
      'Could not prepare the first sprint prompt.';

  @override
  String get sprintStatsSaveFailure => 'Could not save sprint statistics.';

  @override
  String sprintAnswerCorrect(Object translation) {
    return 'Correct: $translation';
  }

  @override
  String sprintAnswerWrong(Object translation) {
    return 'Incorrect. The correct answer is: $translation';
  }

  @override
  String get sprintEarlyCompletion =>
      'You completed every word being learned. The sprint ended early — great pace.';

  @override
  String get sprintCompleted =>
      'Sprint complete. You can start another minute right away.';

  @override
  String get sprintSession => 'Current session';

  @override
  String get sprintLoadingStats => 'Loading sprint statistics...';

  @override
  String get sprintNoStats =>
      'Your record and average will appear after the first completed sprint.';

  @override
  String sprintBest(Object count) {
    return 'Best result: $count correct answers';
  }

  @override
  String sprintAverage(Object count) {
    return 'Average result: $count correct answers';
  }

  @override
  String sprintAttempts(Object count) {
    return '$count answers';
  }

  @override
  String get sprintRestart => 'Restart';

  @override
  String get sprintChoose => 'Choose the correct translation';

  @override
  String get sprintAwaitingAnswer =>
      'A short result will appear here right after you answer.';

  @override
  String get sprintCorrect => 'Correct';

  @override
  String get sprintMistakes => 'Mistakes';

  @override
  String get sprintTimeUp => 'Time is up';

  @override
  String sprintCorrectCount(Object count) {
    return '$count correct answers';
  }

  @override
  String get sprintTotal => 'Total';

  @override
  String get sprintRecord => 'Record';

  @override
  String get sprintStartAgain => 'Start again';

  @override
  String get sprintFirstRecord => 'First record';

  @override
  String get sprintNewRecord => 'New record';

  @override
  String get sprintRecordMatched => 'Record matched';

  @override
  String sprintAboveAverage(Object count) {
    return 'This is $count above your average.';
  }

  @override
  String sprintFirstRecordBody(Object count) {
    return 'First record: $count correct answers.';
  }

  @override
  String sprintNewRecordBody(Object count, Object previous) {
    return 'You beat your record: $count correct answers. The previous record was $previous.';
  }

  @override
  String sprintRecordMatchedBody(Object count) {
    return 'You matched your record: $count correct answers.';
  }
}
