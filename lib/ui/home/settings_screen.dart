import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/locale_provider.dart';
import 'package:circuitquest/state/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Holds the selected language code. "sys-default" means follow device.
  late String _localeChoice;

  /// Holds the selected theme mode.
  late String _themeChoice;

  @override
  void initState() {
    super.initState();
    final savedLocale = ref.read(localeProvider);
    _localeChoice = savedLocale?.languageCode ?? 'sys-default';

    final savedThemeMode = ref.read(themeProvider);
    _themeChoice = savedThemeMode.name;
  }

  Future<void> _updateLocale(String? value) async {
    final choice = value ?? 'sys-default';
    setState(() {
      _localeChoice = choice;
    });

    final notifier = ref.read(localeProvider.notifier);
    if (choice == 'sys-default') {
      notifier.state = null; // Use device locale
    } else {
      notifier.state = Locale(choice);
    }

    final prefs = await SharedPreferences.getInstance();
    if (choice == 'sys-default') {
      await prefs.remove(kLocalePrefsKey);
    } else {
      await prefs.setString(kLocalePrefsKey, choice);
    }
  }

  Future<void> _updateTheme(String? value) async {
    final choice = value ?? 'system';
    setState(() {
      _themeChoice = choice;
    });

    final themeMode = ThemeMode.values.byName(choice);
    final notifier = ref.read(themeProvider.notifier);
    notifier.state = themeMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kThemePrefsKey, choice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context)!.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: Text(
              AppLocalizations.of(context)!.systemDefault
            ),
            value: 'sys-default',
            groupValue: _localeChoice,
            onChanged: _updateLocale,
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: _localeChoice,
            onChanged: _updateLocale,
          ),
          RadioListTile<String>(
            title: const Text('Deutsch'),
            value: 'de',
            groupValue: _localeChoice,
            onChanged: _updateLocale,
          ),
          const SizedBox(height: 24),
          Text(
            'Theme',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: Text(
              AppLocalizations.of(context)!.systemDefault
            ),
            value: 'system',
            groupValue: _themeChoice,
            onChanged: _updateTheme,
          ),
          RadioListTile<String>(
            title: const Text('Light'),
            value: 'light',
            groupValue: _themeChoice,
            onChanged: _updateTheme,
          ),
          RadioListTile<String>(
            title: const Text('Dark'),
            value: 'dark',
            groupValue: _themeChoice,
            onChanged: _updateTheme,
          ),
        ],
      ),
    );
  }
}