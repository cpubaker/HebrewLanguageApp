import 'package:flutter/material.dart';

const double _scrollToTopThreshold = 240;
const Duration _scrollToTopDuration = Duration(milliseconds: 320);
const Curve _scrollToTopCurve = Curves.easeOutCubic;

mixin LessonScrollMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController scrollController;
  bool _showScrollToTop = false;

  bool get showScrollToTop => _showScrollToTop;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!scrollController.hasClients) {
      return;
    }

    final shouldShow = scrollController.offset > _scrollToTopThreshold;
    if (shouldShow == _showScrollToTop) {
      return;
    }

    setState(() {
      _showScrollToTop = shouldShow;
    });
  }

  Future<void> scrollToTop() async {
    if (!scrollController.hasClients) {
      return;
    }

    await scrollController.animateTo(
      0,
      duration: _scrollToTopDuration,
      curve: _scrollToTopCurve,
    );
  }
}
