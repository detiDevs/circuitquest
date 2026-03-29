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

class ComponentType {
  final String name;
  final String displayName;
  final String iconPath;
  final bool isAsset;
  final Component Function() createComponent;

  const ComponentType({
    required this.name,
    required this.displayName,
    required this.iconPath,
    required this.createComponent,
    this.isAsset = true,
  });
}

final List<ComponentType> availableComponents = [
  ComponentType(
    name: 'InputSource',
    displayName: 'Input',
    iconPath: 'assets/gates/Input.svg',
    createComponent: () => InputSource(),
  ),
  ComponentType(
    name: 'OutputProbe',
    displayName: 'Output',
    iconPath: 'assets/gates/Output.svg',
    createComponent: () => OutputProbe(),
  ),
  ComponentType(
    name: 'And',
    displayName: 'AND Gate',
    iconPath: 'assets/gates/And.svg',
    createComponent: () => AndGate(),
  ),
  ComponentType(
    name: 'Or',
    displayName: 'OR Gate',
    iconPath: 'assets/gates/Or.svg',
    createComponent: () => OrGate(),
  ),
  ComponentType(
    name: 'Not',
    displayName: 'NOT Gate',
    iconPath: 'assets/gates/Not.svg',
    createComponent: () => NotGate(),
  ),
  ComponentType(
    name: 'Nand',
    displayName: 'NAND Gate',
    iconPath: 'assets/gates/Nand.svg',
    createComponent: () => NandGate(),
  ),
  ComponentType(
    name: 'Nor',
    displayName: 'NOR Gate',
    iconPath: 'assets/gates/Nor.svg',
    createComponent: () => NorGate(),
  ),
  ComponentType(
    name: 'Xor',
    displayName: 'XOR Gate',
    iconPath: 'assets/gates/Xor.svg',
    createComponent: () => XorGate(),
  ),
  ComponentType(
    name: 'HalfAdder',
    displayName: 'Half Adder',
    iconPath: 'assets/gates/HalfAdder.svg',
    createComponent: () => HalfAdder(),
  ),
  ComponentType(
    name: 'FullAdder',
    displayName: 'Full Adder',
    iconPath: 'assets/gates/FullAdder.svg',
    createComponent: () => FullAdder(),
  ),
  ComponentType(
    name: 'DFlipflop',
    displayName: 'D-Latch',
    iconPath: 'assets/gates/DFlipflop.svg',
    createComponent: () => DFlipflop(),
  ),
  ComponentType(
    name: 'Register',
    displayName: 'Register',
    iconPath: 'assets/gates/Register.svg',
    createComponent: () => Register(),
  ),
  ComponentType(
    name: 'Decoder',
    displayName: 'Decoder',
    iconPath: 'assets/gates/DecoderThreeBit.svg',
    createComponent: () => Decoder(selectBitWidth: 3),
  ),
  ComponentType(
    name: 'Splitter8to1',
    displayName: 'Splitter 8 to 1',
    iconPath: 'assets/gates/Splitter8to1.svg',
    createComponent: () => Splitter(sliceCount: 8, sliceBitWidth: 1),
  ),
  ComponentType(
    name: 'Splitter32to8',
    displayName: 'Splitter 32 to 8',
    iconPath: 'assets/gates/Splitter32to8.svg',
    createComponent: () => Splitter(sliceCount: 4, sliceBitWidth: 8),
  ),
  ComponentType(
    name: 'Collector1to2',
    displayName: 'Collector 1 to 2',
    iconPath: 'assets/gates/Collector1to2.svg',
    createComponent: () => Collector(sliceCount: 2, sliceBitWidth: 1),
  ),
  ComponentType(
    name: 'Collector1to5',
    displayName: 'Collector 1 to 5',
    iconPath: 'assets/gates/Collector1to5.svg',
    createComponent: () => Collector(sliceCount: 5, sliceBitWidth: 1),
  ),
  ComponentType(
    name: 'Collector1to6',
    displayName: 'Collector 1 to 6',
    iconPath: 'assets/gates/Collector1to6.svg',
    createComponent: () => Collector(sliceCount: 6, sliceBitWidth: 1),
  ),
  ComponentType(
    name: 'Collector8to16',
    displayName: 'Collector8to16',
    iconPath: 'assets/gates/Collector8to16.svg',
    createComponent: () => Collector(sliceCount: 2, sliceBitWidth: 8),
  ),
  ComponentType(
    name: 'Multiplexer2Inp',
    displayName: 'Multiplexer2Inp',
    iconPath: 'assets/gates/Multiplexer2Inp.svg',
    createComponent: () => Multiplexer(inputCount: 2),
  ),
  ComponentType(
    name: 'Multiplexer4Inp',
    displayName: 'Multiplexer4Inp',
    iconPath: 'assets/gates/Multiplexer4Inp.svg',
    createComponent: () => Multiplexer(inputCount: 4),
  ),
  ComponentType(
    name: 'Multiplexer8Inp',
    displayName: 'Multiplexer8Inp',
    iconPath: 'assets/gates/Multiplexer8Inp.svg',
    createComponent: () => Multiplexer(inputCount: 8),
  ),
  ComponentType(
    name: 'Adder32bit',
    displayName: 'Adder32bit',
    iconPath: 'assets/gates/Adder32bit.svg',
    createComponent: () => RippleCarryAdder(),
  ),
  ComponentType(
    name: 'ProgramCounter',
    displayName: 'ProgramCounter',
    iconPath: 'assets/gates/ProgramCounter.svg',
    createComponent: () => ProgramCounter(),
  ),
  ComponentType(
    name: 'InstructionMemory',
    displayName: 'InstructionMemory',
    iconPath: 'assets/gates/InstructionMemory.svg',
    createComponent: () => InstructionMemory(),
  ),
  ComponentType(
    name: 'RegisterBlock',
    displayName: 'RegisterBlock',
    iconPath: 'assets/gates/RegisterBlock.svg',
    createComponent: () => RegisterBlock(),
  ),
  ComponentType(
    name: 'ALUAdvanced',
    displayName: 'ALUAdvanced',
    iconPath: 'assets/gates/ALUAdvanced.svg',
    createComponent: () => ALUAdvanced(),
  ),
  ComponentType(
    name: 'SignExtend',
    displayName: 'SignExtend',
    iconPath: 'assets/gates/SignExtend.svg',
    createComponent: () => SignExtend(),
  ),
  ComponentType(
    name: 'ControlUnit',
    displayName: 'ControlUnit',
    iconPath: 'assets/gates/ControlUnit.svg',
    createComponent: () => ControlUnit(),
  ),
  ComponentType(
    name: 'ALUControl',
    displayName: 'ALUControl',
    iconPath: 'assets/gates/ALUControl.svg',
    createComponent: () => ALUControl(),
  ),
  ComponentType(
    name: 'DataMemory',
    displayName: 'DataMemory',
    iconPath: 'assets/gates/DataMemory.svg',
    createComponent: () => DataMemory(),
  ),
  ComponentType(
    name: 'ShiftLeft2',
    displayName: 'ShiftLeft2',
    iconPath: 'assets/gates/ShiftLeft2.svg',
    createComponent: () => ShiftLeft2(),
  ),
];

ComponentType? getComponentTypeByName(String name) {
  for (final componentType in availableComponents) {
    if (componentType.name == name) {
      return componentType;
    }
  }
  return null;
}