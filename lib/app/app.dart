import 'package:circuitquest/app/router.dart';
import 'package:circuitquest/constants.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/app/providers/locale_provider.dart';
import 'package:circuitquest/app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main application widget for CircuitQuest.
class CircuitQuestApp extends ConsumerWidget {
  const CircuitQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(localeProvider);
    final selectedThemeMode = ref.watch(themeProvider);

    return MaterialApp.router(
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
      routerConfig: appRouter,
    );
  }
}
