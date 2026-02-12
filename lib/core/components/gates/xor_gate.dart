import 'package:circuitquest/core/components/gates/binary_gate.dart';

class XorGate extends BinaryGate {
  XorGate() {
    outputs['outValue']!.value = 0;
  }

  @override
  int compute(int a, int b) {
    return a ^ b;
  }
}
