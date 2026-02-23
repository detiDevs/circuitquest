import 'package:circuitquest/state/sandbox_state.dart';

/// Data model representing a circuit component in a level
class LevelComponent {
  final String type;
  final List<int> position;
  final bool immovable;
  final String? label;
  final int? initialValue;
  final int? initialBitWidth;
  final List<int>? initialRegisterValues;

  LevelComponent({
    required this.type,
    required this.position,
    required this.immovable,
    this.label,
    this.initialValue,
    this.initialBitWidth,
    this.initialRegisterValues,
  });

  factory LevelComponent.fromJson(Map<String, dynamic> json) {
    final initialValueJson = json['initialValue'];
    final bool isListValue = initialValueJson is List;
    
    return LevelComponent(
      type: json['type'] as String,
      position: (json['position'] as List<dynamic>).cast<int>(),
      immovable: json['immovable'] as bool? ?? false,
      label: json['label'] as String?,
      initialValue: isListValue ? null : (initialValueJson as int?),
      initialBitWidth: json['initialBitWidth'] as int?,
      initialRegisterValues: isListValue
          ? List<int>.from(initialValueJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'position': position,
      'immovable': immovable,
      if (label != null) 'label': label,
      if (initialValue != null) 'initialValue': initialValue,
      if (initialBitWidth != null) 'initialBitWidth': initialBitWidth,
      if (initialRegisterValues != null) 'initialValue': initialRegisterValues,
    };
  }
}

/// Data model representing an available component in a level
class AvailableComponent {
  final String type;

  AvailableComponent({required this.type});

  factory AvailableComponent.fromJson(Map<String, dynamic> json) {
    return AvailableComponent(type: json['type'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'type': type};
  }
}

/// Data model representing a test case for a level
class LevelTest {
  final List<List<int>> inputs;
  final List<List<int>> expectedOutput;

  LevelTest({required this.inputs, required this.expectedOutput});

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
    return {'inputs': inputs, 'expected_output': expectedOutput};
  }
}

/// Memory contents for level initialization
class MemoryContents {
  final List<int> instructionMemory;
  final List<int> dataMemory;

  MemoryContents({
    required this.instructionMemory,
    required this.dataMemory,
  });

  factory MemoryContents.fromJson(Map<String, dynamic> json) {
    return MemoryContents(
      instructionMemory: (json['instructionMemory'] as List<dynamic>? ?? []).cast<int>(),
      dataMemory: (json['dataMemory'] as List<dynamic>? ?? []).cast<int>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instructionMemory': instructionMemory,
      'dataMemory': dataMemory,
    };
  }
}

/// Data model representing a complete level
class Level {
  final int levelId;
  final String name;
  final String? nameDe;
  final String description;
  final String? descriptionDe;
  final String difficulty;
  final String? difficultyDe;
  final List<String> objectives;
  final List<String>? objectivesDe;
  final List<LevelComponent> components;
  final List<AvailableComponent> availableComponents;
  final List<WireConnection> connections;
  final List<String> hints;
  final List<String>? hintsDe;
  final List<LevelTest> tests;
  final MemoryContents? memoryContents;

