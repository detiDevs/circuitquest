/// Data model representing a circuit component in a level
class LevelComponent {
  final String type;
  final List<int> position;
  final bool immovable;
  final String? label;

  LevelComponent({
    required this.type,
    required this.position,
    required this.immovable,
    this.label,
  });

  factory LevelComponent.fromJson(Map<String, dynamic> json) {
    return LevelComponent(
      type: json['type'] as String,
      position: (json['position'] as List<dynamic>).cast<int>(),
      immovable: json['immovable'] as bool? ?? false,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'position': position,
      'immovable': immovable,
      if (label != null) 'label': label,
    };
  }
}

/// Data model representing an available component in a level
class AvailableComponent {
  final String type;

  AvailableComponent({required this.type});

  factory AvailableComponent.fromJson(Map<String, dynamic> json) {
    return AvailableComponent(
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}

/// Data model representing a test case for a level
class LevelTest {
  final List<List<int>> inputs;
  final List<List<int>> expectedOutput;

  LevelTest({
    required this.inputs,
    required this.expectedOutput,
  });

  factory LevelTest.fromJson(Map<String, dynamic> json) {
    return LevelTest(
      inputs: (json['inputs'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).cast<int>())
          .toList(),
      expectedOutput: (json['expected_output'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).cast<int>())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inputs': inputs,
      'expected_output': expectedOutput,
    };
  }
}

/// Data model representing a complete level
class Level {
  final int levelId;
  final String name;
  final String description;
  final String difficulty;
  final List<String> objectives;
  final List<LevelComponent> components;
  final List<AvailableComponent> availableComponents;
  final List<String> hints;
  final List<LevelTest> tests;

  Level({
    required this.levelId,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.objectives,
    required this.components,
    required this.availableComponents,
    required this.hints,
    required this.tests,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      levelId: json['level_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      objectives: (json['objectives'] as List<dynamic>).cast<String>(),
      components: (json['components'] as List<dynamic>)
          .map((e) => LevelComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableComponents: (json['available_components'] as List<dynamic>)
          .map((e) => AvailableComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      hints: (json['hints'] as List<dynamic>).cast<String>(),
      tests: (json['tests'] as List<dynamic>)
          .map((e) => LevelTest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level_id': levelId,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'objectives': objectives,
      'components': components.map((c) => c.toJson()).toList(),
      'available_components':
          availableComponents.map((c) => c.toJson()).toList(),
      'hints': hints,
      'tests': tests.map((t) => t.toJson()).toList(),
    };
  }
}

/// Data model representing a level block item
class LevelBlockItem {
  final int id;
  final String name;
  final bool recommended;

  LevelBlockItem({
    required this.id,
    required this.name,
    this.recommended = false,
  });

  factory LevelBlockItem.fromJson(Map<String, dynamic> json) {
    return LevelBlockItem(
      id: json['id'] as int,
      name: json['name'] as String,
      recommended: json['recommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'recommended': recommended,
    };
  }
}

/// Data model representing level progression metadata
class LevelMeta {
  final List<int> completedLevels;
  bool allLevelsUnlocked;

  LevelMeta({
    required this.completedLevels,
    required this.allLevelsUnlocked,
  });

  factory LevelMeta.fromJson(Map<String, dynamic> json) {
    return LevelMeta(
      completedLevels: (json['completed_levels'] as List<dynamic>).cast<int>(),
      allLevelsUnlocked: json['all_levels_unlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_levels': completedLevels,
      'all_levels_unlocked': allLevelsUnlocked,
    };
  }
}
