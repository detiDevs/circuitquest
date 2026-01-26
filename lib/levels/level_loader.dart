import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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
  Future<LevelMeta> loadLevelMeta() async {
    // Return cached version if available
    if (_levelMeta != null) {
      return _levelMeta!;
    }

    try {
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
