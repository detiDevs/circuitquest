import 'level.dart';
import 'level_loader.dart';

/// Utility class providing helper functions for working with levels
class LevelUtils {
  /// Get all levels for a specific difficulty
  static Future<List<Level>> getLevelsByDifficulty(
    LevelLoader loader,
    String difficulty,
  ) async {
    final allLevels = await loader.loadAllLevels();
    return allLevels
        .where((level) => level.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }

  /// Get levels that match a search query (searches name and description)
  static Future<List<Level>> searchLevels(
    LevelLoader loader,
    String query,
  ) async {
    final allLevels = await loader.loadAllLevels();
    final lowerQuery = query.toLowerCase();
    
    return allLevels.where((level) {
      return level.name.toLowerCase().contains(lowerQuery) ||
          level.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get levels that use a specific component type
  static Future<List<Level>> getLevelsWithComponent(
    LevelLoader loader,
    String componentType,
  ) async {
    final allLevels = await loader.loadAllLevels();
    
    return allLevels.where((level) {
      return level.availableComponents.any((comp) => comp.type == componentType);
    }).toList();
  }

  /// Calculate level completion percentage based on metadata
  static Future<double> getCompletionPercentage(LevelLoader loader) async {
    final meta = await loader.loadLevelMeta();
    final totalCount = await loader.getTotalLevelCount();
    
    if (totalCount == 0) return 0.0;
    return (meta.completedLevels.length / totalCount) * 100;
  }

  /// Check if a level is completed
  static Future<bool> isLevelCompleted(LevelLoader loader, int levelId) async {
    final meta = await loader.loadLevelMeta();
    return meta.completedLevels.contains(levelId);
  }

  /// Get the next uncompleted level
  static Future<Level?> getNextUncompletedLevel(LevelLoader loader) async {
    final meta = await loader.loadLevelMeta();
    final allLevels = await loader.loadAllLevels();
    
    for (final level in allLevels) {
      if (!meta.completedLevels.contains(level.levelId)) {
        return level;
      }
    }
    
    return null; // All levels completed
  }

  /// Get statistics for a level (number of inputs, outputs, available components)
  static Map<String, int> getLevelStatistics(Level level) {
    final inputs = level.components.where((c) => c.type == 'Input').length;
    final outputs = level.components.where((c) => c.type == 'Output').length;
    
    return {
      'inputs': inputs,
      'outputs': outputs,
      'preplacedComponents': level.components.length,
      'availableComponentTypes': level.availableComponents.length,
      'testCases': level.tests.length,
      'objectives': level.objectives.length,
      'hints': level.hints.length,
    };
  }

  /// Get all unique component types used across all levels
  static Future<Set<String>> getAllComponentTypes(LevelLoader loader) async {
    final allLevels = await loader.loadAllLevels();
    final componentTypes = <String>{};
    
    for (final level in allLevels) {
      for (final comp in level.components) {
        componentTypes.add(comp.type);
      }
      for (final comp in level.availableComponents) {
        componentTypes.add(comp.type);
      }
    }
    
    return componentTypes;
  }

  /// Validate level data structure
  static List<String> validateLevel(Level level) {
    final errors = <String>[];
    
    if (level.name.isEmpty) {
      errors.add('Level name is empty');
    }
    
    if (level.components.isEmpty) {
      errors.add('Level has no components');
    }
    
    if (level.tests.isEmpty) {
      errors.add('Level has no test cases');
    }
    
    if (level.objectives.isEmpty) {
      errors.add('Level has no objectives');
    }
    
    final inputs = level.components.where((c) => c.type == 'Input').toList();
    final outputs = level.components.where((c) => c.type == 'Output').toList();
    
    if (inputs.isEmpty) {
      errors.add('Level has no inputs');
    }
    
    if (outputs.isEmpty) {
      errors.add('Level has no outputs');
    }
    
    // Validate test cases match input/output count
    for (int i = 0; i < level.tests.length; i++) {
      final test = level.tests[i];
      if (test.inputs.length != inputs.length) {
        errors.add('Test case $i: input count mismatch (expected ${inputs.length}, got ${test.inputs.length})');
      }
      if (test.expectedOutput.length != outputs.length) {
        errors.add('Test case $i: output count mismatch (expected ${outputs.length}, got ${test.expectedOutput.length})');
      }
    }
    
    return errors;
  }

  /// Get level progression path (levels in order by ID)
  static Future<List<Level>> getProgressionPath(
    LevelLoader loader,
    String category,
  ) async {
    final blocks = await loader.loadLevelBlocks();
    
    if (!blocks.containsKey(category)) {
      return [];
    }
    
    final levelIds = blocks[category]!.map((item) => item.id).toList();
    return await loader.loadLevels(levelIds);
  }

  /// Format level difficulty with emoji
  static String getDifficultyDisplay(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '🟢 Easy';
      case 'medium':
        return '🟡 Medium';
      case 'hard':
        return '🔴 Hard';
      default:
        return difficulty;
    }
  }

  /// Get estimated completion time based on difficulty
  static String getEstimatedTime(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '5-10 minutes';
      case 'medium':
        return '10-20 minutes';
      case 'hard':
        return '20-40 minutes';
      default:
        return 'Unknown';
    }
  }
}
