import 'package:circuitquest/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'state/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLanguageCode = prefs.getString(kLocalePrefsKey);
  final initialLocale =
      savedLanguageCode == null ? null : Locale(savedLanguageCode);

  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith((_) => initialLocale),
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
      locale: selectedLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
