# Level System Documentation

This documentation describes the level loading system for CircuitQuest.

## Overview

The level system consists of:
- **Level data models** - Dart classes representing level structure
- **LevelLoader** - Service class for loading levels from JSON assets
- **JSON level files** - Assets containing level configurations

## Level Data Structure

### Level JSON Format

Each level file (`level_X.json`) contains:

```json
{
  "level_id": 0,
  "name": "Level Name",
  "description": "Level description text",
  "difficulty": "Easy|Medium|Hard",
  "objectives": ["Objective 1", "Objective 2"],
  "components": [
    {
      "type": "Input|Output|etc",
      "position": [x, y],
      "immovable": true|false,
      "label": "Optional label"
    }
  ],
  "available_components": [
    {"type": "And|Or|Not|etc"}
  ],
  "hints": ["Hint 1", "Hint 2"],
  "tests": [
    {
      "inputs": [[value, pin], [value, pin]],
      "expected_output": [[value, pin]]
    }
  ]
}
```

### Level Blocks JSON Format

The `level_blocks.json` file organizes levels into categories:

```json
{
  "Category Name": [
    {
      "id": 0,
      "name": "Level Name",
      "recommended": true|false
    }
  ]
}
```

### Metadata JSON Format

The `meta.json` file tracks player progress:

```json
{
  "completed_levels": [0, 1, 2],
  "all_levels_unlocked": true|false
}
```

## Usage Examples

### Load a Single Level

```dart
final levelLoader = LevelLoader();
final level = await levelLoader.loadLevel(0);

print('Level: ${level.name}');
print('Difficulty: ${level.difficulty}');
print('Objectives: ${level.objectives.join(", ")}');
```

### Load Multiple Levels

```dart
final levels = await levelLoader.loadLevels([0, 1, 2]);
for (final level in levels) {
  print('Level ${level.levelId}: ${level.name}');
}
```

### Load All Levels

```dart
final allLevels = await levelLoader.loadAllLevels();
print('Total levels: ${allLevels.length}');
```

### Load Level Categories

```dart
final blocks = await levelLoader.loadLevelBlocks();
blocks.forEach((category, items) {
  print('$category: ${items.length} levels');
});
```

### Load Recommended Levels

```dart
final recommendedIds = await levelLoader.getRecommendedLevels();
final recommendedLevels = await levelLoader.loadLevels(recommendedIds);
print('Recommended levels: ${recommendedLevels.map((l) => l.name).join(", ")}');
```

### Load Player Progress

```dart
final meta = await levelLoader.loadLevelMeta();
print('Completed: ${meta.completedLevels}');
print('All unlocked: ${meta.allLevelsUnlocked}');
```

### Check if Level Exists

```dart
final exists = await levelLoader.levelExists(5);
if (exists) {
  final level = await levelLoader.loadLevel(5);
  // Use level...
}
```

## Data Models

### Level

Main data model for a complete level configuration.

**Properties:**
- `levelId` (int) - Unique identifier
- `name` (String) - Display name
- `description` (String) - Level description
- `difficulty` (String) - Difficulty level
- `objectives` (List<String>) - List of objectives
- `components` (List<LevelComponent>) - Pre-placed components
- `availableComponents` (List<AvailableComponent>) - Components player can use
- `hints` (List<String>) - Hints for the player
- `tests` (List<LevelTest>) - Test cases to validate solution

### LevelComponent

Represents a component placed on the grid.

**Properties:**
- `type` (String) - Component type (Input, Output, And, Or, etc.)
- `position` (List<int>) - [x, y] coordinates
- `immovable` (bool) - Whether player can move it
- `label` (String?) - Optional label text

### AvailableComponent

Represents a component type available for use.

**Properties:**
- `type` (String) - Component type

### LevelTest

Represents a test case for validating solutions.

**Properties:**
- `inputs` (List<List<int>>) - Input values [[value, pin], ...]
- `expectedOutput` (List<List<int>>) - Expected output values

### LevelBlockItem

Represents a level in the level selection menu.

**Properties:**
- `id` (int) - Level ID
- `name` (String) - Display name
- `recommended` (bool) - Whether level is recommended

### LevelMeta

Represents player progress metadata.

**Properties:**
- `completedLevels` (List<int>) - IDs of completed levels
- `allLevelsUnlocked` (bool) - Whether all levels are unlocked

## LevelLoader Methods

### Loading Methods

- `loadLevel(int levelId)` - Load a single level
- `loadLevels(List<int> levelIds)` - Load multiple levels
- `loadAllLevels({int maxLevelId})` - Load all available levels
- `loadLevelBlocks()` - Load level organization/categories
- `loadLevelMeta()` - Load player progress metadata

### Query Methods

- `getLevelsByCategory()` - Get level IDs organized by category
- `getRecommendedLevels()` - Get IDs of recommended levels
- `getTotalLevelCount()` - Get total number of available levels
- `levelExists(int levelId)` - Check if a level exists

### Cache Management

- `clearCache()` - Clear all cached level data

## Caching

The `LevelLoader` implements intelligent caching:
- Individual levels are cached after first load
- Level blocks are cached
- Metadata is cached
- Use `clearCache()` to force reload

## Error Handling

All loading methods may throw exceptions if:
- Asset file is missing
- JSON is malformed
- Data doesn't match expected structure

Always wrap loading calls in try-catch blocks:

```dart
try {
  final level = await levelLoader.loadLevel(999);
} catch (e) {
  print('Failed to load level: $e');
}
```

## Integration with Flutter

The level loader is designed to work seamlessly with Flutter's asset system. Ensure `pubspec.yaml` includes:

```yaml
flutter:
  assets:
    - assets/levels/
```

## Available Levels

The system currently supports levels 0-21, organized into categories:
- **Basic Gates** - AND, OR, NOT gates and functional completeness
- **Further Gates** - Multiplexers, decoders, collectors
- **Persistence** - Flip-flops and latches
- **Adders** - Half adders, full adders, subtraction
- **Arithmetic-logical-unit** - ALU components and operations
- **Registers** - Register blocks and write operations

See [level_blocks.json](../../assets/levels/level_blocks.json) for the complete organization.
