import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String kLocalePrefsKey = 'selected_locale_language_code';

/// Holds the currently selected locale.
/// `null` means "system default".
final localeProvider = StateProvider<Locale?>((_) => null);
