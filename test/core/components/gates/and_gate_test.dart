import 'package:circuitquest_flutter/core/components/gates/and_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AndGate', () {
    test('should have correct pins', () {
      final gate = AndGate();
      
      expect(gate.inputs.length, 2);
      expect(gate.outputs.length, 1);
      expect(gate.inputs.containsKey('inputA'), true);
      expect(gate.inputs.containsKey('inputB'), true);
      expect(gate.outputs.containsKey('output'), true);
    });

    test('should compute AND correctly - both false', () {
      final gate = AndGate();
      
      gate.inputs['inputA']!.value = 0;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 0);
    });

    test('should compute AND correctly - one true', () {
      final gate = AndGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 0);
    });

    test('should compute AND correctly - both true', () {
      final gate = AndGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 1;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 1);
    });

    test('should return true when output changes', () {
      final gate = AndGate();
      
      gate.inputs['inputA']!.value = 0;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 1;
      
      final changed = gate.evaluate();
      expect(changed, true);
    });

    test('should return false when output does not change', () {
      final gate = AndGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 1;
      gate.evaluate();
      
      final changed = gate.evaluate();
      expect(changed, false);
    });
  });
}
