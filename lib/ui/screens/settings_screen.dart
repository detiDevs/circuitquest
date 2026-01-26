import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Holds the selected language code. "sys-default" means follow device.
  late String _localeChoice;

  @override
  void initState() {
    super.initState();
    final savedLocale = ref.read(localeProvider);
    _localeChoice = savedLocale?.languageCode ?? 'sys-default';
  }

  void _updateLocale(String? value) {
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
            'App language',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('System default'),
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
        ],
      ),
    );
  }
}