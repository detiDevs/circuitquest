import 'package:circuitquest_flutter/core/components/gates/not_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotGate', () {
    test('should have correct pins', () {
      final gate = NotGate();
      
      expect(gate.inputs.length, 1);
      expect(gate.outputs.length, 1);
      expect(gate.inputs.containsKey('input'), true);
      expect(gate.outputs.containsKey('output'), true);
    });

    test('should compute NOT correctly - false input', () {
      final gate = NotGate();
      
      gate.inputs['input']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 1);
    });

    test('should compute NOT correctly - true input', () {
      final gate = NotGate();
      
      gate.inputs['input']!.value = 1;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 0);
    });

    test('should return true when output changes', () {
      final gate = NotGate();
      
      gate.inputs['input']!.value = 0;
      gate.evaluate();
      
      gate.inputs['input']!.value = 1;
      final changed = gate.evaluate();
      
      expect(changed, true);
    });

    test('should return false when output does not change', () {
      final gate = NotGate();
      
      gate.inputs['input']!.value = 1;
      gate.evaluate();
      
      final changed = gate.evaluate();
      expect(changed, false);
    });
  });
}
