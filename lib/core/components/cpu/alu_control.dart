import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// ALU Control unit that generates ALU control signals based on ALUop and funct bits
class ALUControl extends Component {
  late InputPin _aluOp;
  late InputPin _funct;

  late OutputPin _ainvert;
  late OutputPin _binvert;
  late OutputPin _operation;

  ALUControl() {
    _aluOp = InputPin(this, bitWidth: 2);
    _funct = InputPin(this, bitWidth: 6);

    _ainvert = OutputPin(this, bitWidth: 1);
    _binvert = OutputPin(this, bitWidth: 1);
    _operation = OutputPin(this, bitWidth: 2);

    inputs['ALUop'] = _aluOp;
    inputs['funct'] = _funct;
    outputs['ainvert'] = _ainvert;
    outputs['binvert'] = _binvert;
    outputs['operation'] = _operation;
    outputs['ainvert']!.value = 0;
    outputs['binvert']!.value = 0;
    outputs['operation']!.value = 0;
  }

  @override
  bool evaluate() {
    _aluOp.updateFromSource();
    _funct.updateFromSource();
    final aluOp = _aluOp.value;
    final funct = _funct.value;

    int ainvert = 0;
    int binvert = 0;
    int operation = 0;

    if (aluOp == 0) {
      // lw or sw
      ainvert = 0;
      binvert = 0;
      operation = 0; // ADD
    } else if (aluOp == 1) {
      // beq
      ainvert = 0;
      binvert = 1;
      operation = 2; // SUBTRACT
    } else if (aluOp == 2) {
      // R-type
      if (funct == 0) {
        // ADD
        ainvert = 0;
        binvert = 0;
        operation = 2;
      } else if (funct == 2) {
        // SUBTRACT
        ainvert = 0;
        binvert = 1;
        operation = 2;
      } else if (funct == 4) {
        // AND
        ainvert = 0;
        binvert = 0;
        operation = 0;
      } else if (funct == 5) {
        // OR
        ainvert = 0;
        binvert = 0;
        operation = 1;
      } else if (funct == 10) {
        // SLT
        ainvert = 0;
        binvert = 1;
        operation = 3;
      } else {
        // Default to ADD
        ainvert = 0;
        binvert = 0;
        operation = 0;
      }
    }

    bool changed = false;
    if (_ainvert.value != ainvert) {
      _ainvert.value = ainvert;
      changed = true;
    }
    if (_binvert.value != binvert) {
      _binvert.value = binvert;
      changed = true;
    }
    if (_operation.value != operation) {
      _operation.value = operation;
      changed = true;
    }

    return changed;
  }
}
