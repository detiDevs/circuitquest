import 'package:circuitquest/levels/level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelComponent immutable parsing', () {
    test('defaults immutable to false when key is absent', () {
      final component = LevelComponent.fromJson({
        'type': 'Input',
        'position': [1, 2],
        'immovable': true,
      });

      expect(component.immutable, isFalse);
    });

    test('parses immutable true when key is present', () {
      final component = LevelComponent.fromJson({
        'type': 'Input',
        'position': [1, 2],
        'immovable': true,
        'immutable': true,
      });

      expect(component.immutable, isTrue);
    });
  });
}
