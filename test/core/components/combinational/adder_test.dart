import 'package:circuitquest/core/components/combinational/adder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HalfAdder', () {
    test('computes sum and carry', () {
      final ha = HalfAdder();

      ha.inputs['A']!.value = 0;
      ha.inputs['B']!.value = 0;
      ha.evaluate();
      expect(ha.outputs['SUM']!.value, 0);
      expect(ha.outputs['CARRY']!.value, 0);

      ha.inputs['A']!.value = 1;
      ha.inputs['B']!.value = 0;
      ha.evaluate();
      expect(ha.outputs['SUM']!.value, 1);
      expect(ha.outputs['CARRY']!.value, 0);

      ha.inputs['A']!.value = 1;
      ha.inputs['B']!.value = 1;
      ha.evaluate();
      expect(ha.outputs['SUM']!.value, 0);
      expect(ha.outputs['CARRY']!.value, 1);
    });
  });

  group('FullAdder', () {
    test('computes sum and carry with carry-in', () {
      final fa = FullAdder();

      fa.inputs['A']!.value = 1;
      fa.inputs['B']!.value = 1;
      fa.inputs['CARRY_IN']!.value = 0;
      fa.evaluate();
      expect(fa.outputs['SUM']!.value, 0);
      expect(fa.outputs['CARRY_OUT']!.value, 1);

      fa.inputs['CARRY_IN']!.value = 1;
      fa.evaluate();
      expect(fa.outputs['SUM']!.value, 1);
      expect(fa.outputs['CARRY_OUT']!.value, 1);
    });
  });

  group('RippleCarryAdder', () {
    test('adds small numbers with carry out', () {
      final rca = RippleCarryAdder(bitWidth: 4);

      rca.inputs['A']!.value = 15; // 0b1111
      rca.inputs['B']!.value = 1; // 0b0001
      rca.inputs['CARRY_IN']!.value = 0;
      rca.evaluate();

      expect(rca.outputs['SUM']!.value, 0); // 16 masked to 4 bits
      expect(rca.outputs['CARRY_OUT']!.value, 1);
    });

    test('adds with carry in and without overflow', () {
      final rca = RippleCarryAdder(bitWidth: 8);

      rca.inputs['A']!.value = 10;
      rca.inputs['B']!.value = 20;
      rca.inputs['CARRY_IN']!.value = 1;
      rca.evaluate();

      expect(rca.outputs['SUM']!.value, 31);
      expect(rca.outputs['CARRY_OUT']!.value, 0);
    });

    test('reports changes correctly', () {
      final rca = RippleCarryAdder(bitWidth: 4);

      rca.inputs['A']!.value = 1;
      rca.inputs['B']!.value = 1;
      rca.inputs['CARRY_IN']!.value = 0;
      final changed = rca.evaluate();
      expect(changed, true);

      // No change if inputs the same
      final changedAgain = rca.evaluate();
      expect(changedAgain, false);
    });
  });
}
