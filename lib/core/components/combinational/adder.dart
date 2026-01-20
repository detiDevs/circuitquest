import 'package:cirquitquest_flutter/core/components/base/component.dart';
import 'package:cirquitquest_flutter/core/logic/pin.dart';

/// Half Adder: computes sum and carry from two 1-bit inputs.
class HalfAdder extends Component {
  HalfAdder() {
    inputs['A'] = InputPin(this, bitWidth: 1);
    inputs['B'] = InputPin(this, bitWidth: 1);
    outputs['SUM'] = OutputPin(this, bitWidth: 1);
    outputs['CARRY'] = OutputPin(this, bitWidth: 1);
  }

  /// Evaluates sum = A xor B, carry = A & B.
  @override
  bool evaluate() {
    inputs['A']!.updateFromSource();
    inputs['B']!.updateFromSource();

    final int a = inputs['A']!.value;
    final int b = inputs['B']!.value;
    final int newSum = a ^ b;
    final int newCarry = a & b;

    final bool sumChanged = outputs['SUM']!.value != newSum;
    final bool carryChanged = outputs['CARRY']!.value != newCarry;
    outputs['SUM']!.value = newSum;
    outputs['CARRY']!.value = newCarry;
    return sumChanged || carryChanged;
  }
}

/// Full Adder: computes sum and carry-out from two 1-bit inputs and carry-in.
class FullAdder extends Component {
  FullAdder() {
    inputs['A'] = InputPin(this, bitWidth: 1);
    inputs['B'] = InputPin(this, bitWidth: 1);
    inputs['CARRY_IN'] = InputPin(this, bitWidth: 1);
    outputs['SUM'] = OutputPin(this, bitWidth: 1);
    outputs['CARRY_OUT'] = OutputPin(this, bitWidth: 1);
  }

  /// Evaluates sum = A xor B xor Cin; carry = majority(A,B,Cin).
  @override
  bool evaluate() {
    inputs['A']!.updateFromSource();
    inputs['B']!.updateFromSource();
    inputs['CARRY_IN']!.updateFromSource();

    final int a = inputs['A']!.value;
    final int b = inputs['B']!.value;
    final int cin = inputs['CARRY_IN']!.value;

    final int newSum = a ^ b ^ cin;
    final int newCarry = (a & b) | (a & cin) | (b & cin);

    final bool sumChanged = outputs['SUM']!.value != newSum;
    final bool carryChanged = outputs['CARRY_OUT']!.value != newCarry;
    outputs['SUM']!.value = newSum;
    outputs['CARRY_OUT']!.value = newCarry;
    return sumChanged || carryChanged;
  }
}

/// Ripple-carry adder for multi-bit addition with carry-in and carry-out.
class RippleCarryAdder extends Component {
  /// Bit width of the operands and sum output.
  final int bitWidth;

  RippleCarryAdder({this.bitWidth = 8}) {
    if (bitWidth <= 0) {
      throw ArgumentError('bitWidth must be positive');
    }
    inputs['A'] = InputPin(this, bitWidth: bitWidth);
    inputs['B'] = InputPin(this, bitWidth: bitWidth);
    inputs['CARRY_IN'] = InputPin(this, bitWidth: 1);
    outputs['SUM'] = OutputPin(this, bitWidth: bitWidth);
    outputs['CARRY_OUT'] = OutputPin(this, bitWidth: 1);
  }

  /// Adds A and B and an optional carry-in, producing SUM and CARRY_OUT.
  @override
  bool evaluate() {
    inputs['A']!.updateFromSource();
    inputs['B']!.updateFromSource();
    inputs['CARRY_IN']!.updateFromSource();

    final int a = inputs['A']!.value;
    final int b = inputs['B']!.value;
    final int cin = inputs['CARRY_IN']!.value;

    final int mask = (1 << bitWidth) - 1;
    final int raw = a + b + cin;
    final int newSum = raw & mask;
    final int newCarry = (raw >> bitWidth) & 0x1;

    final bool sumChanged = outputs['SUM']!.value != newSum;
    final bool carryChanged = outputs['CARRY_OUT']!.value != newCarry;
    outputs['SUM']!.value = newSum;
    outputs['CARRY_OUT']!.value = newCarry;
    return sumChanged || carryChanged;
  }
}
