// Output probe component for testing
import 'package:circuitquest_flutter/core/components/base/component.dart';
import 'package:circuitquest_flutter/core/logic/pin.dart';

class OutputProbe extends Component {
  OutputProbe({int bitWidth = 1}) {
    inputs['input'] = InputPin(this, bitWidth: bitWidth);
  }

  int get value {
    inputs['input']!.updateFromSource();
    return inputs['input']!.value;
  }

  @override
  bool evaluate() {
    final oldValue = inputs['input']!.value;
    inputs['input']!.updateFromSource();
    return oldValue != inputs['input']!.value;
  }
}
