import 'package:circuitquest/data/repositories/custom_component_repository.dart';
import 'package:circuitquest/data/services/custom_component_storage_service.dart';
import 'package:circuitquest/core/components/custom_component_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customComponentStorageServiceProvider =
    Provider<CustomComponentStorageService>(
  (ref) => CustomComponentStorageService(),
);

final customComponentRepositoryProvider =
    ChangeNotifierProvider<CustomComponentRepositoryImpl>(
  (ref) => CustomComponentRepositoryImpl(
    storageService: ref.read(customComponentStorageServiceProvider),
  )..load(),
);

class CustomComponentRepositoryImpl extends ChangeNotifier
    implements CustomComponentRepository {
  CustomComponentRepositoryImpl({
    required CustomComponentStorageService storageService,
  }) : _storageService = storageService;

  final CustomComponentStorageService _storageService;
  final List<CustomComponentEntry> _components = [];

  @override
  List<CustomComponentEntry> get components => List.unmodifiable(_components);

  @override
  CustomComponentData? getByName(String name) {
    for (final entry in _components) {
      if (entry.data.name == name) return entry.data;
    }
    return null;
  }

  @override
  Future<void> load() async {
    _components
      ..clear()
      ..addAll(
        (await _storageService.loadFromDisk())
            .map(
              (record) => CustomComponentEntry(
                data: record.data,
                storageName: record.storageName,
                spritePath: record.spritePath,
              ),
            )
            .toList(),
      );
    notifyListeners();
  }

  @override
  Future<void> refresh() async {
    await load();
  }

  @override
  Future<bool> saveCustomComponent(
    CustomComponentData data, {
    String? spriteSourcePath,
  }) async {
    final success = await _storageService.saveCustomComponent(
      data,
      spriteSourcePath: spriteSourcePath,
    );
    if (success) {
      await load();
    }
    return success;
  }

  @override
  Future<bool> deleteCustomComponentByName(String name) async {
    final success = await _storageService.deleteCustomComponentByName(name);
    if (success) {
      _components.removeWhere((entry) => entry.data.name == name);
      notifyListeners();
    }
    return success;
  }
}
