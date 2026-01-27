import 'package:flutter_test/flutter_test.dart';
import 'package:circuitquest/levels/level_loader.dart';

void main() {
  // Set up the test environment to load assets
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LevelLoader Tests', () {
    late LevelLoader levelLoader;

    setUp(() {
      levelLoader = LevelLoader();
    });

    test('Load single level', () async {
      final level = await levelLoader.loadLevel(0);
      
      expect(level.levelId, 0);
      expect(level.name, 'AND Gate');
      expect(level.difficulty, 'Easy');
      expect(level.components.length, greaterThan(0));
      expect(level.availableComponents.length, greaterThan(0));
      expect(level.tests.length, greaterThan(0));
    });

    test('Load level with correct structure', () async {
      final level = await levelLoader.loadLevel(1);
      
      expect(level.levelId, 1);
      expect(level.name, 'OR Gate');
      expect(level.objectives, isNotEmpty);
      expect(level.hints, isNotEmpty);
    });

    test('Load level blocks', () async {
      final blocks = await levelLoader.loadLevelBlocks();
      
      expect(blocks, isNotEmpty);
      expect(blocks.containsKey('Basic Gates'), true);
      expect(blocks.containsKey('Further Gates'), true);
    });

    test('Load level metadata', () async {
      final meta = await levelLoader.loadLevelMeta();
      
      expect(meta.completedLevels, isA<List<int>>());
      expect(meta.allLevelsUnlocked, isA<bool>());
    });

    test('Get recommended levels', () async {
      final recommendedIds = await levelLoader.getRecommendedLevels();
      
      expect(recommendedIds, isNotEmpty);
      expect(recommendedIds, contains(0));
    });

    test('Get levels by category', () async {
      final categorized = await levelLoader.getLevelsByCategory();
      
      expect(categorized, isNotEmpty);
      expect(categorized['Basic Gates'], isNotEmpty);
    });

    test('Check level exists', () async {
      final exists = await levelLoader.levelExists(0);
      expect(exists, true);
    });

    test('Level caching works', () async {
      // Load level twice
      final level1 = await levelLoader.loadLevel(0);
      final level2 = await levelLoader.loadLevel(0);
      
      // Should return same instance from cache
      expect(identical(level1, level2), true);
    });

    test('Clear cache works', () async {
      await levelLoader.loadLevel(0);
      levelLoader.clearCache();
      
      // Cache should be empty
      final level = await levelLoader.loadLevel(0);
      expect(level, isNotNull);
    });

    test('Level components have correct structure', () async {
      final level = await levelLoader.loadLevel(0);
      
      final inputs = level.components.where((c) => c.type == 'Input').toList();
      expect(inputs.length, 2);
      
      for (final input in inputs) {
        expect(input.position.length, 2);
        expect(input.immovable, true);
        expect(input.label, isNotNull);
      }
    });

    test('Level tests have correct structure', () async {
      final level = await levelLoader.loadLevel(0);
      
      expect(level.tests.length, 4); // AND gate has 4 test cases
      
      for (final test in level.tests) {
        expect(test.inputs, isNotEmpty);
        expect(test.expectedOutput, isNotEmpty);
      }
    });
  });
}
