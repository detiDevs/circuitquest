import 'package:circuitquest/data/repositories/level_repository.dart';
import 'package:circuitquest/data/services/level_loader_service.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final levelLoaderServiceProvider = Provider<LevelLoader>(
  (ref) => LevelLoader(),
);

final levelRepositoryProvider = Provider<LevelRepository>(
  (ref) => LevelRepositoryImpl(loader: ref.read(levelLoaderServiceProvider)),
);

class LevelRepositoryImpl implements LevelRepository {
  LevelRepositoryImpl({required LevelLoader loader}) : _loader = loader;

  final LevelLoader _loader;

  @override
  Future<Level> loadLevel(int levelId) => _loader.loadLevel(levelId);

  @override
  Future<List<Level>> loadLevels(List<int> levelIds) =>
      _loader.loadLevels(levelIds);

  @override
  Future<List<Level>> loadAllLevels({int maxLevelId = 21}) =>
      _loader.loadAllLevels(maxLevelId: maxLevelId);

  @override
  Future<Map<String, List<LevelBlockItem>>> loadLevelBlocks() =>
      _loader.loadLevelBlocks();

  @override
  Future<List<LevelCategory>> loadLevelCategories() =>
      _loader.loadLevelCategories();

  @override
  Future<LevelMeta> loadLevelMeta() => _loader.loadLevelMeta();

  @override
  Future<bool> canAccessLevel(int levelId) => _loader.canAccessLevel(levelId);

  @override
  Future<void> completeLevel(int levelId) => _loader.completeLevel(levelId);

  @override
  Future<void> toggleAllLevelsUnlocked() => _loader.toggleAllLevelsUnlocked();

  @override
  Future<bool> isLevelCompleted(int levelId) => _loader.isLevelCompleted(levelId);

  @override
  Future<bool> levelExists(int levelId) => _loader.levelExists(levelId);

  @override
  Future<int> getTotalLevelCount() => _loader.getTotalLevelCount();

  @override
  Future<Map<String, List<int>>> getLevelsByCategory() =>
      _loader.getLevelsByCategory();

  @override
  Future<List<int>> getRecommendedLevels() =>
      _loader.getRecommendedLevels();

  @override
  Future<void> resetUserProgress() => _loader.resetUserProgress();

  @override
  void clearCache() => _loader.clearCache();
}
