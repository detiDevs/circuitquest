import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// ALU Control unit that generates ALU control signal based on ALUOp and function bits
class ALUControl extends Component {
  late InputPin _aluOp;
  late InputPin _functionBits;
  late OutputPin _aluControl;

  ALUControl() {
    _aluOp = InputPin(this, bitWidth: 2);
    _functionBits = InputPin(this, bitWidth: 6);
    _aluControl = OutputPin(this, bitWidth: 4);
    
    inputs['aluOp'] = _aluOp;
    inputs['functionBits'] = _functionBits;
    outputs['aluControl'] = _aluControl;
  }

  @override
  bool evaluate() {
    final aluOp = _aluOp.value;
    final funct = _functionBits.value;
    
    int control;
    if (aluOp == 2) { // R-type
      // Use function bits to determine operation
      control = switch (funct) {
        32 => 2, // ADD
        34 => 6, // SUBTRACT
        36 => 0, // AND
        37 => 1, // OR
        42 => 7, // SLT
        _ => 0,
      };
    } else if (aluOp == 0) { // LW/SW
      control = 2; // ADD
    } else if (aluOp == 1) { // BEQ
      control = 6; // SUBTRACT
    } else {
      control = 0;
    }
    
    if (_aluControl.value != control) {
      _aluControl.value = control;
      return true;
    }
    return false;
  }
}
