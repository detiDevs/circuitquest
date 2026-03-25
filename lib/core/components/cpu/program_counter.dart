import 'package:circuitquest/core/components/base/sequentialComponent.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Program Counter component for MIPS processor
class ProgramCounter extends SequentialComponent {
  late InputPin _nextPcInput;
  late OutputPin _pcOutput;
  int _currentPC = 0;
  bool _shoudEvaluateNormally = true;
  int _nextValue = 0;

  ProgramCounter() {
    _nextPcInput = InputPin(this, bitWidth: 32);
    _pcOutput = OutputPin(this, bitWidth: 32);

    inputs['input'] = _nextPcInput;
    outputs['outValue'] = _pcOutput;
    outputs['outValue']!.value = 0;
  }

  int get value => outputs['outValue']!.value;

  /// Sets the value of the PC to the given byte adress [newValue]
  /// If [newValue] cannot be converted to a word adress (i.e. is not divisible by 4), the PC value will remain unchanged.
  set value(int newValue) {
    if (newValue % 4 == 0) outputs['outValue']!.value = newValue;
  }

  @override
  bool evaluate() {
    _nextPcInput.updateFromSource();
    final nextValue = _nextPcInput.value;
    _nextValue = nextValue;

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
      _pcOutput.value =_currentPC;
      _shoudEvaluateNormally = true;
    }
  }

  /// Returns the current PC value
  int get currentPC => _currentPC;
}
