import 'lesson_progress_store.dart';

abstract class ReadingProgressStore implements LessonProgressStore {}

class SharedPreferencesReadingProgressStore
    extends SharedPreferencesLessonProgressStore
    implements ReadingProgressStore {
  const SharedPreferencesReadingProgressStore()
    : super(storageKey: 'reading_lesson_statuses', logLabel: 'reading');
}
