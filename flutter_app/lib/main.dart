import 'package:flutter/widgets.dart';

import 'app.dart';
import 'services/theme_mode_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const HebrewFlutterApp(themeModeStore: SharedPreferencesThemeModeStore()),
  );
}
