import 'package:flutter/material.dart';

import '../../models/guide_lesson_status.dart';
import '../../models/learning_bundle.dart';
import '../../services/lesson_status_updates.dart';

mixin LessonStatusHandlerMixin<T extends StatefulWidget> on State<T> {
  late Map<String, GuideLessonStatus> _lessonStatuses;
  late Map<String, GuideLessonStatus> _lastWidgetStatuses;

  Map<String, GuideLessonStatus> get widgetLessonStatuses;
  LessonStatusChangeHandler get widgetOnStatusChanged;

  Map<String, GuideLessonStatus> get lessonStatuses => _lessonStatuses;

  @override
  void initState() {
    super.initState();
    _lastWidgetStatuses = widgetLessonStatuses;
    _lessonStatuses = Map<String, GuideLessonStatus>.from(widgetLessonStatuses);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = widgetLessonStatuses;
    if (!identical(_lastWidgetStatuses, current)) {
      _lastWidgetStatuses = current;
      _lessonStatuses = Map<String, GuideLessonStatus>.from(current);
    }
  }

  GuideLessonStatus statusFor(LessonEntry lesson) {
    return _lessonStatuses[lesson.progressKey] ?? GuideLessonStatus.unread;
  }

  Future<void> handleLessonStatusSelected(
    LessonEntry lesson,
    GuideLessonStatus status,
  ) async {
    final lessonKey = lesson.progressKey;
    final previousStatus = _lessonStatuses[lessonKey];
    setState(() {
      _lessonStatuses = applyLessonStatus(
        _lessonStatuses,
        lessonKey: lessonKey,
        status: status,
      );
    });

    final saved = await widgetOnStatusChanged(lessonKey, status);
    if (!saved && mounted) {
      setState(() {
        _lessonStatuses = restoreLessonStatus(
          _lessonStatuses,
          lessonKey: lessonKey,
          previousStatus: previousStatus,
        );
      });
    }
  }
}
