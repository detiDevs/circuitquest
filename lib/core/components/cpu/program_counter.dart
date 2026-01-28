import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Program Counter component for MIPS processor
class ProgramCounter extends Component {
  late InputPin _clockInput;
  late InputPin _nextPcInput;
  late OutputPin _pcOutput;
  int _currentPC = 0;

  ProgramCounter() {
    _clockInput = InputPin(this, bitWidth: 1);
    _nextPcInput = InputPin(this, bitWidth: 32);
    _pcOutput = OutputPin(this, bitWidth: 32);
    
    inputs['clock'] = _clockInput;
    inputs['input'] = _nextPcInput;
    outputs['outValue'] = _pcOutput;
  }

  @override
  bool evaluate() {
    // PC updates on clock pulse
    _pcOutput.value = _currentPC;
    return false;
  }

  @override
  void tick() {
    if (_clockInput.value == 1) {
      _currentPC = _nextPcInput.value;
    }
  }
}
