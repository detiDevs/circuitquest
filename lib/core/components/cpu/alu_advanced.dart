import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Advanced ALU component supporting multiple operations
class ALUAdvanced extends Component {
  late InputPin _inputA;
  late InputPin _inputB;
  late InputPin _control;
  late OutputPin _result;
  late OutputPin _zero;

  ALUAdvanced() {
    _inputA = InputPin(this, bitWidth: 32);
    _inputB = InputPin(this, bitWidth: 32);
    _control = InputPin(this, bitWidth: 4);
    _result = OutputPin(this, bitWidth: 32);
    _zero = OutputPin(this, bitWidth: 1);
    
    inputs['a'] = _inputA;
    inputs['b'] = _inputB;
    inputs['control'] = _control;
    outputs['result'] = _result;
    outputs['zero'] = _zero;
  }

  @override
  bool evaluate() {
    final a = _inputA.value;
    final b = _inputB.value;
    final op = _control.value;
    
    int result;
    switch (op) {
      case 0: // AND
        result = a & b;
        break;
      case 1: // OR
        result = a | b;
        break;
      case 2: // ADD
        result = (a + b) & 0xFFFFFFFF;
        break;
      case 6: // SUBTRACT
        result = (a - b) & 0xFFFFFFFF;
        break;
      case 7: // SLT (Set on Less Than)
        result = (a < b) ? 1 : 0;
        break;
      default:
        result = 0;
    }
    
    final zeroFlag = result == 0 ? 1 : 0;
    
    bool changed = false;
    if (_result.value != result) {
      _result.value = result;
      changed = true;
    }
    if (_zero.value != zeroFlag) {
      _zero.value = zeroFlag;
      changed = true;
    }
    return changed;
  }
}
