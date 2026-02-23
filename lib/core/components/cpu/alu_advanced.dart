import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Advanced ALU component supporting AND, OR, ADD, SUB, and SLT operations with input inversion and negation
class ALUAdvanced extends Component {
  late InputPin _input1;
  late InputPin _input2;
  late InputPin _op;
  late InputPin _ainvert;
  late InputPin _bnegate;
  late OutputPin _outValue;
  late OutputPin _zero;

  ALUAdvanced() {
    _input1 = InputPin(this, bitWidth: 32);
    _input2 = InputPin(this, bitWidth: 32);
    _op = InputPin(this, bitWidth: 2);
    _ainvert = InputPin(this, bitWidth: 1);
    _bnegate = InputPin(this, bitWidth: 1);
    _outValue = OutputPin(this, bitWidth: 32);
    _zero = OutputPin(this, bitWidth: 1);

    inputs['input1'] = _input1;
    inputs['input2'] = _input2;
    inputs['OP'] = _op;
    inputs['Ainvert'] = _ainvert;
    inputs['Bnegate'] = _bnegate;
    outputs['outValue'] = _outValue;
    outputs['zero'] = _zero;
    outputs['outValue']!.value = 0;
    outputs['zero']!.value = 0;
  }

  @override
  bool evaluate() {
    int a = _input1.value;
    int b = _input2.value;
    final op = _op.value;
    final ainvert = _ainvert.value;
    final bnegate = _bnegate.value;

    // Apply inversion if needed
    if (ainvert == 1) {
      a = (~a) & 0xFFFFFFFF; // Bitwise NOT and mask to 32 bits
    }
    if (bnegate == 1) {
      b = (~b + 1) & 0xFFFFFFFF; // Two's complement negation
    }

    int result;
    switch (op) {
      case 0: // AND
        result = a & b;
        break;
      case 1: // OR
        result = a | b;
        break;
      case 2: // ADD
        result = (a + b) & 0xFFFFFFFF; // Subtraction handled by Bnegate
        break;
      case 3: // SLT (Set on Less Than)
        // Convert to signed 32-bit integers for proper comparison
        final signedA = a < 0x80000000 ? a : a - 0x100000000;
        final signedB = b < 0x80000000 ? b : b - 0x100000000;
        result = signedA < signedB ? 1 : 0;
        break;
      default:
        result = 0;
    }

    final zeroFlag = result == 0 ? 1 : 0;

    bool changed = false;
    if (_outValue.value != result) {
      _outValue.value = result;
      changed = true;
    }
    if (_zero.value != zeroFlag) {
      _zero.value = zeroFlag;
      changed = true;
    }
    return changed;
  }
}
