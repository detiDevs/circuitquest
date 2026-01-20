import 'package:cirquitquest_flutter/core/components/gates/xor_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XorGate', () {
    test('should compute XOR correctly - both false', () {
      final gate = XorGate();
      
      gate.inputs['inputA']!.value = 0;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 0);
    });

    test('should compute XOR correctly - one true', () {
      final gate = XorGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 1);
    });

    test('should compute XOR correctly - both true', () {
      final gate = XorGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 1;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 0);
    });
  });
}
