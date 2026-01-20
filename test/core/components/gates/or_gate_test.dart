import 'package:cirquitquest_flutter/core/components/gates/or_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrGate', () {
    test('should compute OR correctly - both false', () {
      final gate = OrGate();
      
      gate.inputs['inputA']!.value = 0;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 0);
    });

    test('should compute OR correctly - one true', () {
      final gate = OrGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 0;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 1);
    });

    test('should compute OR correctly - both true', () {
      final gate = OrGate();
      
      gate.inputs['inputA']!.value = 1;
      gate.inputs['inputB']!.value = 1;
      gate.evaluate();
      
      expect(gate.outputs['output']!.value, 1);
    });
  });
}

