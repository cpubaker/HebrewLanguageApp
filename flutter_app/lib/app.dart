import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/learning_bundle_loader.dart';
import 'theme/app_theme.dart';

class HebrewFlutterApp extends StatelessWidget {
  const HebrewFlutterApp({
    super.key,
    LearningBundleLoader? loader,
  }) : _loader = loader;

  final LearningBundleLoader? _loader;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hebrew Language App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: HomeScreen(
        loader: _loader ?? AssetLearningBundleLoader(),
      ),
    );
  }
}
