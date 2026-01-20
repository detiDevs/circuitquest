import 'package:cirquitquest_flutter/core/components/combinational/multiplexer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Multiplexer', () {
    test('selects correct input', () {
      final mux = Multiplexer(inputCount: 4, dataBitWidth: 3);

      mux.inputs['in0']!.value = 1;
      mux.inputs['in1']!.value = 2;
      mux.inputs['in2']!.value = 3;
      mux.inputs['in3']!.value = 4;

      mux.inputs['sel']!.value = 0;
      mux.evaluate();
      expect(mux.outputs['out']!.value, 1);

      mux.inputs['sel']!.value = 1;
      mux.evaluate();
      expect(mux.outputs['out']!.value, 2);

      mux.inputs['sel']!.value = 2;
      mux.evaluate();
      expect(mux.outputs['out']!.value, 3);

      mux.inputs['sel']!.value = 3;
      mux.evaluate();
      expect(mux.outputs['out']!.value, 4);
    });

    test('wraps selection beyond range', () {
      final mux = Multiplexer(inputCount: 2, dataBitWidth: 2);

      mux.inputs['in0']!.value = 1;
      mux.inputs['in1']!.value = 2;
      mux.inputs['sel']!.value = 3; // wraps to 1 for two inputs
      mux.evaluate();
      expect(mux.outputs['out']!.value, 2);
    });

    test('reports changes correctly', () {
      final mux = Multiplexer(inputCount: 2, dataBitWidth: 1);

      mux.inputs['in0']!.value = 0;
      mux.inputs['in1']!.value = 1;

      mux.inputs['sel']!.value = 0;
      final firstChange = mux.evaluate();
      expect(firstChange, false);

      // No change if selection stays the same and inputs unchanged
      final secondChange = mux.evaluate();
      expect(secondChange, false);

      // Change selection to pick new value
      mux.inputs['sel']!.value = 1;
      final thirdChange = mux.evaluate();
      expect(thirdChange, true);
      expect(mux.outputs['out']!.value, 1);
    });
  });
}
