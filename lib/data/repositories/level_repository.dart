import 'package:circuitquest/levels/level.dart';

abstract class LevelRepository {
  Future<Level> loadLevel(int levelId);
  Future<List<Level>> loadLevels(List<int> levelIds);
  Future<List<Level>> loadAllLevels({int maxLevelId = 21});
  Future<Map<String, List<LevelBlockItem>>> loadLevelBlocks();
  Future<List<LevelCategory>> loadLevelCategories();
  Future<LevelMeta> loadLevelMeta();
  Future<bool> canAccessLevel(int levelId);
  Future<void> completeLevel(int levelId);
  Future<void> toggleAllLevelsUnlocked();
  Future<bool> isLevelCompleted(int levelId);
  Future<bool> levelExists(int levelId);
  Future<int> getTotalLevelCount();
  Future<Map<String, List<int>>> getLevelsByCategory();
  Future<List<int>> getRecommendedLevels();
  Future<void> resetUserProgress();
  void clearCache();
}
