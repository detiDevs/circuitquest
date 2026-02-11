import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Instruction Memory component
class InstructionMemory extends Component {
  late InputPin _addressInput;
  late OutputPin _instructionOutput;

  List<int> _instructionList = [];

  InstructionMemory() {
    _addressInput = InputPin(this, bitWidth: 32);
    _instructionOutput = OutputPin(this, bitWidth: 32);

    inputs['readAddress'] = _addressInput;
    outputs['instruction'] = _instructionOutput;
    outputs['instruction']!.value = 0;
  }

  /// Load a list of instructions into the instruction memory.
  /// Only for testing and level initialization.
  void loadInstructions(List<int> instructions) {
    _instructionList = instructions;
  }

  @override
  bool evaluate() {
    final address =
        _addressInput.value ~/ 4; // Convert byte address to word address
    final instruction = address < _instructionList.length
        ? _instructionList[address]
        : 0;
    print("Instruction: $instruction");

    if (_instructionOutput.value != instruction) {
      _instructionOutput.value = instruction;
      return true;
    }
    return false;
  }
}
