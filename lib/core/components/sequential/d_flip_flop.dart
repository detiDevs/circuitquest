import 'package:cirquitquest_flutter/core/components/base/component.dart';
import 'package:cirquitquest_flutter/core/logic/pin.dart';

/// D Flip-Flop - stores a value on the rising edge of the clock
/// Only updates on the rising edge (0 -> 1 transition) of clock
class DFlipFlop extends Component {
  int _storedValue = 0;
  int _previousClock = 0;

  DFlipFlop({int bitWidth = 1}) {
    inputs['D'] = InputPin(this, bitWidth: bitWidth);
    inputs['clock'] = InputPin(this, bitWidth: 1);
    outputs['Q'] = OutputPin(this, bitWidth: bitWidth);
    outputs['!Q'] = OutputPin(this, bitWidth: bitWidth);
  }

  @override
  bool evaluate() {
    inputs['D']!.updateFromSource();
    inputs['clock']!.updateFromSource();

    final clock = inputs['clock']!.value;
    final d = inputs['D']!.value;

    // Detect rising edge (0 -> 1 transition)
    if (_previousClock == 0 && clock == 1) {
      _storedValue = d;
    }

    _previousClock = clock;

    final mask = outputs['Q']!.mask;
    final newQ = _storedValue;
    final newNotQ = (~_storedValue) & mask;

    final qChanged = outputs['Q']!.value != newQ;
    final notQChanged = outputs['!Q']!.value != newNotQ;

    outputs['Q']!.value = newQ;
    outputs['!Q']!.value = newNotQ;

    return qChanged || notQChanged;
  }

  /// Resets the flip-flop to initial state
  void reset() {
    _storedValue = 0;
    _previousClock = 0;
    outputs['Q']!.value = 0;
    outputs['!Q']!.value = outputs['Q']!.mask;
  }
}
