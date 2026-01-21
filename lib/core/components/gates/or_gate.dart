import 'package:circuitquest/core/components/gates/binary_gate.dart';

class OrGate extends BinaryGate {
  @override
  int compute(int a, int b) {
    return a | b;
  }
}