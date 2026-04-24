import 'dart:convert';
import 'package:circuitquest/constants.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'level.dart';

const _kMetaPrefsKey = '${Constants.kAppName}_level_meta';

/// Service class for loading level data from JSON assets
class LevelLoader {
  /// Cache for loaded levels to avoid redundant loading
  final Map<int, Level> _levelCache = {};
  
  /// Cache for level blocks
  Map<String, List<LevelBlockItem>>? _levelBlocks;
  
  /// Cache for level metadata
  LevelMeta? _levelMeta;

  /// Load a specific level by ID
  /// 
  /// Returns the Level object for the specified ID.
  /// Throws an exception if the level file cannot be loaded or parsed.
  Future<Level> loadLevel(int levelId) async {
    // Check cache first
    if (_levelCache.containsKey(levelId)) {
      return _levelCache[levelId]!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/levels/level_$levelId.json',
      );
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final level = Level.fromJson(jsonData);
      
      // Cache the loaded level
      _levelCache[levelId] = level;
      
      return level;
    } catch (e) {
      throw Exception('Failed to load level $levelId: $e');
    }
  }

  /// Load multiple levels by IDs
  /// 
  /// Returns a list of Level objects in the order of the provided IDs.
  Future<List<Level>> loadLevels(List<int> levelIds) async {
    final List<Level> levels = [];
    
    for (final id in levelIds) {
      final level = await loadLevel(id);
      levels.add(level);
    }
    
    return levels;
  }

  /// Load all levels from 0 to maxLevelId (inclusive)
  /// 
  /// Returns a list of all levels in order.
  /// Skips levels that fail to load and continues with the next.
  Future<List<Level>> loadAllLevels({int maxLevelId = 21}) async {
    final List<Level> levels = [];
    
    for (int i = 0; i <= maxLevelId; i++) {
      try {
        final level = await loadLevel(i);
        levels.add(level);
      } catch (e) {
        // Skip levels that fail to load
        print('Warning: Could not load level $i: $e');
      }
    }
    
    return levels;
  }

  /// Load the level blocks configuration
  /// 
  /// Returns a map where keys are category names and values are lists of level items.
  Future<Map<String, List<LevelBlockItem>>> loadLevelBlocks() async {
    // Return cached version if available
    if (_levelBlocks != null) {
      return _levelBlocks!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/levels/level_blocks.json',
      );
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final Map<String, List<LevelBlockItem>> blocks = {};
      
      // Check if using new structure with categories array
      if (jsonData.containsKey('categories')) {
        final categories = jsonData['categories'] as List<dynamic>;
        for (final categoryData in categories) {
          final categoryMap = categoryData as Map<String, dynamic>;
          final categoryName = categoryMap['name'] as String;
          final levels = (categoryMap['levels'] as List<dynamic>)
              .map((item) => LevelBlockItem.fromJson(item as Map<String, dynamic>))
              .toList();
          blocks[categoryName] = levels;
        }
      } else {
        // Fallback to old structure for backwards compatibility
        jsonData.forEach((category, items) {
          blocks[category] = (items as List<dynamic>)
              .map((item) => LevelBlockItem.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      }
      
      // Cache the result
      _levelBlocks = blocks;
      
      return blocks;
    } catch (e) {
      throw Exception('Failed to load level blocks: $e');
    }
  }

  /// Load the level categories with localization support
  /// 
  /// Returns a list of LevelCategory objects containing category metadata and levels.
  Future<List<LevelCategory>> loadLevelCategories() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/levels/level_blocks.json',
      );
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Check if using new structure with categories array
      if (jsonData.containsKey('categories')) {
        final categories = (jsonData['categories'] as List<dynamic>)
            .map((categoryData) => LevelCategory.fromJson(categoryData as Map<String, dynamic>))
            .toList();
        return categories;
      } else {
        // Fallback to old structure - create categories without translations
        final List<LevelCategory> categories = [];
        jsonData.forEach((categoryName, items) {
          final levels = (items as List<dynamic>)
              .map((item) => LevelBlockItem.fromJson(item as Map<String, dynamic>))
              .toList();
          categories.add(LevelCategory(
            name: categoryName as String,
            levels: levels,
          ));
        });
        return categories;
      }
    } catch (e) {
      throw Exception('Failed to load level categories: $e');
    }
  }

  /// Load level metadata (progression info)
  /// 
  /// Returns the LevelMeta object containing completed levels and unlock status.
  /// First tries to load from user documents directory, falls back to assets.
  Future<LevelMeta> loadLevelMeta() async {
    // Return cached version if available
    if (_levelMeta != null) {
      return _levelMeta!;
    }

    try {
      // Try to load from user data directory first
      final userMeta = await _loadUserMeta();
      if (userMeta != null) {
        _levelMeta = userMeta;
        return userMeta;
      }
      
      // Fall back to assets
      final String jsonString = await rootBundle.loadString(
        'assets/levels/meta.json',
      );
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final meta = LevelMeta.fromJson(jsonData);
      
      // Cache the result
      _levelMeta = meta;
      
      return meta;
    } catch (e) {
      throw Exception('Failed to load level metadata: $e');
    }
  }

  /// Load metadata from shared preferences if it exists
  Future<LevelMeta?> _loadUserMeta() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kMetaPrefsKey);
      if (jsonString == null) return null;
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return LevelMeta.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Save metadata to shared preferences
  Future<void> _saveUserMeta(LevelMeta meta) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = {
        'completed_levels': meta.completedLevels,
        'all_levels_unlocked': meta.allLevelsUnlocked,
      };
      await prefs.setString(_kMetaPrefsKey, json.encode(jsonData));
    } catch (e) {
      print('Warning: Failed to save level metadata: $e');
    }
  }

  /// Get all level IDs organized by category
  /// 
  /// Returns a map where keys are category names and values are lists of level IDs.
  Future<Map<String, List<int>>> getLevelsByCategory() async {
    final blocks = await loadLevelBlocks();
    
    final Map<String, List<int>> categorizedLevels = {};
    
    blocks.forEach((category, items) {
      categorizedLevels[category] = items.map((item) => item.id).toList();
    });
    
    return categorizedLevels;
  }

  /// Get all recommended level IDs
  /// 
  /// Returns a list of level IDs that are marked as recommended.
  Future<List<int>> getRecommendedLevels() async {
    final blocks = await loadLevelBlocks();
    
    final List<int> recommendedLevels = [];
    
    blocks.forEach((category, items) {
      for (final item in items) {
        if (item.recommended) {
          recommendedLevels.add(item.id);
        }
      }
    });
    
    return recommendedLevels;
  }

  /// Clear all caches
  /// 
  /// Useful for forcing a reload of all level data.
  void clearCache() {
    _levelCache.clear();
    _levelBlocks = null;
    _levelMeta = null;
  }

  /// Reset user progress (completed levels / unlock flag)
  ///
  /// Clears any persisted user metadata and replaces it with a default empty
  /// meta (no completed levels, locked progression). This makes the
  /// application behave as if the user has not completed any levels.
  Future<void> resetUserProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kMetaPrefsKey);
    } catch (e) {
      // Ignore deletion errors but log for debugging
      print('Warning: Failed to delete user meta: $e');
    }

    // Replace in-memory meta with default empty meta and persist it so
    // subsequent loads read the cleared state.
    final defaultMeta = LevelMeta(completedLevels: <int>[], allLevelsUnlocked: false);
    _levelMeta = defaultMeta;
    await _saveUserMeta(defaultMeta);
  }

  /// Check if a level can be accessed by the player
  /// 
  /// Returns true if the level with the given [levelId] is unlocked.
  /// That is the case if:
  /// - allLevelsUnlocked flag is set to true
  /// - the user has completed the previous non-bonus level in the list from [levelBlocks]
  /// - the user has completed the [required_level], if any. In that case the previous condition will not be relevant
  Future<bool> canAccessLevel(int levelId) async {
    final meta = await loadLevelMeta();
    final blocks = await loadLevelBlocks();
    
    // If all levels are unlocked, allow access
    if (meta.allLevelsUnlocked) {
      return true;
    }
    
    // Level 0 is always accessible
    if (levelId == 0) {
      return true;
    }

    // Completed levels are always replayable
    if (meta.completedLevels.contains(levelId)) {
      return true;
    }

    // Build a flat ordered list from level blocks to evaluate progression
    final orderedLevels = <LevelBlockItem>[];
    blocks.forEach((_, items) {
      orderedLevels.addAll(items);
    });

    final currentLevelIndex = orderedLevels.indexWhere((item) => item.id == levelId);

    // If level is not part of configured blocks, treat as inaccessible
    if (currentLevelIndex == -1) {
      return false;
    }

    final currentLevelItem = orderedLevels[currentLevelIndex];

    // Explicit prerequisite overrides sequential progression
    if (currentLevelItem.requiredLevelId != null) {
      return meta.completedLevels.contains(currentLevelItem.requiredLevelId);
    }

    // First configured level is always accessible
    if (currentLevelIndex == 0) {
      return true;
    }

    // Progression ignores bonus levels: only previous non-bonus levels gate access
    int previousNonBonusIndex = currentLevelIndex - 1;
    while (
      previousNonBonusIndex >= 0 &&
      orderedLevels[previousNonBonusIndex].isBonus
    ) {
      previousNonBonusIndex--;
    }

    // If no non-bonus level exists before this one, it is accessible
    if (previousNonBonusIndex < 0) {
      return true;
    }

    final previousRequiredLevelId = orderedLevels[previousNonBonusIndex].id;
    return meta.completedLevels.contains(previousRequiredLevelId);
  }

  /// Mark a level as completed
  /// 
  /// Adds the level ID to the completed levels list if not already present.
  /// Persists the change to the user data directory.
  Future<void> completeLevel(int levelId) async {
    // Reload meta to ensure we have latest data
    _levelMeta = null;
    final meta = await loadLevelMeta();
    
    if (!meta.completedLevels.contains(levelId)) {
      meta.completedLevels.add(levelId);
      _levelMeta = meta;
      await _saveUserMeta(meta);
    }
  }

  /// Toggle the all_levels_unlocked flag
  /// 
  /// Toggles whether all levels are unlocked for testing purposes.
  /// Persists the change to the user data directory.
  Future<void> toggleAllLevelsUnlocked() async {
    // Reload meta to ensure we have latest data
    _levelMeta = null;
    final meta = await loadLevelMeta();
    
    meta.allLevelsUnlocked = !meta.allLevelsUnlocked;
    _levelMeta = meta;
    await _saveUserMeta(meta);
  }

  /// Check if a level is completed
  /// 
  /// Returns true if the level ID is in the completed levels list.
  Future<bool> isLevelCompleted(int levelId) async {
    final meta = await loadLevelMeta();
    return meta.completedLevels.contains(levelId);
  }

  /// Check if a level exists and can be loaded
  /// 
  /// Returns true if the level file exists and can be loaded.
  Future<bool> levelExists(int levelId) async {
    try {
      await loadLevel(levelId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the total number of available levels
  /// 
  /// Scans for level files and returns the count.
  Future<int> getTotalLevelCount() async {
    final blocks = await loadLevelBlocks();
    
    int count = 0;
    blocks.forEach((category, items) {
      count += items.length;
    });
    
    return count;
  }
}
