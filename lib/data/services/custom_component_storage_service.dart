import 'dart:convert';
import 'dart:io';

import 'package:circuitquest/constants.dart';
import 'package:circuitquest/core/components/custom_component_data.dart';
import 'package:path_provider/path_provider.dart';

class CustomComponentStorageRecord {
  final CustomComponentData data;
  final String? spritePath;
  final String storageName;

  CustomComponentStorageRecord({
    required this.data,
    required this.storageName,
    this.spritePath,
  });
}

class CustomComponentStorageService {
  Future<List<CustomComponentStorageRecord>> loadFromDisk() async {
    final baseDir = await _ensureBaseDirectory();
    if (!await baseDir.exists()) return [];

    final entries = <CustomComponentStorageRecord>[];
    final directories = baseDir
        .listSync()
        .whereType<Directory>()
        .toList(growable: false);

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
          CustomComponentStorageRecord(
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

  Future<bool> saveCustomComponent(
    CustomComponentData data, {
    String? spriteSourcePath,
  }) async {
    try {
      final baseDir = await _ensureBaseDirectory();
      final storageName = _sanitizeFileName(data.name);
      final componentDir = Directory(
        [baseDir.path, storageName].join(Platform.pathSeparator),
      );
      if (!await componentDir.exists()) {
        await componentDir.create(recursive: true);
      }

      final jsonPath =
          [componentDir.path, '$storageName.json'].join(Platform.pathSeparator);
      final file = File(jsonPath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data.toJson()),
      );

      if (spriteSourcePath != null && spriteSourcePath.isNotEmpty) {
        final spriteFile = File(spriteSourcePath);
        if (await spriteFile.exists()) {
          final ext = spriteFile.path.split('.').last;
          final destPath =
              [componentDir.path, '$storageName.$ext'].join(Platform.pathSeparator);
          await spriteFile.copy(destPath);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCustomComponentByName(String name) async {
    try {
      final storageName = _sanitizeFileName(name);
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

  Future<Directory> _ensureBaseDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dirPath = [documentsDir.path, Constants.kAppName, 'Custom Components']
        .join(Platform.pathSeparator);
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

  String _sanitizeFileName(String input) {
    final trimmed = input.trim();
    final base = trimmed.isEmpty ? 'custom_component' : trimmed;
    return base.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
  }
}
