import 'dart:convert';

import 'package:circuitquest/constants.dart';
import 'package:circuitquest/core/components/custom_component_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_component_entry.dart';

const _kNamesKey = '${Constants.kAppName}_custom_component_names';
String _dataKey(String storageName) =>
    '${Constants.kAppName}_custom_component_$storageName';

/// Saves [data] to shared_preferences. Returns true on success.
/// Sprites are not supported on web.
Future<bool> saveCustomComponentToPlatform(
  CustomComponentData data, {
  String? spriteSourcePath,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final storageName = sanitizeComponentFileName(data.name);

    await prefs.setString(
      _dataKey(storageName),
      const JsonEncoder.withIndent('  ').convert(data.toJson()),
    );

    final names = List<String>.from(
      prefs.getStringList(_kNamesKey) ?? [],
    )..add(storageName);
    await prefs.setStringList(_kNamesKey, names.toSet().toList());

    return true;
  } catch (_) {
    return false;
  }
}

/// Deletes the component with [name] from shared_preferences.
/// Returns true on success.
Future<bool> deleteCustomComponentFromPlatform(String name) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final storageName = sanitizeComponentFileName(name);

    await prefs.remove(_dataKey(storageName));

    final names = List<String>.from(
      prefs.getStringList(_kNamesKey) ?? [],
    )..remove(storageName);
    await prefs.setStringList(_kNamesKey, names);

    return true;
  } catch (_) {
    return false;
  }
}

/// Loads all custom components from shared_preferences.
Future<List<CustomComponentEntry>> loadCustomComponentsFromPlatform() async {
  final prefs = await SharedPreferences.getInstance();
  final names = List<String>.from(
    prefs.getStringList(_kNamesKey) ?? [],
  );

  final entries = <CustomComponentEntry>[];
  for (final storageName in names) {
    try {
      final jsonString = prefs.getString(_dataKey(storageName));
      if (jsonString == null) continue;

      final data = CustomComponentData.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
      entries.add(
        CustomComponentEntry(
          data: data,
          storageName: storageName,
          spritePath: null, // Sprites not supported on web
        ),
      );
    } catch (_) {
      continue;
    }
  }

  return entries;
}

/// Sanitizes a component name to a safe storage key.
String sanitizeComponentFileName(String input) {
  final trimmed = input.trim();
  final base = trimmed.isEmpty ? 'custom_component' : trimmed;
  return base.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
}
