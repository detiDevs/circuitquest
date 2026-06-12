import 'package:circuitquest/core/components/custom_component_data.dart';

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

abstract class CustomComponentRepository {
  List<CustomComponentEntry> get components;
  CustomComponentData? getByName(String name);
  Future<void> load();
  Future<void> refresh();
  Future<bool> saveCustomComponent(
    CustomComponentData data, {
    String? spriteSourcePath,
  });
  Future<bool> deleteCustomComponentByName(String name);
}
