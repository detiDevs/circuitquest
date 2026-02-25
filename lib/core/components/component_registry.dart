import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/components/combinational/adder.dart';
import 'package:circuitquest/core/components/combinational/collector.dart';
import 'package:circuitquest/core/components/combinational/decoder.dart';
import 'package:circuitquest/core/components/combinational/multiplexer.dart';
import 'package:circuitquest/core/components/combinational/shift_left2.dart';
import 'package:circuitquest/core/components/combinational/sign_extend.dart';
import 'package:circuitquest/core/components/combinational/splitter.dart';
import 'package:circuitquest/core/components/cpu/alu_advanced.dart';
import 'package:circuitquest/core/components/cpu/alu_control.dart';
import 'package:circuitquest/core/components/cpu/control_unit.dart';
import 'package:circuitquest/core/components/cpu/data_memory.dart';
import 'package:circuitquest/core/components/cpu/instruction_memory.dart';
import 'package:circuitquest/core/components/cpu/program_counter.dart';
import 'package:circuitquest/core/components/cpu/register_block.dart';
import 'package:circuitquest/core/components/gates/and_gate.dart';
import 'package:circuitquest/core/components/gates/nand_gate.dart';
import 'package:circuitquest/core/components/gates/nor_gate.dart';
import 'package:circuitquest/core/components/gates/not_gate.dart';
import 'package:circuitquest/core/components/gates/or_gate.dart';
import 'package:circuitquest/core/components/gates/xor_gate.dart';
import 'package:circuitquest/core/components/input_source.dart';
import 'package:circuitquest/core/components/output_probe.dart';
import 'package:circuitquest/core/components/sequential/d_latch.dart';
import 'package:circuitquest/core/components/sequential/register.dart';

final Map<String, Component Function()> componentFactoryByName = {
  'InputSource': () => InputSource(),
  'OutputProbe': () => OutputProbe(),
  'And': () => AndGate(),
  'Or': () => OrGate(),
  'Not': () => NotGate(),
  'Nand': () => NandGate(),
  'Nor': () => NorGate(),
  'Xor': () => XorGate(),
  'HalfAdder': () => HalfAdder(),
  'FullAdder': () => FullAdder(),
  'DLatch': () => DLatch(),
  'Decoder': ()=> Decoder(selectBitWidth: 3),
  'Splitter8to1': () => Splitter(sliceCount: 8, sliceBitWidth: 1),
  'Splitter32to8': () => Splitter(sliceCount: 4, sliceBitWidth: 8),
  'Collector1to2': () => Collector(sliceCount: 2, sliceBitWidth: 1),
  'Collector1to5': () => Collector(sliceCount: 5, sliceBitWidth: 1),
  'Collector1to6': () => Collector(sliceCount: 6, sliceBitWidth: 1),
  'Collector8to16': () => Collector(sliceCount: 2, sliceBitWidth: 8),
  'Multiplexer2Inp': () => Multiplexer(inputCount: 2),
  'Multiplexer4Inp': () => Multiplexer(inputCount: 4),
  'Multiplexer8Inp': () => Multiplexer(inputCount: 8),
  'Register': () => Register(),
  'ProgramCounter': () => ProgramCounter(),
  'InstructionMemory': () => InstructionMemory(),
  'RegisterBlock': () => RegisterBlock(),
  'ALUAdvanced': () => ALUAdvanced(),
  'SignExtend': () => SignExtend(),
  'ControlUnit': () => ControlUnit(),
  'ALUControl': () => ALUControl(),
  'DataMemory': () => DataMemory(),
  'ShiftLeft2': () => ShiftLeft2(),
  'Adder32bit': ()=> RippleCarryAdder(),
};

Component? createComponentByName(String type) {
  final factory = componentFactoryByName[type];
  return factory?.call();
}