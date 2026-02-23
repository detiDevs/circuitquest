import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Control Unit for a simplified MIPS processor.
///
/// Supports R-type, lw, sw, and beq instructions.
/// Takes a 6-bit opcode as input and generates control signals.
///
/// Inputs:
///   - input: 6-bit opcode from instruction
///
/// Outputs:
///   - RegDst: 1-bit - Register destination (0=rt, 1=rd)
///   - Branch: 1-bit - Branch signal
///   - MemRead: 1-bit - Memory read enable
///   - MemtoReg: 1-bit - Memory to register (0=ALU, 1=Memory)
///   - AluOp: 2-bit - ALU operation code
///   - MemWrite: 1-bit - Memory write enable
///   - AluSrc: 1-bit - ALU source (0=register, 1=immediate)
///   - RegWrite: 1-bit - Register write enable
class ControlUnit extends Component {
  ControlUnit() {
    inputs['input'] = InputPin(this, bitWidth: 6);

    outputs['RegDst'] = OutputPin(this, bitWidth: 1);
    outputs['Branch'] = OutputPin(this, bitWidth: 1);
    outputs['MemRead'] = OutputPin(this, bitWidth: 1);
    outputs['MemtoReg'] = OutputPin(this, bitWidth: 1);
    outputs['AluOp'] = OutputPin(this, bitWidth: 2);
    outputs['MemWrite'] = OutputPin(this, bitWidth: 1);
    outputs['AluSrc'] = OutputPin(this, bitWidth: 1);
    outputs['RegWrite'] = OutputPin(this, bitWidth: 1);

    outputs['RegDst']!.value = 0;
    outputs['Branch']!.value = 0;
    outputs['MemRead']!.value = 0;
    outputs['MemtoReg']!.value = 0;
    outputs['AluOp']!.value = 0;
    outputs['MemWrite']!.value = 0;
    outputs['AluSrc']!.value = 0;
    outputs['RegWrite']!.value = 0;
  }

  @override
  bool evaluate() {
    inputs['input']!.updateFromSource();
    final int opcode = inputs['input']!.value;

    int regDst = 0, branch = 0, memRead = 0, memtoReg = 0;
    int aluOp = 0, memWrite = 0, aluSrc = 0, regWrite = 0;

    switch (opcode) {
      case 0: // R-type instructions
        regDst = 1;
        branch = 0;
        memRead = 0;
        memtoReg = 0;
        aluOp = 2;
        memWrite = 0;
        aluSrc = 0;
        regWrite = 1;
        break;

      case 35: // lw (load word) instruction
        regDst = 0;
        branch = 0;
        memRead = 1;
        memtoReg = 1;
        aluOp = 0;
        memWrite = 0;
        aluSrc = 1;
        regWrite = 1;
        break;

      case 43: // sw (store word) instruction
        regDst = 0; // don't care
        branch = 0;
        memRead = 0;
        memtoReg = 0; // don't care
        aluOp = 0;
        memWrite = 1;
        aluSrc = 1;
        regWrite = 0;
        break;

      case 4: // beq (branch if equal) instruction
        regDst = 0; // don't care
        branch = 1;
        memRead = 0;
        memtoReg = 0; // don't care
        aluOp = 1;
        memWrite = 0;
        aluSrc = 0;
        regWrite = 0;
        break;

      default: // Unsupported opcode - set all signals to 0
        regDst = 0;
        branch = 0;
        memRead = 0;
        memtoReg = 0;
        aluOp = 0;
        memWrite = 0;
        aluSrc = 0;
        regWrite = 0;
        break;
    }

    // Check if any output changed
    bool changed = false;
    changed |= _setOutputIfChanged('RegDst', regDst);
    changed |= _setOutputIfChanged('Branch', branch);
    changed |= _setOutputIfChanged('MemRead', memRead);
    changed |= _setOutputIfChanged('MemtoReg', memtoReg);
    changed |= _setOutputIfChanged('AluOp', aluOp);
    changed |= _setOutputIfChanged('MemWrite', memWrite);
    changed |= _setOutputIfChanged('AluSrc', aluSrc);
    changed |= _setOutputIfChanged('RegWrite', regWrite);

    return changed;
  }

  /// Helper method to set an output value and return if it changed.
  bool _setOutputIfChanged(String name, int newValue) {
    final bool hasChanged = outputs[name]!.value != newValue;
    outputs[name]!.value = newValue;
    return hasChanged;
  }
}
