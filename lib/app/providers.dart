import 'package:circuitquest/app/providers/locale_provider.dart';
import 'package:circuitquest/app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<Override> buildAppProviderOverrides({
  Locale? initialLocale,
  ThemeMode? initialThemeMode,
}) {
  return [
    if (initialLocale != null)
      localeProvider.overrideWith((_) => initialLocale),
    if (initialThemeMode != null)
      themeProvider.overrideWith((_) => initialThemeMode),
  ];
}
