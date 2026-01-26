import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the currently selected locale.
/// `null` means "system default".
final localeProvider = StateProvider<Locale?>((_) => null);
