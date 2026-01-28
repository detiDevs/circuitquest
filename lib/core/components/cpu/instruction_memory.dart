import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Instruction Memory component
class InstructionMemory extends Component {
  late InputPin _addressInput;
  late OutputPin _instructionOutput;

  // Simple instruction memory with pre-loaded instruction
  final Map<int, int> _memory = {
    0: 4392992, // add $3, $1, $2
  };

  InstructionMemory() {
    _addressInput = InputPin(this, bitWidth: 32);
    _instructionOutput = OutputPin(this, bitWidth: 32);
    
    inputs['address'] = _addressInput;
    outputs['instruction'] = _instructionOutput;
  }

  @override
  bool evaluate() {
    final instruction = _memory[_addressInput.value] ?? 0;
    _instructionOutput.value = instruction;
    return false;
  }
}
