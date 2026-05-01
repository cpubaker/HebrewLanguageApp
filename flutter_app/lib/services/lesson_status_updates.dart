import '../models/guide_lesson_status.dart';

Map<String, GuideLessonStatus> applyLessonStatus(
  Map<String, GuideLessonStatus> statuses, {
  required String lessonKey,
  required GuideLessonStatus status,
}) {
  if (status == GuideLessonStatus.unread) {
    return <String, GuideLessonStatus>{
      for (final entry in statuses.entries)
        if (entry.key != lessonKey) entry.key: entry.value,
    };
  }

  return <String, GuideLessonStatus>{...statuses, lessonKey: status};
}
