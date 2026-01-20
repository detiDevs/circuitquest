import 'package:cirquitquest_flutter/core/components/sequential/register.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Register', () {
    test('should have correct pins', () {
      final reg = Register();

      expect(reg.inputs.length, 2);
      expect(reg.outputs.length, 1);
      expect(reg.inputs.containsKey('data'), true);
      expect(reg.inputs.containsKey('clock'), true);
      expect(reg.outputs.containsKey('output'), true);
    });

    test('should have default 32-bit width', () {
      final reg = Register();

      expect(reg.inputs['data']!.bitWidth, 32);
      expect(reg.outputs['output']!.bitWidth, 32);
    });

    test('should support custom bit width', () {
      final reg = Register(bitWidth: 8);

      expect(reg.inputs['data']!.bitWidth, 8);
      expect(reg.outputs['output']!.bitWidth, 8);
    });

    test('should store data on rising edge', () {
      final reg = Register(bitWidth: 8);

      // Set data = 42, clock = 0
      reg.inputs['data']!.value = 42;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();

      expect(reg.outputs['output']!.value, 0); // Not stored yet

      // Rising edge
      reg.inputs['clock']!.value = 1;
      reg.evaluate();

      expect(reg.outputs['output']!.value, 42);
      expect(reg.value, 42);
    });

    test('should not store on high level, only on edge', () {
      final reg = Register(bitWidth: 8);

      // Rising edge with data = 100
      reg.inputs['data']!.value = 100;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();
      reg.inputs['clock']!.value = 1;
      reg.evaluate();

      expect(reg.outputs['output']!.value, 100);

      // Change data while clock is still high
      reg.inputs['data']!.value = 200;
      reg.evaluate();

      expect(reg.outputs['output']!.value, 100); // Should not change
    });

    test('should store multiple values on successive rising edges', () {
      final reg = Register(bitWidth: 16);

      // First value
      reg.inputs['data']!.value = 1000;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();
      reg.inputs['clock']!.value = 1;
      reg.evaluate();
      expect(reg.value, 1000);

      // Second value
      reg.inputs['data']!.value = 2000;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();
      reg.inputs['clock']!.value = 1;
      reg.evaluate();
      expect(reg.value, 2000);

      // Third value
      reg.inputs['data']!.value = 3000;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();
      reg.inputs['clock']!.value = 1;
      reg.evaluate();
      expect(reg.value, 3000);
    });

    test('should hold value when clock is low', () {
      final reg = Register(bitWidth: 8);

      // Store initial value
      reg.inputs['data']!.value = 55;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();
      reg.inputs['clock']!.value = 1;
      reg.evaluate();

      // Clock goes low, data changes
      reg.inputs['clock']!.value = 0;
      reg.inputs['data']!.value = 99;
      reg.evaluate();

      expect(reg.value, 55); // Should still be 55
    });

    test('should reset to zero', () {
      final reg = Register(bitWidth: 8);

      // Store a value
      reg.inputs['data']!.value = 255;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();
      reg.inputs['clock']!.value = 1;
      reg.evaluate();

      expect(reg.value, 255);

      // Reset
      reg.reset();

      expect(reg.value, 0);
      expect(reg.outputs['output']!.value, 0);
    });

    test('should work with 32-bit values', () {
      final reg = Register(bitWidth: 32);

      final largeValue = 0x12345678;

      reg.inputs['data']!.value = largeValue;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();
      reg.inputs['clock']!.value = 1;
      reg.evaluate();

      expect(reg.value, largeValue);
    });

    test('should return true when output changes', () {
      final reg = Register(bitWidth: 8);

      reg.inputs['data']!.value = 42;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();

      // Rising edge should change output
      reg.inputs['clock']!.value = 1;
      final changed = reg.evaluate();

      expect(changed, true);
    });

    test('should return false when output does not change', () {
      final reg = Register(bitWidth: 8);

      // Store initial value
      reg.inputs['data']!.value = 42;
      reg.inputs['clock']!.value = 0;
      reg.evaluate();
      reg.inputs['clock']!.value = 1;
      reg.evaluate();

      // Clock stays high, no change
      final changed = reg.evaluate();
      expect(changed, false);
    });
  });
}
