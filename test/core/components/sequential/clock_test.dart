import 'package:circuitquest_flutter/core/components/sequential/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Clock', () {
    test('should start with output', () {
      final clock = Clock();

      expect(clock.outputs.length, 1);
      expect(clock.outputs.containsKey('clock'), true);
      expect(clock.inputs.length, 0);
    });

    test('should set clock value', () {
      final clock = Clock();

      clock.setClock(0);
      expect(clock.outputs['clock']!.value, 0);

      clock.setClock(1);
      expect(clock.outputs['clock']!.value, 1);
    });

    test('should toggle clock value', () {
      final clock = Clock();

      clock.setClock(0);
      expect(clock.outputs['clock']!.value, 0);

      clock.toggle();
      expect(clock.outputs['clock']!.value, 1);

      clock.toggle();
      expect(clock.outputs['clock']!.value, 0);

      clock.toggle();
      expect(clock.outputs['clock']!.value, 1);
    });

    test('should always return true on evaluate to trigger downstream', () {
      final clock = Clock();

      final result = clock.evaluate();
      expect(result, true);
    });
  });
}
