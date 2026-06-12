import 'package:circuitquest/app/providers/locale_provider.dart';
import 'package:circuitquest/app/providers/theme_provider.dart';
import 'package:circuitquest/data/repositories/level_repository_impl.dart';
import 'package:circuitquest/ui/shared/providers/level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  Locale? getSavedLocale(WidgetRef ref) {
    return ref.read(localeProvider);
  }

  ThemeMode getSaveThemeMode(WidgetRef ref) {
    return ref.read(themeProvider);
  }

  Future<void> updateLocale(WidgetRef ref, String choice) async {
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

  Future<void> updateTheme(WidgetRef ref, String choice) async {
    final themeMode = ThemeMode.values.byName(choice);
    final notifier = ref.read(themeProvider.notifier);
    notifier.state = themeMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kThemePrefsKey, choice);
  }

  Future<void> resetUserProgress(WidgetRef ref) async {
    final levelRepository = ref.read(levelRepositoryProvider);
    await levelRepository.resetUserProgress();

    // Invalidate providers so UI refreshes
    ref.invalidate(levelMetaProvider);
    ref.invalidate(levelCompletedProvider);
    ref.invalidate(levelAccessProvider);
  }
}
