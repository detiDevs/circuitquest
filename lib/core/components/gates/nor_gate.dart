import 'package:circuitquest_flutter/core/components/gates/binary_gate.dart';

class NorGate extends BinaryGate {
  @override
  int compute(int a, int b) {
    final mask = (1 << outputs["output"]!.bitWidth) - 1;
    return ~(a | b) & mask;
  }
}