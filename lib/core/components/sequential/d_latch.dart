import 'package:cirquitquest_flutter/core/components/base/component.dart';
import 'package:cirquitquest_flutter/core/logic/pin.dart';

/// D Latch - stores a value when clock is high
/// When clock is high (1), output Q follows input D
/// When clock is low (0), output Q holds its previous value
class DLatch extends Component {
  int _storedValue = 0;

  DLatch({int bitWidth = 1}) {
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

    if (clock == 1) {
      // Clock is high - latch is transparent, output follows input
      _storedValue = d;
    }
    // When clock is low, keep stored value

    final mask = outputs['Q']!.mask;
    final newQ = _storedValue;
    final newNotQ = (~_storedValue) & mask;

    final qChanged = outputs['Q']!.value != newQ;
    final notQChanged = outputs['!Q']!.value != newNotQ;

    outputs['Q']!.value = newQ;
    outputs['!Q']!.value = newNotQ;

    return qChanged || notQChanged;
  }
}
