// Input source component for testing
import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

class InputSource extends Component {
  InputSource({int bitWidth = 1, int value = 0}) {
    outputs['outValue'] = OutputPin(this, bitWidth: bitWidth);
    this.value = value;
  }

  int get value => outputs['outValue']!.value;

  /// Sets the value to the given [value], unless it is not compatible with the bitwidth.
  /// In that case the value will be set to the maximum allowed by the bitwidth
  set value(int value) {
    outputs['outValue']!.value = value;
  }

  int get bitWidth => outputs['outValue']!.bitWidth;

  /// Sets the bitwidth to the given [bitWidth].
  // If the given bitwidth is larger than 32, the bitwidth will be set to 32.
  // If the previous value is larger than the new bitwidth, it will be set to the value allowed by the bitwidth.
  set bitWidth(int bitWidth) {
    if (bitWidth > 32) bitWidth = 32;
    outputs['outValue']!.bitWidth = bitWidth;
  }

  @override
  bool evaluate() {
    // Input sources always return true to trigger downstream propagation
    return true;
  }
}
