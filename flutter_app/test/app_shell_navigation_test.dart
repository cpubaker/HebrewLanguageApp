import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_language_flutter/l10n/generated/app_localizations.dart';
import 'package:hebrew_language_flutter/screens/app_shell_navigation.dart';
import 'package:hebrew_language_flutter/theme/app_theme.dart';

void main() {
  testWidgets('expanded bottom navigation selects destinations', (
    tester,
  ) async {
    int? selectedIndex;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: AppShellBottomNavigation(
            isVisible: true,
            duration: Duration.zero,
            selectedIndex: AppRootArea.home.index,
            onDestinationSelected: (index) {
              selectedIndex = index;
            },
            onRevealRequested: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('app-shell-bottom-nav')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('app-shell-bottom-nav'))).height,
      appShellBottomNavigationHeight,
    );

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pump();

    expect(selectedIndex, AppRootArea.learn.index);
  });

  testWidgets('collapsed bottom navigation exposes reveal handle', (
    tester,
  ) async {
    var revealRequested = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: AppShellBottomNavigation(
            isVisible: false,
            duration: Duration.zero,
            selectedIndex: AppRootArea.home.index,
            onDestinationSelected: (_) {},
            onRevealRequested: () {
              revealRequested = true;
            },
          ),
        ),
      ),
    );

    final handle = find.byKey(const ValueKey('app-shell-nav-handle'));
    expect(handle, findsOneWidget);

    await tester.tap(handle);
    await tester.pump();

    expect(revealRequested, isTrue);
  });

  testWidgets('bottom navigation uses the selected locale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildLightAppTheme(),
        home: Scaffold(
          body: AppShellBottomNavigation(
            isVisible: true,
            duration: Duration.zero,
            selectedIndex: AppRootArea.home.index,
            onDestinationSelected: (_) {},
            onRevealRequested: () {},
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
