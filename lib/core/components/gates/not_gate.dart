import 'package:cirquitquest_flutter/core/components/base/component.dart';
import 'package:cirquitquest_flutter/core/logic/pin.dart';

class NotGate extends Component {
  NotGate() {
    inputs["input"] = InputPin(this);
    outputs["output"] = OutputPin(this);
  }

  @override
  bool evaluate() {
    final input = inputs["input"]!.value;
    final mask = (1 << outputs["output"]!.bitWidth) - 1;

    final newValue = ~input & mask;
    final changed = outputs["output"]!.value != newValue;

    outputs["output"]!.value = newValue;
    return changed;
  }
}