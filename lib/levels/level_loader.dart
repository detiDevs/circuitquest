import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'level.dart';

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
      
      jsonData.forEach((category, items) {
        blocks[category] = (items as List<dynamic>)
            .map((item) => LevelBlockItem.fromJson(item as Map<String, dynamic>))
            .toList();
      });
      
      // Cache the result
      _levelBlocks = blocks;
      
      return blocks;
    } catch (e) {
      throw Exception('Failed to load level blocks: $e');
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

  /// Load metadata from user documents directory if it exists
  Future<LevelMeta?> _loadUserMeta() async {
    try {
      final file = await _getUserMetaFile();
      if (!await file.exists()) {
        return null;
      }
      
      final jsonString = await file.readAsString();
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return LevelMeta.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Get the path to the user meta file
  Future<File> _getUserMetaFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final questDir = Directory('${dir.path}/CircuitQuest');
    if (!await questDir.exists()) {
      await questDir.create(recursive: true);
    }
    return File('${questDir.path}/level_meta.json');
  }

  /// Save metadata to user documents directory
  Future<void> _saveUserMeta(LevelMeta meta) async {
    try {
      final file = await _getUserMetaFile();
      final jsonData = {
        'completed_levels': meta.completedLevels,
        'all_levels_unlocked': meta.allLevelsUnlocked,
      };
      await file.writeAsString(json.encode(jsonData));
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

  /// Check if a level can be accessed by the player
  /// 
  /// Returns true if the level is unlocked (either all levels unlocked,
  /// or the player has completed the previous level).
  Future<bool> canAccessLevel(int levelId) async {
    final meta = await loadLevelMeta();
    
    // If all levels are unlocked, allow access
    if (meta.allLevelsUnlocked) {
      return true;
    }
    
    // Level 0 is always accessible
    if (levelId == 0) {
      return true;
    }
    
    // Otherwise, check if previous level is completed
    return meta.completedLevels.contains(levelId - 1);
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
