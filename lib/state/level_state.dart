import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../levels/level_loader.dart';
import '../levels/level.dart';

/// Provider for the LevelLoader instance
final levelLoaderProvider = Provider<LevelLoader>((ref) {
  return LevelLoader();
});

/// Provider for level metadata (completed levels, unlock status)
final levelMetaProvider = FutureProvider<LevelMeta>((ref) async {
  final loader = ref.watch(levelLoaderProvider);
  return await loader.loadLevelMeta();
});

/// Provider to check if a specific level is completed
final levelCompletedProvider = FutureProvider.family<bool, int>((ref, levelId) async {
  final meta = await ref.watch(levelMetaProvider.future);
  return meta.completedLevels.contains(levelId);
});

/// Provider to check if a specific level can be accessed
final levelAccessProvider = FutureProvider.family<bool, int>((ref, levelId) async {
  final loader = ref.watch(levelLoaderProvider);
  return await loader.canAccessLevel(levelId);
});

/// Provider for level blocks
final levelBlocksProvider = FutureProvider<Map<String, List<LevelBlockItem>>>((ref) async {
  final loader = ref.watch(levelLoaderProvider);
  return await loader.loadLevelBlocks();
});

/// Helper method to mark a level as completed and refresh the state
Future<void> markLevelCompleted(WidgetRef ref, int levelId) async {
  final loader = ref.read(levelLoaderProvider);
  await loader.completeLevel(levelId);
  
  // Invalidate providers to trigger refresh
  ref.invalidate(levelMetaProvider);
  ref.invalidate(levelCompletedProvider);
  ref.invalidate(levelAccessProvider);
}

/// Helper method to toggle all levels unlocked and refresh the state
Future<void> toggleAllLevelsUnlocked(WidgetRef ref) async {
  final loader = ref.read(levelLoaderProvider);
  await loader.toggleAllLevelsUnlocked();
  
  // Invalidate providers to trigger refresh
  ref.invalidate(levelMetaProvider);
  ref.invalidate(levelAccessProvider);
}
