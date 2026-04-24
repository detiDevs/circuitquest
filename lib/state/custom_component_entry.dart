import 'package:circuitquest/core/components/custom_component_data.dart';

/// Represents a stored custom component with its metadata.
class CustomComponentEntry {
  final CustomComponentData data;
  final String? spritePath;
  final String storageName;

  CustomComponentEntry({
    required this.data,
    required this.storageName,
    this.spritePath,
  });
}
