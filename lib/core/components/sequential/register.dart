import 'package:circuitquest/core/components/base/sequentialComponent.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Register - stores a multi-bit value on the rising edge of the clock
class Register extends SequentialComponent {
  int _storedValue = 0;
  int _newValue = 0;

  Register({int bitWidth = 32}) {
    inputs['data'] = InputPin(this, bitWidth: bitWidth);
    outputs['outValue'] = OutputPin(this, bitWidth: bitWidth);
    outputs['outValue']!.value = 0;
  }

  @override
  bool evaluate() {
    inputs['data']!.updateFromSource();

    final data = inputs['data']!.value;

      _newValue = data;

    return false;
  }

  @override
  void applyNewState(){
    _storedValue = _newValue;
    // KRITISCH: Korrekter Output-Pin Name verwenden!
    outputs['outValue']!.value = _storedValue;
  }

  /// Resets the register to zero
  void reset() {
    _storedValue = 0;
    _newValue = 0;
    // KRITISCH: Korrekter Output-Pin Name verwenden!
    outputs['outValue']!.value = 0;
  }

  /// Gets the current stored value
  int get value => _storedValue;
}