  Level({
    required this.levelId,
    required this.name,
    this.nameDe,
    required this.description,
    this.descriptionDe,
    required this.difficulty,
    this.difficultyDe,
    required this.objectives,
    this.objectivesDe,
    required this.components,
    required this.availableComponents,
    required this.connections,
    required this.hints,
    this.hintsDe,
    required this.tests,
    this.memoryContents,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      levelId: json['level_id'] as int,
      name: json['name'] as String,
      nameDe: json['name_de'] as String?,
      description: json['description'] as String,
      descriptionDe: json['description_de'] as String?,
      difficulty: json['difficulty'] as String,
      difficultyDe: json['difficulty_de'] as String?,
      objectives: (json['objectives'] as List<dynamic>).cast<String>(),
      objectivesDe: (json['objectives_de'] as List<dynamic>?)?.cast<String>(),
      components: (json['components'] as List<dynamic>)
          .map((e) => LevelComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableComponents: (json['available_components'] as List<dynamic>)
          .map((e) => AvailableComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      connections: ((json['connections'] ?? []) as List<dynamic>)
          .map((e) => WireConnection.fromJson(e as Map<String, dynamic>))
          .toList(),
      hints: (json['hints'] as List<dynamic>).cast<String>(),
      hintsDe: (json['hints_de'] as List<dynamic>?)?.cast<String>(),
      tests: ((json['tests'] ?? []) as List<dynamic>)
          .map((e) => LevelTest.fromJson(e as Map<String, dynamic>))
          .toList(),
      memoryContents: json['memoryContents'] != null
          ? MemoryContents.fromJson(json['memoryContents'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level_id': levelId,
      'name': name,
      if (nameDe != null) 'name_de': nameDe,
      'description': description,
      if (descriptionDe != null) 'description_de': descriptionDe,
      'difficulty': difficulty,
      if (difficultyDe != null) 'difficulty_de': difficultyDe,
      'objectives': objectives,
      if (objectivesDe != null) 'objectives_de': objectivesDe,
      'components': components.map((c) => c.toJson()).toList(),
      'available_components': availableComponents
          .map((c) => c.toJson())
          .toList(),
      'hints': hints,
      if (hintsDe != null) 'hints_de': hintsDe,
      'tests': tests.map((t) => t.toJson()).toList(),
      if (memoryContents != null) 'memoryContents': memoryContents!.toJson(),
    };
  }

  /// Get localized string for the given field and locale code.
  /// Falls back to English if translation not available.
  String getLocalizedString(String field, String localeCode) {
    switch (field) {
      case 'name':
        return localeCode == 'de' && nameDe != null ? nameDe! : name;
      case 'description':
        return localeCode == 'de' && descriptionDe != null ? descriptionDe! : description;
      case 'difficulty':
        return localeCode == 'de' && difficultyDe != null ? difficultyDe! : difficulty;
      default:
        return '';
    }
  }

  /// Get localized string list for the given field and locale code.
  /// Falls back to English if translation not available.
  List<String> getLocalizedStringList(String field, String localeCode) {
    switch (field) {
      case 'objectives':
        return localeCode == 'de' && objectivesDe != null ? objectivesDe! : objectives;
      case 'hints':
        return localeCode == 'de' && hintsDe != null ? hintsDe! : hints;
      default:
        return [];
    }
  }
}

/// Data model representing a level block item
class LevelBlockItem {
  final int id;
  final String name;
  final String? nameDe;
  final bool recommended;

  LevelBlockItem({
    required this.id,
    required this.name,
    this.nameDe,
    this.recommended = false,
  });

  factory LevelBlockItem.fromJson(Map<String, dynamic> json) {
    return LevelBlockItem(
      id: json['id'] as int,
      name: json['name'] as String,
      nameDe: json['name_de'] as String?,
      recommended: json['recommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (nameDe != null) 'name_de': nameDe,
      'recommended': recommended,
    };
  }

  /// Get localized name for the given locale code.
  /// Falls back to English if translation not available.
  String getLocalizedName(String localeCode) {
    return localeCode == 'de' && nameDe != null ? nameDe! : name;
  }
}

/// Data model representing a level category
class LevelCategory {
  final String name;
  final String? nameDe;
  final List<LevelBlockItem> levels;

  LevelCategory({
    required this.name,
    this.nameDe,
    required this.levels,
  });

  factory LevelCategory.fromJson(Map<String, dynamic> json) {
    return LevelCategory(
      name: json['name'] as String,
      nameDe: json['name_de'] as String?,
      levels: (json['levels'] as List<dynamic>)
          .map((item) => LevelBlockItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (nameDe != null) 'name_de': nameDe,
      'levels': levels.map((l) => l.toJson()).toList(),
    };
  }

  /// Get localized name for the given locale code.
  /// Falls back to English if translation not available.
  String getLocalizedName(String localeCode) {
    return localeCode == 'de' && nameDe != null ? nameDe! : name;
  }
}

/// Data model representing level progression metadata
class LevelMeta {
  final List<int> completedLevels;
  bool allLevelsUnlocked;

  LevelMeta({required this.completedLevels, required this.allLevelsUnlocked});

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
