import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/screens/bottom_nav_auto_hide_behavior.dart';

void main() {
  const behavior = BottomNavAutoHideBehavior();

  test('shows navigation when auto-hide is disabled', () {
    expect(
      behavior.decisionFor(
        autoHideEnabled: false,
        axis: Axis.horizontal,
        maxScrollExtent: 100,
        pixels: 100,
        userScrollDirection: ScrollDirection.reverse,
      ),
      BottomNavVisibilityDecision.show,
    );
  });

  test('ignores horizontal scrolling when auto-hide is enabled', () {
    expect(
      behavior.decisionFor(
        autoHideEnabled: true,
        axis: Axis.horizontal,
        maxScrollExtent: 100,
        pixels: 100,
        userScrollDirection: ScrollDirection.reverse,
      ),
      BottomNavVisibilityDecision.none,
    );
  });

  test('shows navigation near the top or on non-scrollable content', () {
    expect(
      behavior.decisionFor(
        autoHideEnabled: true,
        axis: Axis.vertical,
        maxScrollExtent: 0,
        pixels: 100,
      ),
      BottomNavVisibilityDecision.show,
    );
    expect(
      behavior.decisionFor(
        autoHideEnabled: true,
        axis: Axis.vertical,
        maxScrollExtent: 100,
        pixels: 24,
      ),
      BottomNavVisibilityDecision.show,
    );
  });

  test('uses user scroll direction when available', () {
    expect(
      behavior.decisionFor(
        autoHideEnabled: true,
        axis: Axis.vertical,
        maxScrollExtent: 200,
        pixels: 100,
        userScrollDirection: ScrollDirection.reverse,
      ),
      BottomNavVisibilityDecision.hide,
    );
    expect(
      behavior.decisionFor(
        autoHideEnabled: true,
        axis: Axis.vertical,
        maxScrollExtent: 200,
        pixels: 100,
        userScrollDirection: ScrollDirection.forward,
      ),
      BottomNavVisibilityDecision.show,
    );
  });

  test('uses scroll update delta when user direction is absent', () {
    expect(
      behavior.decisionFor(
        autoHideEnabled: true,
        axis: Axis.vertical,
        maxScrollExtent: 200,
        pixels: 100,
        scrollDelta: 5,
      ),
      BottomNavVisibilityDecision.hide,
    );
    expect(
      behavior.decisionFor(
        autoHideEnabled: true,
        axis: Axis.vertical,
        maxScrollExtent: 200,
        pixels: 100,
        scrollDelta: -5,
      ),
      BottomNavVisibilityDecision.show,
    );
  });

  test(
    'keeps current visibility for small deltas and early reverse scrolls',
    () {
      expect(
        behavior.decisionFor(
          autoHideEnabled: true,
          axis: Axis.vertical,
          maxScrollExtent: 200,
          pixels: 70,
          userScrollDirection: ScrollDirection.reverse,
        ),
        BottomNavVisibilityDecision.none,
      );
      expect(
        behavior.decisionFor(
          autoHideEnabled: true,
          axis: Axis.vertical,
          maxScrollExtent: 200,
          pixels: 100,
          scrollDelta: 3,
        ),
        BottomNavVisibilityDecision.none,
      );
    },
  );
}
