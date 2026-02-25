import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Half Adder: computes sum and carry from two 1-bit inputs.
class HalfAdder extends Component {
  HalfAdder() {
    inputs['inputA'] = InputPin(this, bitWidth: 1);
    inputs['inputB'] = InputPin(this, bitWidth: 1);
    outputs['outSum'] = OutputPin(this, bitWidth: 1);
    outputs['carryOut'] = OutputPin(this, bitWidth: 1);
    outputs['outSum']!.value = 0;
    outputs['carryOut']!.value = 0;
    pinPositions = {'carryOut': PinPosition.BOTTOM};
  }

  /// Evaluates sum = A xor B, carry = A & B.
  @override
  bool evaluate() {
    inputs['inputA']!.updateFromSource();
    inputs['inputB']!.updateFromSource();

    final int a = inputs['inputA']!.value;
    final int b = inputs['inputB']!.value;
    final int newSum = a ^ b;
    final int newCarry = a & b;

    final bool sumChanged = outputs['outSum']!.value != newSum;
    final bool carryChanged = outputs['carryOut']!.value != newCarry;
    outputs['outSum']!.value = newSum;
    outputs['carryOut']!.value = newCarry;
    return sumChanged || carryChanged;
  }
}

/// Full Adder: computes sum and carry-out from two 1-bit inputs and carry-in.
class FullAdder extends Component {
  FullAdder() {
    inputs['inputA'] = InputPin(this, bitWidth: 1);
    inputs['inputB'] = InputPin(this, bitWidth: 1);
    inputs['carryIn'] = InputPin(this, bitWidth: 1);
    outputs['outSum'] = OutputPin(this, bitWidth: 1);
    outputs['carryOut'] = OutputPin(this, bitWidth: 1);
    outputs['outSum']!.value = 0;
    outputs['carryOut']!.value = 0;
    pinPositions = {'carryIn': PinPosition.TOP, 'carryOut': PinPosition.BOTTOM};
  }

  /// Evaluates sum = A xor B xor Cin; carry = majority(A,B,Cin).
  @override
  bool evaluate() {
    inputs['inputA']!.updateFromSource();
    inputs['inputB']!.updateFromSource();
    inputs['carryIn']!.updateFromSource();

    final int a = inputs['inputA']!.value;
    final int b = inputs['inputB']!.value;
    final int cin = inputs['carryIn']!.value;

    final int newSum = a ^ b ^ cin;
    final int newCarry = (a & b) | (a & cin) | (b & cin);

    final bool sumChanged = outputs['outSum']!.value != newSum;
    final bool carryChanged = outputs['carryOut']!.value != newCarry;
    outputs['outSum']!.value = newSum;
    outputs['carryOut']!.value = newCarry;
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
    inputs['inputA'] = InputPin(this, bitWidth: bitWidth);
    inputs['inputB'] = InputPin(this, bitWidth: bitWidth);
    inputs['carryIn'] = InputPin(this, bitWidth: 1);
    outputs['outSum'] = OutputPin(this, bitWidth: bitWidth);
    outputs['carryOut'] = OutputPin(this, bitWidth: 1);
  }

  /// Adds A and B and an optional carry-in, producing SUM and carryOut.
  @override
  bool evaluate() {
    inputs['inputA']!.updateFromSource();
    inputs['inputB']!.updateFromSource();
    inputs['carryIn']!.updateFromSource();

    final int a = inputs['inputA']!.value;
    final int b = inputs['inputB']!.value;
    final int cin = inputs['carryIn']!.value;

    final int mask = (1 << bitWidth) - 1;
    final int raw = a + b + cin;
    final int newSum = raw & mask;
    final int newCarry = (raw >> bitWidth) & 0x1;

    final bool sumChanged = outputs['outSum']!.value != newSum;
    final bool carryChanged = outputs['carryOut']!.value != newCarry;
    outputs['outSum']!.value = newSum;
    outputs['carryOut']!.value = newCarry;
    return sumChanged || carryChanged;
  }
}
