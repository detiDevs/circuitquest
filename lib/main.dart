import 'package:circuitquest/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/home/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'state/locale_provider.dart';
import 'state/theme_provider.dart';

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
      overrides: [
        localeProvider.overrideWith((_) => initialLocale),
        themeProvider.overrideWith((_) => initialThemeMode),
      ],
      child: const CircuitQuestApp(),
    ),
  );
}

/// Main application widget for CircuitQuest.
class CircuitQuestApp extends ConsumerWidget {
  const CircuitQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(localeProvider);
    final selectedThemeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: Constants.kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: selectedThemeMode,
      locale: selectedLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
