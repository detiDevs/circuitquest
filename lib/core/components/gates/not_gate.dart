import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

class NotGate extends Component {
  NotGate() {
    inputs["input"] = InputPin(this);
    outputs["outValue"] = OutputPin(this);
    outputs['outValue']!.value = 1;
  }

  @override
  bool evaluate() {
    inputs["input"]!.updateFromSource();

    final input = inputs["input"]!.value;
    final mask = (1 << outputs["outValue"]!.bitWidth) - 1;

    final newValue = ~input & mask;
    final changed = outputs["outValue"]!.value != newValue;

    outputs["outValue"]!.value = newValue;
    return changed;
  }
}
