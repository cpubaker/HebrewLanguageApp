import 'package:flutter/rendering.dart';

enum BottomNavVisibilityDecision { none, show, hide }

class BottomNavAutoHideBehavior {
  const BottomNavAutoHideBehavior({
    this.topRevealOffset = 24,
    this.hideOffset = 72,
    this.hideScrollDelta = 4,
    this.showScrollDelta = -4,
  });

  final double topRevealOffset;
  final double hideOffset;
  final double hideScrollDelta;
  final double showScrollDelta;

  BottomNavVisibilityDecision decisionFor({
    required bool autoHideEnabled,
    required Axis axis,
    required double maxScrollExtent,
    required double pixels,
    ScrollDirection? userScrollDirection,
    double? scrollDelta,
  }) {
    if (!autoHideEnabled) {
      return BottomNavVisibilityDecision.show;
    }

    if (axis != Axis.vertical) {
      return BottomNavVisibilityDecision.none;
    }

    if (maxScrollExtent <= 0 || pixels <= topRevealOffset) {
      return BottomNavVisibilityDecision.show;
    }

    if (userScrollDirection != null) {
      return switch (userScrollDirection) {
        ScrollDirection.forward => BottomNavVisibilityDecision.show,
        ScrollDirection.reverse when pixels > hideOffset =>
          BottomNavVisibilityDecision.hide,
        _ => BottomNavVisibilityDecision.none,
      };
    }

    final delta = scrollDelta ?? 0;
    if (delta > hideScrollDelta && pixels > hideOffset) {
      return BottomNavVisibilityDecision.hide;
    }
    if (delta < showScrollDelta) {
      return BottomNavVisibilityDecision.show;
    }

    return BottomNavVisibilityDecision.none;
  }
}
