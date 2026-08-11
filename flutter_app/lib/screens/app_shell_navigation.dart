import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

enum AppRootArea { home, learn, practice, profile }

const double appShellBottomNavigationHeight = 72;

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
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final navigationBarTheme = theme.navigationBarTheme;
    final localizations = AppLocalizations.of(context);
    final items = [
      _BottomNavigationItem(
        area: AppRootArea.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: localizations.navHome,
      ),
      _BottomNavigationItem(
        area: AppRootArea.learn,
        icon: Icons.school_outlined,
        selectedIcon: Icons.school_rounded,
        label: localizations.navLearn,
      ),
      _BottomNavigationItem(
        area: AppRootArea.practice,
        icon: Icons.bolt_outlined,
        selectedIcon: Icons.bolt_rounded,
        label: localizations.navPractice,
      ),
      _BottomNavigationItem(
        area: AppRootArea.profile,
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: localizations.navProfile,
      ),
    ];

    return Material(
      color: navigationBarTheme.backgroundColor ?? tokens.navBarBackground,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: appShellBottomNavigationHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 5, 4, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in items)
                  Expanded(
                    child: _BottomNavigationDestinationButton(
                      item: item,
                      isSelected: selectedIndex == item.area.index,
                      onTap: () => onDestinationSelected(item.area.index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationDestinationButton extends StatelessWidget {
  const _BottomNavigationDestinationButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _BottomNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.appTokens;
    final navigationBarTheme = theme.navigationBarTheme;
    final colorScheme = theme.colorScheme;
    final states = isSelected
        ? const <WidgetState>{WidgetState.selected}
        : const <WidgetState>{};
    final iconTheme =
        navigationBarTheme.iconTheme?.resolve(states) ??
        IconThemeData(
          color: isSelected ? colorScheme.primary : tokens.secondaryText,
        );
    final labelStyle =
        navigationBarTheme.labelTextStyle?.resolve(states) ??
        theme.textTheme.labelSmall?.copyWith(
          color: iconTheme.color,
          fontWeight: FontWeight.w700,
        );
    final indicatorColor =
        navigationBarTheme.indicatorColor ??
        tokens.accentSoftBorder(colorScheme.primary);

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 56,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? indicatorColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: iconTheme.size ?? 24,
                  color: iconTheme.color,
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: labelStyle?.copyWith(height: 1.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class _BottomNavigationItem {
  const _BottomNavigationItem({
    required this.area,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final AppRootArea area;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _CollapsedBottomNavigationHandle extends StatelessWidget {
  const _CollapsedBottomNavigationHandle({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).appTokens;

    return SafeArea(
      top: false,
      child: Padding(
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
                      color: tokens.accentHandle(colorScheme.primary),
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
      ),
    );
  }
}
