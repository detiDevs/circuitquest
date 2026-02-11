import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Register - stores a multi-bit value on the rising edge of the clock
class Register extends Component {
  int _storedValue = 0;
  int _previousClock = 0;

  Register({int bitWidth = 32}) {
    inputs['data'] = InputPin(this, bitWidth: bitWidth);
    inputs['clock'] = InputPin(this, bitWidth: 1);
    outputs['outValue'] = OutputPin(this, bitWidth: bitWidth);
    outputs['outValue']!.value = 0;
  }

  @override
  bool evaluate() {
    inputs['data']!.updateFromSource();
    inputs['clock']!.updateFromSource();

    final clock = inputs['clock']!.value;
    final data = inputs['data']!.value;

    // Detect rising edge (0 -> 1 transition)
    if (_previousClock == 0 && clock == 1) {
      _storedValue = data;
    }

    _previousClock = clock;

    final newValue = _storedValue;
    final changed = outputs['output']!.value != newValue;

    outputs['output']!.value = newValue;

    return changed;
  }

  /// Resets the register to zero
  void reset() {
    _storedValue = 0;
    _previousClock = 0;
    outputs['output']!.value = 0;
  }

  /// Gets the current stored value
  int get value => _storedValue;
}
