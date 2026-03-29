import 'package:flutter/material.dart';

import 'screens/app_shell_screen.dart';
import 'services/lesson_document_loader.dart';
import 'services/learning_bundle_loader.dart';
import 'theme/app_theme.dart';

class HebrewFlutterApp extends StatelessWidget {
  const HebrewFlutterApp({
    super.key,
    LearningBundleLoader? loader,
    LessonDocumentLoader? documentLoader,
  })  : _loader = loader,
        _documentLoader = documentLoader;

  final LearningBundleLoader? _loader;
  final LessonDocumentLoader? _documentLoader;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hebrew Language App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AppShellScreen(
        loader: _loader ?? AssetLearningBundleLoader(),
        documentLoader: _documentLoader ?? AssetLessonDocumentLoader(),
      ),
    );
  }
}
