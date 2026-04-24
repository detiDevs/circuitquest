import 'dart:convert';

import 'package:flutter/material.dart';

/// On web there is no local filesystem – return null so callers skip the
/// initialDirectory parameter for the file picker.
Future<String?> getDefaultCircuitsDirectory() async => null;

/// On web, the file-picker's [bytes] parameter already triggers a browser
/// download for save operations; no additional write is needed.
Future<void> writeBytesToFile(String path, List<int> bytes) async {}

/// On web, the picked file's content is accessed via [bytes] (the file path
/// is not available).
Future<String> readPickedFileContent({
  required String? path,
  required List<int>? bytes,
}) async {
  if (bytes == null) throw Exception('No file bytes available');
  return utf8.decode(bytes);
}

/// On web there are no file paths, so just return an empty string.
String fileNameFromPath(String path) => path;

/// On web, file-based SVG loading is not supported – return the placeholder.
Widget buildSvgFromFilePath({
  required String path,
  required double size,
  required ColorFilter colorFilter,
  required Widget Function(BuildContext) placeholderBuilder,
}) {
  return Builder(builder: placeholderBuilder);
}

/// On web, file-based image loading is not supported – return the error widget.
Widget buildImageFromFilePath({
  required String path,
  required double size,
  required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
}) {
  return Builder(
    builder: (context) => errorBuilder(context, 'web: no file access', null),
  );
}
