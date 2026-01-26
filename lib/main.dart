import 'package:circuitquest/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/home_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: CircuitQuestApp()));
}

/// Main application widget for CircuitQuest.
class CircuitQuestApp extends StatelessWidget {
  const CircuitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
