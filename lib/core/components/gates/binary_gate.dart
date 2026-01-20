import 'package:cirquitquest_flutter/core/components/base/component.dart';
import 'package:cirquitquest_flutter/core/logic/pin.dart';

abstract class BinaryGate extends Component {
  BinaryGate() {
    inputs["inputA"] = InputPin(this);
    inputs["inputB"] = InputPin(this);
    outputs["output"] = OutputPin(this);
  }

  int compute(int a, int b);

  @override
  bool evaluate() {
    inputs["inputA"]!.updateFromSource();
    inputs["inputB"]!.updateFromSource();
    
    int a = inputs["inputA"]!.value;
    int b = inputs["inputB"]!.value;
    int out = outputs["output"]!.value;
    int newValue = compute(a, b);
    bool valueChanged = newValue != out;
    outputs["output"]!.value = newValue;
    return valueChanged;
  }
}