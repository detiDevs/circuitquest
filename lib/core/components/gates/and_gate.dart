import 'package:circuitquest_flutter/core/components/gates/binary_gate.dart';

class AndGate extends BinaryGate{
  @override
  int compute(int a, int b) {
    return a & b;
  }
}