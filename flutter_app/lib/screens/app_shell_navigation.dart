import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppRootArea { home, learn, practice, more }

class AppShellBottomNavigation extends StatelessWidget {
  const AppShellBottomNavigation({
    super.key,
    required this.isVisible,
    required this.duration,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onRevealRequested,
  });

  final bool isVisible;
  final Duration duration;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onRevealRequested;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.18),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: isVisible
          ? _ExpandedBottomNavigationBar(
              key: const ValueKey('app-shell-bottom-nav'),
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            )
          : _CollapsedBottomNavigationHandle(
              key: const ValueKey('app-shell-nav-handle'),
              onTap: onRevealRequested,
            ),
    );
  }
}

class _ExpandedBottomNavigationBar extends StatelessWidget {
  const _ExpandedBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Головна',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school_rounded),
          label: 'Вчитись',
        ),
        NavigationDestination(
          icon: Icon(Icons.bolt_outlined),
          selectedIcon: Icon(Icons.bolt_rounded),
          label: 'Практика',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Профіль',
        ),
      ],
    );
  }
}

class _CollapsedBottomNavigationHandle extends StatelessWidget {
  const _CollapsedBottomNavigationHandle({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).appTokens;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: tokens.navBarBackground,
        elevation: 8,
        shadowColor: tokens.shadowColor,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
