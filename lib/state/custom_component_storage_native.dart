import 'dart:convert';
import 'dart:io';

import 'package:circuitquest/constants.dart';
import 'package:circuitquest/core/components/custom_component_data.dart';
import 'package:path_provider/path_provider.dart';

import 'custom_component_entry.dart';

/// Saves [data] to the filesystem. Returns true on success.
Future<bool> saveCustomComponentToPlatform(
  CustomComponentData data, {
  String? spriteSourcePath,
}) async {
  try {
    final baseDir = await _ensureBaseDirectory();
    final storageName = sanitizeComponentFileName(data.name);
    final componentDir = Directory(
      [baseDir.path, storageName].join(Platform.pathSeparator),
    );
    if (!await componentDir.exists()) {
      await componentDir.create(recursive: true);
    }

    final jsonPath =
        [componentDir.path, '$storageName.json'].join(Platform.pathSeparator);
    await File(jsonPath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(data.toJson()),
    );

    if (spriteSourcePath != null && spriteSourcePath.isNotEmpty) {
      final spriteFile = File(spriteSourcePath);
      if (await spriteFile.exists()) {
        final ext = spriteFile.path.split('.').last;
        final destPath = [componentDir.path, '$storageName.$ext']
            .join(Platform.pathSeparator);
        await spriteFile.copy(destPath);
      }
    }
    return true;
  } catch (_) {
    return false;
  }
}

/// Deletes the component with [name] from the filesystem.
/// Returns true on success.
Future<bool> deleteCustomComponentFromPlatform(String name) async {
  try {
    final storageName = sanitizeComponentFileName(name);
    final baseDir = await _ensureBaseDirectory();
    final componentDir = Directory(
      [baseDir.path, storageName].join(Platform.pathSeparator),
    );
    if (await componentDir.exists()) {
      await componentDir.delete(recursive: true);
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}

/// Loads all custom components from the filesystem.
Future<List<CustomComponentEntry>> loadCustomComponentsFromPlatform() async {
  final baseDir = await _ensureBaseDirectory();
  if (!await baseDir.exists()) return [];

  final entries = <CustomComponentEntry>[];
  final directories =
      baseDir.listSync().whereType<Directory>().toList(growable: false);

  for (final dir in directories) {
    try {
      final storageName = dir.path.split(Platform.pathSeparator).last;
      final jsonFile = File(
        [dir.path, '$storageName.json'].join(Platform.pathSeparator),
      );
      if (!await jsonFile.exists()) continue;

      final jsonString = await jsonFile.readAsString();
      final data = CustomComponentData.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      final spritePath = _findSpritePath(dir.path, storageName);
      entries.add(
        CustomComponentEntry(
          data: data,
          storageName: storageName,
          spritePath: spritePath,
        ),
      );
    } catch (_) {
      continue;
    }
  }

  return entries;
}

Future<Directory> _ensureBaseDirectory() async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final dirPath = [
    documentsDir.path,
    Constants.kAppName,
    'Custom Components',
  ].join(Platform.pathSeparator);
  final dir = Directory(dirPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

String? _findSpritePath(String dirPath, String storageName) {
  const exts = ['png', 'jpg', 'jpeg', 'svg'];
  for (final ext in exts) {
    final candidate =
        [dirPath, '$storageName.$ext'].join(Platform.pathSeparator);
    if (File(candidate).existsSync()) {
      return candidate;
    }
  }
  return null;
}

/// Sanitizes a component name to a safe filename.
String sanitizeComponentFileName(String input) {
  final trimmed = input.trim();
  final base = trimmed.isEmpty ? 'custom_component' : trimmed;
  return base.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
}
