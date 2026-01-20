import 'package:cirquitquest_flutter/core/components/gates/nor_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NorGate', () {
    test('should compute NOR correctly - both false', () {
      final gate = NorGate();
      
      gate.inputs['inputA']!.value = 0;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 1);
    });

    test('should compute NOR correctly - one true', () {
      final gate = NorGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 0);
    });

    test('should compute NOR correctly - both true', () {
      final gate = NorGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 1;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 0);
    });
  });
}
