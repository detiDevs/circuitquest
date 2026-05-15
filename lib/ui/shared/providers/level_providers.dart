import 'package:circuitquest/data/repositories/level_repository_impl.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/ui/sandbox_mode/view_models/sandbox_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for level metadata (completed levels, unlock status)
final levelMetaProvider = FutureProvider<LevelMeta>((ref) async {
  final repository = ref.watch(levelRepositoryProvider);
  return await repository.loadLevelMeta();
});

/// Provider to check if a specific level is completed
final levelCompletedProvider = FutureProvider.family<bool, int>(
  (ref, levelId) async {
    final meta = await ref.watch(levelMetaProvider.future);
    return meta.completedLevels.contains(levelId);
  },
);

/// Provider to check if a specific level can be accessed
final levelAccessProvider = FutureProvider.family<bool, int>(
  (ref, levelId) async {
    final repository = ref.watch(levelRepositoryProvider);
    return await repository.canAccessLevel(levelId);
  },
);

/// Provider for level blocks
final levelBlocksProvider = FutureProvider<Map<String, List<LevelBlockItem>>>(
  (ref) async {
    final repository = ref.watch(levelRepositoryProvider);
    return await repository.loadLevelBlocks();
  },
);

/// Provider for level categories with localization support
final levelCategoriesProvider = FutureProvider<List<LevelCategory>>(
  (ref) async {
    final repository = ref.watch(levelRepositoryProvider);
    return await repository.loadLevelCategories();
  },
);

/// Helper method to mark a level as completed and refresh the state
Future<void> markLevelCompleted(WidgetRef ref, int levelId) async {
  final repository = ref.read(levelRepositoryProvider);
  await repository.completeLevel(levelId);

  // Invalidate providers to trigger refresh
  ref.invalidate(levelMetaProvider);
  ref.invalidate(levelCompletedProvider);
  ref.invalidate(levelAccessProvider);
}

/// Provider for current level's clock configuration
final currentLevelClockProvider = StateProvider<ClockConfig?>((ref) => null);

/// Provider tracking how many hints are revealed for a level.
final levelRevealedHintsCountProvider = StateProvider.family<int, int>(
  (ref, levelId) => 0,
);

/// Helper method to initialize clock for current level
void initializeLevelClock(WidgetRef ref, Level level) {
  final clockConfig = level.clockConfig;
  ref.read(currentLevelClockProvider.notifier).state = clockConfig;

  // Initialize clock in sandbox state
  final sandbox = ref.read(sandboxProvider);
  sandbox.initializeClockFromLevel(clockConfig);
}

/// Helper method to reset level clock
void resetLevelClock(WidgetRef ref) {
  ref.read(currentLevelClockProvider.notifier).state = null;
}

/// Reveal one more hint for a level, up to [totalHints].
void revealNextLevelHint(WidgetRef ref, int levelId, int totalHints) {
  final notifier = ref.read(levelRevealedHintsCountProvider(levelId).notifier);
  if (notifier.state < totalHints) {
    notifier.state++;
  }
}

/// Helper method to toggle all levels unlocked and refresh the state
Future<void> toggleAllLevelsUnlocked(WidgetRef ref) async {
  final repository = ref.read(levelRepositoryProvider);
  await repository.toggleAllLevelsUnlocked();

  // Invalidate providers to trigger refresh
  ref.invalidate(levelMetaProvider);
  ref.invalidate(levelAccessProvider);
}
