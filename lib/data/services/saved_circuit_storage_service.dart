import 'dart:io';

import 'package:circuitquest/constants.dart';
import 'package:path_provider/path_provider.dart';

class SavedCircuitStorageService {
  Future<String> ensureDefaultDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dirPath = [
      documentsDir.path,
      Constants.kAppName,
      'Saved Circuits',
    ].join(Platform.pathSeparator);
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  String sanitizeFileName(String input) {
    final trimmed = input.trim();
    final base = trimmed.isEmpty ? 'circuit' : trimmed;
    return base.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
  }

  Future<void> saveToPath(String path, String jsonString) async {
    final outFile = File(path);
    await outFile.parent.create(recursive: true);
    await outFile.writeAsString(jsonString, flush: true);
  }

  Future<String> readFromPath(String path) async {
    final file = File(path);
    return await file.readAsString();
  }
}
