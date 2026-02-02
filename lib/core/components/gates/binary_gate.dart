import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

abstract class BinaryGate extends Component {
  BinaryGate() {
    inputs["input1"] = InputPin(this);
    inputs["input2"] = InputPin(this);
    outputs["outValue"] = OutputPin(this);
  }

  int compute(int a, int b);

  @override
  bool evaluate() {
    inputs["input1"]!.updateFromSource();
    inputs["input2"]!.updateFromSource();
    
    int a = inputs["input1"]!.value;
    int b = inputs["input2"]!.value;
    int out = outputs["outValue"]!.value;
    int newValue = compute(a, b);
    bool valueChanged = newValue != out;
    outputs["outValue"]!.value = newValue;
    return valueChanged;
  }
}