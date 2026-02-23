import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Program Counter component for MIPS processor
class ProgramCounter extends Component {
  late InputPin _nextPcInput;
  late OutputPin _pcOutput;
  int _currentPC = 0;
  bool _firstEval = true;

  ProgramCounter() {
    _nextPcInput = InputPin(this, bitWidth: 32);
    _pcOutput = OutputPin(this, bitWidth: 32);

    inputs['input'] = _nextPcInput;
    outputs['outValue'] = _pcOutput;
    outputs['outValue']!.value = 0;
  }

  @override
  bool evaluate() {
    final nextValue = _nextPcInput.value;
    _pcOutput.value = nextValue;

    // On first evaluation, always propagate to trigger downstream components
    if (_firstEval) {
      _firstEval = false;
      return true;
    }

    if (_currentPC != nextValue) {
      _currentPC = nextValue;
      return true;
    }
    return false;
  }
}
