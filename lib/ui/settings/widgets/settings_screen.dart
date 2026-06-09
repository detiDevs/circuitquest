import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/settings/view_models/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

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
    final savedLocale = widget.viewModel.getSavedLocale(ref);
    _localeChoice = savedLocale?.languageCode ?? 'sys-default';

    final savedThemeMode = widget.viewModel.getSaveThemeMode(ref);
    _themeChoice = savedThemeMode.name;
  }

  Future<void> _updateLocale(String? value) async {
    final choice = value ?? 'sys-default';
    setState(() {
      _localeChoice = choice;
    });

    widget.viewModel.updateLocale(ref, choice);
  }

  Future<void> _updateTheme(String? value) async {
    final choice = value ?? 'system';
    setState(() {
      _themeChoice = choice;
    });

    await widget.viewModel.updateTheme(ref, choice);
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
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(AppLocalizations.of(context)!.resetProgress),
            subtitle: Text(AppLocalizations.of(context)!.resetProgressSubtitle),
            onTap: () => _confirmResetProgress(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetProgressConfirmTitle),
        content: Text(AppLocalizations.of(context)!.resetProgressConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.viewModel.resetUserProgress(ref);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.progressReset)),
      );
    }
  }
}