import 'package:circuitquest_flutter/core/components/sequential/d_latch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DLatch', () {
    test('should have correct pins', () {
      final latch = DLatch();

      expect(latch.inputs.length, 2);
      expect(latch.outputs.length, 2);
      expect(latch.inputs.containsKey('D'), true);
      expect(latch.inputs.containsKey('clock'), true);
      expect(latch.outputs.containsKey('Q'), true);
      expect(latch.outputs.containsKey('!Q'), true);
    });

    test('should store value when clock is high', () {
      final latch = DLatch();

      // Set D = 1, clock = 1
      latch.inputs['D']!.value = 1;
      latch.inputs['clock']!.value = 1;
      latch.evaluate();

      expect(latch.outputs['Q']!.value, 1);
      expect(latch.outputs['!Q']!.value, 0);
    });

    test('should hold value when clock goes low', () {
      final latch = DLatch();

      // Set D = 1, clock = 1 (store the value)
      latch.inputs['D']!.value = 1;
      latch.inputs['clock']!.value = 1;
      latch.evaluate();

      expect(latch.outputs['Q']!.value, 1);

      // Change D = 0, clock = 0 (should hold previous value)
      latch.inputs['D']!.value = 0;
      latch.inputs['clock']!.value = 0;
      latch.evaluate();

      expect(latch.outputs['Q']!.value, 1); // Still 1
      expect(latch.outputs['!Q']!.value, 0);
    });

    test('should be transparent when clock is high', () {
      final latch = DLatch();

      // Clock high, D changes should propagate immediately
      latch.inputs['clock']!.value = 1;

      latch.inputs['D']!.value = 0;
      latch.evaluate();
      expect(latch.outputs['Q']!.value, 0);

      latch.inputs['D']!.value = 1;
      latch.evaluate();
      expect(latch.outputs['Q']!.value, 1);

      latch.inputs['D']!.value = 0;
      latch.evaluate();
      expect(latch.outputs['Q']!.value, 0);
    });

    test('should return true when output changes', () {
      final latch = DLatch();

      latch.inputs['D']!.value = 1;
      latch.inputs['clock']!.value = 1;
      final changed = latch.evaluate();

      expect(changed, true);
    });

    test('should return false when output does not change', () {
      final latch = DLatch();

      // Set initial value
      latch.inputs['D']!.value = 1;
      latch.inputs['clock']!.value = 1;
      latch.evaluate();

      // Evaluate again with same inputs
      final changed = latch.evaluate();
      expect(changed, false);
    });

    test('should work with multi-bit values', () {
      final latch = DLatch(bitWidth: 4);

      latch.inputs['D']!.value = 12; // 0b1100
      latch.inputs['clock']!.value = 1;
      latch.evaluate();

      expect(latch.outputs['Q']!.value, 12);
      expect(latch.outputs['!Q']!.value, 3); // 0b0011

      // Hold the value
      latch.inputs['D']!.value = 7;
      latch.inputs['clock']!.value = 0;
      latch.evaluate();

      expect(latch.outputs['Q']!.value, 12); // Still 12
    });
  });
}
