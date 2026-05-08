import 'lesson_progress_store.dart';

abstract class GuideProgressStore implements LessonProgressStore {}

class SharedPreferencesGuideProgressStore
    extends SharedPreferencesLessonProgressStore
    implements GuideProgressStore {
  const SharedPreferencesGuideProgressStore()
    : super(
        storageKey: 'guide_lesson_statuses',
        logLabel: 'guide',
        mergeDuplicateStatuses: true,
      );
}
