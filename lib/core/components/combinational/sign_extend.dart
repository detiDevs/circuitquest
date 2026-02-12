import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Sign Extend component for extending 16-bit immediate value to 32-bit
class SignExtend extends Component {
  late InputPin _input;
  late OutputPin _output;

  SignExtend() {
    _input = InputPin(this, bitWidth: 16);
    _output = OutputPin(this, bitWidth: 32);

    inputs['input'] = _input;
    outputs['outValue'] = _output;
    outputs['outValue']!.value = 0;
  }

  @override
  bool evaluate() {
    final value = _input.value & 0xFFFF;
    // Check sign bit (bit 15)
    final signBit = (value >> 15) & 1;

    // Sign extend: if sign bit is 1, fill upper bits with 1s
    int extended;
    if (signBit == 1) {
      extended = value | 0xFFFF0000;
    } else {
      extended = value & 0x0000FFFF;
    }

    if (_output.value != extended) {
      _output.value = extended;
      return true;
    }
    return false;
  }
}
