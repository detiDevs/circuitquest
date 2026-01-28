// Input source component for testing
import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

class InputSource extends Component {
  InputSource({int bitWidth = 1}) {
    outputs['outValue'] = OutputPin(this, bitWidth: bitWidth);
  }

  void setValue(int value) {
    outputs['outValue']!.value = value;
  }

  @override
  bool evaluate() {
    // Input sources always return true to trigger downstream propagation
    return true;
  }
}
