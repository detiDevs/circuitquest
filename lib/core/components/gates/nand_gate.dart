import 'package:circuitquest/core/components/gates/binary_gate.dart';

class NandGate extends BinaryGate {
  NandGate() {
    outputs['outValue']!.value = 1;
  }
  @override
  int compute(int a, int b) {
    final mask = (1 << outputs["outValue"]!.bitWidth) - 1;
    return ~(a & b) & mask;
  }
}
