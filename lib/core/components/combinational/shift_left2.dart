import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Shift Left by 2 component
class ShiftLeft2 extends Component {
  late InputPin _input;
  late OutputPin _output;

  ShiftLeft2() {
    _input = InputPin(this, bitWidth: 32);
    _output = OutputPin(this, bitWidth: 32);
    
    inputs['in'] = _input;
    outputs['outValue'] = _output;
  }

  @override
  bool evaluate() {
    final shifted = (_input.value << 2) & 0xFFFFFFFF;
    
    if (_output.value != shifted) {
      _output.value = shifted;
      return true;
    }
    return false;
  }
}
