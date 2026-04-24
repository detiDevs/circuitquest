import 'package:circuitquest/core/components/custom_component_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'custom_component_entry.dart';
import 'custom_component_storage.dart';

export 'custom_component_entry.dart';
export 'custom_component_storage.dart' show sanitizeComponentFileName;

final customComponentProvider = ChangeNotifierProvider<CustomComponentLibrary>(
  (ref) => CustomComponentLibrary()..load(),
);

class CustomComponentLibrary extends ChangeNotifier {
  final List<CustomComponentEntry> _components = [];

  List<CustomComponentEntry> get components => List.unmodifiable(_components);

  CustomComponentData? getByName(String name) {
    for (final entry in _components) {
      if (entry.data.name == name) return entry.data;
    }
    return null;
  }

  Future<void> load() async {
    _components
      ..clear()
      ..addAll(await loadCustomComponentsFromPlatform());
    notifyListeners();
  }

  Future<void> refresh() async {
    await load();
  }

  Future<bool> saveCustomComponent(
    CustomComponentData data, {
    String? spriteSourcePath,
  }) async {
    return saveCustomComponentToPlatform(
      data,
      spriteSourcePath: spriteSourcePath,
    );
  }

  /// Deletes a custom component by the given name string.
  /// Returns true iff deletion was successful.
  Future<bool> deleteCustomComponentByName(String name) async {
    final success = await deleteCustomComponentFromPlatform(name);
    if (success) {
      _components.removeWhere((entry) => entry.data.name == name);
      notifyListeners();
    }
    return success;
  }
}