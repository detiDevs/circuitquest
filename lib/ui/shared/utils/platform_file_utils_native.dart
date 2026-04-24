import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:circuitquest/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Returns the default save directory path for circuits, creating it if needed.
Future<String?> getDefaultCircuitsDirectory() async {
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

/// Writes [bytes] to the file at [path].
Future<void> writeBytesToFile(String path, List<int> bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
}

/// Reads the file at [path] as a UTF-8 string.
/// On native platforms, uses the file [path] from the picker result.
/// [bytes] is ignored.
Future<String> readPickedFileContent({
  required String? path,
  required List<int>? bytes,
}) async {
  if (path == null) throw Exception('No file path available');
  return File(path).readAsString();
}

/// Returns the last path component (filename) from a full path.
/// Handles trailing separators and empty paths gracefully.
String fileNameFromPath(String path) {
  if (path.isEmpty) return path;
  final segments = path.split(Platform.pathSeparator);
  return segments.lastWhere((s) => s.isNotEmpty, orElse: () => path);
}

/// Builds a widget to display an SVG from a local file path.
Widget buildSvgFromFilePath({
  required String path,
  required double size,
  required ColorFilter colorFilter,
  required Widget Function(BuildContext) placeholderBuilder,
}) {
  return SvgPicture.file(
    File(path),
    colorFilter: colorFilter,
    fit: BoxFit.contain,
    placeholderBuilder: placeholderBuilder,
  );
}

/// Builds a widget to display a raster image from a local file path.
Widget buildImageFromFilePath({
  required String path,
  required double size,
  required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
}) {
  return Image.file(
    File(path),
    fit: BoxFit.contain,
    errorBuilder: errorBuilder,
  );
}
