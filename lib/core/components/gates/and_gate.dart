import 'package:circuitquest/core/components/gates/binary_gate.dart';

class AndGate extends BinaryGate{
  AndGate(){
    outputs['outValue']!.value = 0;
  }
  @override
  int compute(int a, int b) {
    return a & b;
  }
}