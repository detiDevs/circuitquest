import 'package:circuitquest_flutter/core/components/sequential/d_flip_flop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DFlipFlop', () {
    test('should have correct pins', () {
      final ff = DFlipFlop();

      expect(ff.inputs.length, 2);
      expect(ff.outputs.length, 2);
      expect(ff.inputs.containsKey('D'), true);
      expect(ff.inputs.containsKey('clock'), true);
      expect(ff.outputs.containsKey('Q'), true);
      expect(ff.outputs.containsKey('!Q'), true);
    });

    test('should store value on rising edge', () {
      final ff = DFlipFlop();

      // Set D = 1, but clock is low
      ff.inputs['D']!.value = 1;
      ff.inputs['clock']!.value = 0;
      ff.evaluate();

      expect(ff.outputs['Q']!.value, 0); // Not stored yet

      // Rising edge: clock 0 -> 1
      ff.inputs['clock']!.value = 1;
      ff.evaluate();

      expect(ff.outputs['Q']!.value, 1); // Now stored
      expect(ff.outputs['!Q']!.value, 0);
    });

    test('should not store on high level, only on edge', () {
      final ff = DFlipFlop();

      // Rising edge with D = 1
      ff.inputs['D']!.value = 1;
      ff.inputs['clock']!.value = 0;
      ff.evaluate();

      ff.inputs['clock']!.value = 1;
      ff.evaluate();
      expect(ff.outputs['Q']!.value, 1);

      // Change D while clock is still high
      ff.inputs['D']!.value = 0;
      ff.evaluate();

      expect(ff.outputs['Q']!.value, 1); // Should not change
    });

    test('should detect multiple rising edges', () {
      final ff = DFlipFlop();

      // First rising edge with D = 1
      ff.inputs['D']!.value = 1;
      ff.inputs['clock']!.value = 0;
      ff.evaluate();
      ff.inputs['clock']!.value = 1;
      ff.evaluate();
      expect(ff.outputs['Q']!.value, 1);

      // Clock goes low
      ff.inputs['clock']!.value = 0;
      ff.inputs['D']!.value = 0;
      ff.evaluate();

      // Second rising edge with D = 0
      ff.inputs['clock']!.value = 1;
      ff.evaluate();
      expect(ff.outputs['Q']!.value, 0);
    });

    test('should hold value between rising edges', () {
      final ff = DFlipFlop();

      // Store value 1
      ff.inputs['D']!.value = 1;
      ff.inputs['clock']!.value = 0;
      ff.evaluate();
      ff.inputs['clock']!.value = 1;
      ff.evaluate();

      // Clock stays high, D changes
      ff.inputs['D']!.value = 0;
      ff.evaluate();
      expect(ff.outputs['Q']!.value, 1); // Unchanged

      // Clock goes low, D changes
      ff.inputs['clock']!.value = 0;
      ff.inputs['D']!.value = 0;
      ff.evaluate();
      expect(ff.outputs['Q']!.value, 1); // Still unchanged
    });

    test('should reset to initial state', () {
      final ff = DFlipFlop();

      // Store a value
      ff.inputs['D']!.value = 1;
      ff.inputs['clock']!.value = 0;
      ff.evaluate();
      ff.inputs['clock']!.value = 1;
      ff.evaluate();
      expect(ff.outputs['Q']!.value, 1);

      // Reset
      ff.reset();

      expect(ff.outputs['Q']!.value, 0);
      expect(ff.outputs['!Q']!.value, 1);
    });

    test('should work with multi-bit values', () {
      final ff = DFlipFlop(bitWidth: 8);

      // Store 255 (0xFF)
      ff.inputs['D']!.value = 255;
      ff.inputs['clock']!.value = 0;
      ff.evaluate();
      ff.inputs['clock']!.value = 1;
      ff.evaluate();

      expect(ff.outputs['Q']!.value, 255);
      expect(ff.outputs['!Q']!.value, 0);

      // Store 170 (0xAA)
      ff.inputs['D']!.value = 170;
      ff.inputs['clock']!.value = 0;
      ff.evaluate();
      ff.inputs['clock']!.value = 1;
      ff.evaluate();

      expect(ff.outputs['Q']!.value, 170);
      expect(ff.outputs['!Q']!.value, 85); // 0x55
    });

    test('should return true when output changes', () {
      final ff = DFlipFlop();

      ff.inputs['D']!.value = 1;
      ff.inputs['clock']!.value = 0;
      ff.evaluate();

      // Rising edge should change output
      ff.inputs['clock']!.value = 1;
      final changed = ff.evaluate();

      expect(changed, true);
    });

    test('should return false when output does not change', () {
      final ff = DFlipFlop();

      // Store initial value
      ff.inputs['D']!.value = 1;
      ff.inputs['clock']!.value = 0;
      ff.evaluate();
      ff.inputs['clock']!.value = 1;
      ff.evaluate();

      // Clock stays high, no change
      final changed = ff.evaluate();
      expect(changed, false);
    });
  });
}
