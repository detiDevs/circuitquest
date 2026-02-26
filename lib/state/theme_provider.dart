import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String kThemePrefsKey = 'selected_theme_mode';

/// Holds the currently selected theme mode.
/// `ThemeMode.system` means "follow device system preference".
final themeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);
