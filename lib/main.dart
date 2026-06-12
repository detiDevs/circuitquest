import 'package:circuitquest/app/app.dart';
import 'package:circuitquest/app/providers.dart';
import 'package:circuitquest/app/providers/locale_provider.dart';
import 'package:circuitquest/app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLanguageCode = prefs.getString(kLocalePrefsKey);
  final initialLocale =
      savedLanguageCode == null ? null : Locale(savedLanguageCode);

  final savedThemeModeString = prefs.getString(kThemePrefsKey);
  final initialThemeMode = savedThemeModeString == null
      ? ThemeMode.system
      : ThemeMode.values.byName(savedThemeModeString);

  runApp(
    ProviderScope(
      overrides: buildAppProviderOverrides(
        initialLocale: initialLocale,
        initialThemeMode: initialThemeMode,
      ),
      child: const CircuitQuestApp(),
    ),
  );
}
