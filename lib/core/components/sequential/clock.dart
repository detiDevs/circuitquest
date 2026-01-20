import 'package:circuitquest_flutter/core/components/base/component.dart';
import 'package:circuitquest_flutter/core/logic/pin.dart';

/// A clock component that generates periodic pulses
/// The clock value must be manually toggled using setClock()
class Clock extends Component {
  Clock() {
    outputs['clock'] = OutputPin(this, bitWidth: 1);
  }

  void setClock(int value) {
    outputs['clock']!.value = value;
  }

  void toggle() {
    outputs['clock']!.value = outputs['clock']!.value == 0 ? 1 : 0;
  }

  @override
  bool evaluate() {
    // Clock is controlled externally, always trigger downstream
    return true;
  }
}
