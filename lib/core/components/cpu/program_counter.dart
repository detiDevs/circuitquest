import 'package:circuitquest/core/components/base/sequentialComponent.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Program Counter component for MIPS processor
class ProgramCounter extends SequentialComponent {
  late InputPin _nextPcInput;
  late OutputPin _pcOutput;
  int _currentPC = 0;
  bool _shoudEvaluateNormally = true;
  int _nextValue = 0;
  bool _nextValueWasManuallySet = false;

  ProgramCounter() {
    _nextPcInput = InputPin(this, bitWidth: 32);
    _pcOutput = OutputPin(this, bitWidth: 32);

    inputs['input'] = _nextPcInput;
    outputs['outValue'] = _pcOutput;
    outputs['outValue']!.value = 0;
  }

  int get nextValue => _nextValue;

  /// Sets the value of the PC to the given byte adress [nextValue]
  /// If [nextValue] cannot be converted to a word adress (i.e. is not divisible by 4), the PC value will remain unchanged.
  set nextValue(int nextValue) {
    if (nextValue % 4 == 0) {
      _nextValue = nextValue;
      _nextValueWasManuallySet = true;
    }
  }

  @override
  bool evaluate() {
    if (!_nextValueWasManuallySet) {
      _nextPcInput.updateFromSource();
      final nextValue = _nextPcInput.value;
      _nextValue = nextValue;
    }

    // On first evaluation in cycle return true, wait for clock afterwards
    if (_shoudEvaluateNormally) {
      _shoudEvaluateNormally = false;
      return true;
    }
    return false;
  }

  @override
  void applyNewState() {
    if (_currentPC != _nextValue) {
      _currentPC = _nextValue;
      _pcOutput.value = _currentPC;
      _shoudEvaluateNormally = true;
      _nextValueWasManuallySet = false;
    }
  }

  /// Returns the current PC value
  int get currentPC => _currentPC;
}
