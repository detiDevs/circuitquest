// Input source component for testing
import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

class InputSource extends Component {
  InputSource({int bitWidth = 1, int value = 0}) {
    outputs['outValue'] = OutputPin(this, bitWidth: bitWidth);
    setValue(value);
  }

  // Sets the value to the given int. 
  // If the given value is larger than the maximum allowed by the bitwidth, it will be set to this maximum.
  // Returns the new value of the input source.
  int setValue(int value) {
    outputs['outValue']!.value = value;
    return outputs['outValue']!.value;
  }

  // Sets the bitwidth to the given int.
  // If the given bitwidth is larger than 32, the bitwidth will be set to 32.
  // If the previous value is larger than the new bitwidth, it will be set to the value allowed by the bitwidth
  // Returns the new bitwidth of the input source.
  int setBitWidth(int bitWidth) {
    if (bitWidth > 32) bitWidth = 32;
    outputs['outValue']!.bitWidth = bitWidth;
    return bitWidth;
  }

  @override
  bool evaluate() {
    // Input sources always return true to trigger downstream propagation
    return true;
  }
}
