import 'package:circuitquest/core/components/gates/binary_gate.dart';

class XorGate extends BinaryGate {
  @override
  int compute(int a, int b) {
    return a ^ b;
  }
}