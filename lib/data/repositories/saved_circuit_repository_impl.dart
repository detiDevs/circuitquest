import 'package:circuitquest/data/repositories/saved_circuit_repository.dart';
import 'package:circuitquest/data/services/saved_circuit_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final savedCircuitStorageServiceProvider =
    Provider<SavedCircuitStorageService>(
  (ref) => SavedCircuitStorageService(),
);

final savedCircuitRepositoryProvider = Provider<SavedCircuitRepository>(
  (ref) => SavedCircuitRepositoryImpl(
    storageService: ref.read(savedCircuitStorageServiceProvider),
  ),
);

class SavedCircuitRepositoryImpl implements SavedCircuitRepository {
  SavedCircuitRepositoryImpl({
    required SavedCircuitStorageService storageService,
  }) : _storageService = storageService;

  final SavedCircuitStorageService _storageService;

  @override
  Future<String> ensureDefaultDirectory() =>
      _storageService.ensureDefaultDirectory();

  @override
  String sanitizeFileName(String input) => _storageService.sanitizeFileName(input);

  @override
  Future<void> saveCircuitFile({
    required String path,
    required String jsonString,
  }) => _storageService.saveToPath(path, jsonString);

  @override
  Future<String> readCircuitFile(String path) =>
      _storageService.readFromPath(path);
}
