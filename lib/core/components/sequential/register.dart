import 'package:circuitquest/core/components/base/sequentialComponent.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Register - stores a multi-bit value on the rising edge of the clock
class Register extends SequentialComponent {
  int _storedValue = 0;
  int _newValue = 0;

  Register({int bitWidth = 32, int initialValue = 0}) {
    inputs['data'] = InputPin(this, bitWidth: bitWidth);
    inputs['writeEnable'] = InputPin(this, bitWidth: 1);
    outputs['outValue'] = OutputPin(this, bitWidth: bitWidth);
    _storedValue = initialValue;
    _newValue = initialValue;
    outputs['outValue']!.value = initialValue;
  }

  @override
  bool evaluate() {
    inputs['data']!.updateFromSource();
    inputs['writeEnable']!.updateFromSource();

    final data = inputs['data']!.value;
    final writeEnable = inputs['writeEnable']!.value;
    if (writeEnable == 1) {
      _newValue = data;
    }

    return false;
  }

  @override
  void applyNewState() {
    inputs['writeEnable']!.updateFromSource();

    if (inputs['writeEnable']!.value == 1) {

      _storedValue = _newValue;
      outputs['outValue']!.value = _storedValue;
    }
  }

  /// Resets the register to zero
  void reset() {
    _storedValue = 0;
    _newValue = 0;
    outputs['outValue']!.value = 0;
  }

  /// Gets the current stored value
  int get value => _storedValue;
}
