// Input source component for testing
import 'package:cirquitquest_flutter/core/components/base/component.dart';
import 'package:cirquitquest_flutter/core/logic/pin.dart';

class InputSource extends Component {
  InputSource({int bitWidth = 1}) {
    outputs['output'] = OutputPin(this, bitWidth: bitWidth);
  }

  void setValue(int value) {
    outputs['output']!.value = value;
  }

  @override
  bool evaluate() {
    // Input sources always return true to trigger downstream propagation
    return true;
  }
}
