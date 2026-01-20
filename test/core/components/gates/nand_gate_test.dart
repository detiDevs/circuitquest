import 'package:cirquitquest_flutter/core/components/gates/nand_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NandGate', () {
    test('should compute NAND correctly - both false', () {
      final gate = NandGate();
      
      gate.inputs['inputA']!.value = 0;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 1);
    });

    test('should compute NAND correctly - one true', () {
      final gate = NandGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 1);
    });

    test('should compute NAND correctly - both true', () {
      final gate = NandGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 1;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 0);
    });
  });
}
