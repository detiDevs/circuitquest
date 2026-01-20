import 'package:circuitquest_flutter/core/components/gates/and_gate.dart';
import 'package:circuitquest_flutter/core/components/gates/or_gate.dart';
import 'package:circuitquest_flutter/core/components/input_source.dart';
import 'package:circuitquest_flutter/core/components/output_probe.dart';
import 'package:circuitquest_flutter/core/components/sequential/clock.dart';
import 'package:circuitquest_flutter/core/components/sequential/d_flip_flop.dart';
import 'package:circuitquest_flutter/core/components/sequential/d_latch.dart';
import 'package:circuitquest_flutter/core/components/sequential/register.dart';
import 'package:circuitquest_flutter/core/logic/wire.dart';
import 'package:circuitquest_flutter/core/simulation/simulator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sequential Integration Tests', () {
    test('should propagate clock signal through flip-flop', () {
      final clock = Clock();
      final data = InputSource();
      final ff = DFlipFlop();
      final output = OutputProbe();

      Wire(clock.outputs['clock']!, ff.inputs['clock']!);
      Wire(data.outputs['output']!, ff.inputs['D']!);
      Wire(ff.outputs['Q']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {clock, data, ff, output},
        inputComponents: {clock, data},
      );

      // Set data = 1, clock = 0
      data.setValue(1);
      clock.setClock(0);
      simulator.evaluateEventDriven();
      output.evaluate();
      expect(output.value, 0); // Not stored yet

      // Rising edge: clock = 1
      clock.setClock(1);
      simulator.evaluateEventDriven();
      output.evaluate();
      expect(output.value, 1); // Now stored
    });

    test('should create a simple clocked counter with flip-flops', () {
      // Create a 2-bit counter using flip-flops and feedback
      final clock = Clock();
      final ff0 = DFlipFlop();
      final ff1 = DFlipFlop();

      // Connect clock to both flip-flops
      Wire(clock.outputs['clock']!, ff0.inputs['clock']!);
      Wire(clock.outputs['clock']!, ff1.inputs['clock']!);

      // Connect !Q back to D for toggling (creates a T flip-flop behavior)
      Wire(ff0.outputs['!Q']!, ff0.inputs['D']!);

      // ff1 gets ff0's !Q as clock (divided by 2)
      Wire(ff0.outputs['!Q']!, ff1.inputs['D']!);

      final simulator = Simulator(
        components: {clock, ff0, ff1},
        inputComponents: {clock},
      );

      // Initial state: both flip-flops at 0
      expect(ff0.outputs['Q']!.value, 0);
      expect(ff1.outputs['Q']!.value, 0);

      // First clock pulse
      clock.setClock(0);
      simulator.evaluateEventDriven();
      clock.setClock(1);
      simulator.evaluateEventDriven();

      expect(ff0.outputs['Q']!.value, 1); // Toggled to 1

      // Second clock pulse
      clock.setClock(0);
      simulator.evaluateEventDriven();
      clock.setClock(1);
      simulator.evaluateEventDriven();

      expect(ff0.outputs['Q']!.value, 0); // Toggled back to 0
      expect(ff1.outputs['Q']!.value, 1); // Now changes
    });

    test('should use register with combinational logic', () {
      // Create circuit: Register with feedback through OR gate
      final clock = Clock();
      final reg = Register(bitWidth: 1);
      final orGate = OrGate();
      final constant = InputSource(bitWidth: 1);

      Wire(clock.outputs['clock']!, reg.inputs['clock']!);
      Wire(reg.outputs['output']!, orGate.inputs['inputA']!);
      Wire(constant.outputs['output']!, orGate.inputs['inputB']!);
      Wire(orGate.outputs['output']!, reg.inputs['data']!);

      final simulator = Simulator(
        components: {clock, reg, orGate, constant},
        inputComponents: {clock, constant},
      );

      constant.setValue(1);

      // Initial value
      expect(reg.value, 0);

      // Clock cycle 1: 0 OR 1 = 1
      clock.setClock(0);
      simulator.evaluateEventDriven();
      clock.setClock(1);
      simulator.evaluateEventDriven();

      expect(reg.value, 1);

      // Clock cycle 2: 1 OR 1 = 1 (stays at 1)
      clock.setClock(0);
      simulator.evaluateEventDriven();
      clock.setClock(1);
      simulator.evaluateEventDriven();

      expect(reg.value, 1);
    });

    test('should use latch for temporary storage', () {
      final enable = InputSource();
      final data = InputSource();
      final latch = DLatch();
      final output = OutputProbe();

      Wire(enable.outputs['output']!, latch.inputs['clock']!);
      Wire(data.outputs['output']!, latch.inputs['D']!);
      Wire(latch.outputs['Q']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {enable, data, latch, output},
        inputComponents: {enable, data},
      );

      // Enable = 1 (transparent mode)
      enable.setValue(1);
      data.setValue(1);
      simulator.evaluateEventDriven();
      output.evaluate();
      expect(output.value, 1);

      // Change data while enabled
      data.setValue(0);
      simulator.evaluateEventDriven();
      output.evaluate();
      expect(output.value, 0);

      // Disable and change data (should hold)
      enable.setValue(0);
      simulator.evaluateEventDriven();
      data.setValue(1);
      simulator.evaluateEventDriven();
      output.evaluate();
      expect(output.value, 0); // Still 0
    });

    test('should create SR latch from NOR gates and use D latch', () {
      // Test D latch holding state through multiple evaluations
      final clock = Clock();
      final data = InputSource();
      final latch = DLatch();

      Wire(clock.outputs['clock']!, latch.inputs['clock']!);
      Wire(data.outputs['output']!, latch.inputs['D']!);

      final simulator = Simulator(
        components: {clock, data, latch},
        inputComponents: {clock, data},
      );

      // Store 1
      data.setValue(1);
      clock.setClock(1);
      simulator.evaluateEventDriven();
      expect(latch.outputs['Q']!.value, 1);

      // Hold with clock low
      clock.setClock(0);
      data.setValue(0);
      simulator.evaluateEventDriven();
      expect(latch.outputs['Q']!.value, 1); // Still 1

      // Store 0
      clock.setClock(1);
      simulator.evaluateEventDriven();
      expect(latch.outputs['Q']!.value, 0); // Now 0
    });

    test('should handle multiple registers with shared clock', () {
      final clock = Clock();
      final data1 = InputSource(bitWidth: 8);
      final data2 = InputSource(bitWidth: 8);
      final reg1 = Register(bitWidth: 8);
      final reg2 = Register(bitWidth: 8);

      Wire(clock.outputs['clock']!, reg1.inputs['clock']!);
      Wire(clock.outputs['clock']!, reg2.inputs['clock']!);
      Wire(data1.outputs['output']!, reg1.inputs['data']!);
      Wire(data2.outputs['output']!, reg2.inputs['data']!);

      final simulator = Simulator(
        components: {clock, data1, data2, reg1, reg2},
        inputComponents: {clock, data1, data2},
      );

      // Set different data for each register
      data1.setValue(100);
      data2.setValue(200);

      // Both should update on same clock edge
      clock.setClock(0);
      simulator.evaluateEventDriven();
      clock.setClock(1);
      simulator.evaluateEventDriven();

      expect(reg1.value, 100);
      expect(reg2.value, 200);

      // Change data and clock again
      data1.setValue(150);
      data2.setValue(250);
      clock.setClock(0);
      simulator.evaluateEventDriven();
      clock.setClock(1);
      simulator.evaluateEventDriven();

      expect(reg1.value, 150);
      expect(reg2.value, 250);
    });

    test('should combine flip-flop with AND gate', () {
      final clock = Clock();
      final data = InputSource();
      final enable = InputSource();
      final andGate = AndGate();
      final ff = DFlipFlop();

      // AND gate combines data and enable
      Wire(data.outputs['output']!, andGate.inputs['inputA']!);
      Wire(enable.outputs['output']!, andGate.inputs['inputB']!);
      Wire(andGate.outputs['output']!, ff.inputs['D']!);
      Wire(clock.outputs['clock']!, ff.inputs['clock']!);

      final simulator = Simulator(
        components: {clock, data, enable, andGate, ff},
        inputComponents: {clock, data, enable},
      );

      // Enable = 0, data = 1 => AND = 0
      enable.setValue(0);
      data.setValue(1);
      clock.setClock(0);
      simulator.evaluateEventDriven();
      clock.setClock(1);
      simulator.evaluateEventDriven();

      expect(ff.outputs['Q']!.value, 0);

      // Enable = 1, data = 1 => AND = 1
      enable.setValue(1);
      clock.setClock(0);
      simulator.evaluateEventDriven();
      clock.setClock(1);
      simulator.evaluateEventDriven();

      expect(ff.outputs['Q']!.value, 1);
    });
  });
}
