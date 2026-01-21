// Output probe component for testing
import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

class OutputProbe extends Component {
  OutputProbe() {
    // Default to a wide input; actual width is effectively the source's width.
    inputs['input'] = InputPin(this, bitWidth: 32);
  }

  /// Current bitwidth is driven by the connected source if present.
  int get bitWidth => inputs['input']!.source?.from.bitWidth ?? inputs['input']!.bitWidth;

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
