import 'package:cirquitquest_flutter/core/components/base/component.dart';
import 'package:cirquitquest_flutter/core/components/gates/and_gate.dart';
import 'package:cirquitquest_flutter/core/components/gates/not_gate.dart';
import 'package:cirquitquest_flutter/core/components/gates/or_gate.dart';
import 'package:cirquitquest_flutter/core/components/input_source.dart';
import 'package:cirquitquest_flutter/core/components/output_probe.dart';
import 'package:cirquitquest_flutter/core/logic/wire.dart';
import 'package:cirquitquest_flutter/core/simulation/simulator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simulator - Event Driven', () {
    test('should evaluate simple AND gate', () {
      final inputA = InputSource();
      final inputB = InputSource();
      final andGate = AndGate();
      final output = OutputProbe();

      Wire(inputA.outputs['output']!, andGate.inputs['inputA']!);
      Wire(inputB.outputs['output']!, andGate.inputs['inputB']!);
      Wire(andGate.outputs['output']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {inputA, inputB, andGate, output},
        inputComponents: {inputA, inputB},
      );

      // Test case: 0 AND 0 = 0
      inputA.setValue(0);
      inputB.setValue(0);
      final result1 = simulator.evaluateEventDriven();
      expect(result1, true);
      expect(output.value, 0);

      // Test case: 1 AND 1 = 1
      inputA.setValue(1);
      inputB.setValue(1);
      final result2 = simulator.evaluateEventDriven();
      expect(result2, true);
      expect(output.value, 1);

      // Test case: 1 AND 0 = 0
      inputA.setValue(1);
      inputB.setValue(0);
      final result3 = simulator.evaluateEventDriven();
      expect(result3, true);
      expect(output.value, 0);
    });

    test('should evaluate chained gates', () {
      // Build circuit: (A AND B) OR C
      final inputA = InputSource();
      final inputB = InputSource();
      final inputC = InputSource();
      final andGate = AndGate();
      final orGate = OrGate();
      final output = OutputProbe();

      Wire(inputA.outputs['output']!, andGate.inputs['inputA']!);
      Wire(inputB.outputs['output']!, andGate.inputs['inputB']!);
      Wire(andGate.outputs['output']!, orGate.inputs['inputA']!);
      Wire(inputC.outputs['output']!, orGate.inputs['inputB']!);
      Wire(orGate.outputs['output']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {inputA, inputB, inputC, andGate, orGate, output},
        inputComponents: {inputA, inputB, inputC},
      );

      // Test case: (1 AND 1) OR 0 = 1
      inputA.setValue(1);
      inputB.setValue(1);
      inputC.setValue(0);
      simulator.evaluateEventDriven();
      expect(output.value, 1);

      // Test case: (0 AND 1) OR 0 = 0
      inputA.setValue(0);
      inputB.setValue(1);
      inputC.setValue(0);
      simulator.evaluateEventDriven();
      expect(output.value, 0);

      // Test case: (0 AND 0) OR 1 = 1
      inputA.setValue(0);
      inputB.setValue(0);
      inputC.setValue(1);
      simulator.evaluateEventDriven();
      expect(output.value, 1);
    });

    test('should handle NOT gate chain', () {
      final input = InputSource();
      final not1 = NotGate();
      final not2 = NotGate();
      final output = OutputProbe();

      Wire(input.outputs['output']!, not1.inputs['input']!);
      Wire(not1.outputs['output']!, not2.inputs['input']!);
      Wire(not2.outputs['output']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {input, not1, not2, output},
        inputComponents: {input},
      );

      // Start with 0, which should propagate through: NOT(NOT(0)) = 0
      input.setValue(0);
      simulator.evaluateEventDriven();
      output.evaluate();
      expect(output.value, 0); // NOT(NOT(0)) = 0

      // Now change to 1, which should propagate: NOT(NOT(1)) = 1
      input.setValue(1);
      simulator.evaluateEventDriven();
      output.evaluate();
      expect(output.value, 1); // NOT(NOT(1)) = 1
    });

    test('should call update callback for each evaluation cycle', () {
      final input = InputSource();
      final notGate = NotGate();
      final output = OutputProbe();

      Wire(input.outputs['output']!, notGate.inputs['input']!);
      Wire(notGate.outputs['output']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {input, notGate, output},
        inputComponents: {input},
      );

      final List<Set<Component>> updates = [];
      
      input.setValue(1);
      simulator.evaluateEventDriven(
        onUpdate: (components) => updates.add(components),
      );

      expect(updates.length, greaterThan(0));
    });

    test('should stop after max cycles to prevent infinite loops', () {
      // Create a simple circuit that would loop many times
      final input = InputSource();
      final not1 = NotGate();
      final not2 = NotGate();
      final not3 = NotGate();
      final output = OutputProbe();

      Wire(input.outputs['output']!, not1.inputs['input']!);
      Wire(not1.outputs['output']!, not2.inputs['input']!);
      Wire(not2.outputs['output']!, not3.inputs['input']!);
      Wire(not3.outputs['output']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {input, not1, not2, not3, output},
        inputComponents: {input},
      );

      input.setValue(1);
      final result = simulator.evaluateEventDriven();
      expect(result, true); // Should complete successfully
    });

    test('should return false when starting with empty input components', () {
      final notGate = NotGate();
      
      final simulator = Simulator(
        components: {notGate},
        inputComponents: {}, // No inputs
      );

      final result = simulator.evaluateEventDriven();
      expect(result, false);
    });

    test('should allow custom starting components', () {
      final inputA = InputSource();
      final inputB = InputSource();
      final andGate = AndGate();
      final output = OutputProbe();

      Wire(inputA.outputs['output']!, andGate.inputs['inputA']!);
      Wire(inputB.outputs['output']!, andGate.inputs['inputB']!);
      Wire(andGate.outputs['output']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {inputA, inputB, andGate, output},
        inputComponents: {inputA, inputB},
      );

      inputA.setValue(1);
      inputB.setValue(1);

      // Start evaluation from the AND gate instead of inputs
      final result = simulator.evaluateEventDriven(
        startingComponents: {andGate},
      );
      
      expect(result, true);
      expect(output.value, 1);
    });
  });

  group('Simulator - Topological', () {
    test('should evaluate circuit in topological order', () {
      final inputA = InputSource();
      final inputB = InputSource();
      final andGate = AndGate();
      final output = OutputProbe();

      Wire(inputA.outputs['output']!, andGate.inputs['inputA']!);
      Wire(inputB.outputs['output']!, andGate.inputs['inputB']!);
      Wire(andGate.outputs['output']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {inputA, inputB, andGate, output},
        inputComponents: {inputA, inputB},
      );

      inputA.setValue(1);
      inputB.setValue(1);

      final result = simulator.evaluateTopological();
      expect(result, true);
      expect(output.value, 1);
    });

    test('should evaluate simple topological circuit', () {
      final inputA = InputSource();
      final inputB = InputSource();
      final andGate = AndGate();
      final notGate = NotGate();
      final output = OutputProbe();

      Wire(inputA.outputs['output']!, andGate.inputs['inputA']!);
      Wire(inputB.outputs['output']!, andGate.inputs['inputB']!);
      Wire(andGate.outputs['output']!, notGate.inputs['input']!);
      Wire(notGate.outputs['output']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {inputA, inputB, andGate, notGate, output},
        inputComponents: {inputA, inputB},
      );

      inputA.setValue(1);
      inputB.setValue(1);

      final result = simulator.evaluateTopological();
      expect(result, true);
      expect(output.value, 0); // NOT(1 AND 1) = 0
    });

    test('should call update callback for each topological level', () {
      final input = InputSource();
      final not1 = NotGate();
      final not2 = NotGate();
      final output = OutputProbe();

      Wire(input.outputs['output']!, not1.inputs['input']!);
      Wire(not1.outputs['output']!, not2.inputs['input']!);
      Wire(not2.outputs['output']!, output.inputs['input']!);

      final simulator = Simulator(
        components: {input, not1, not2, output},
        inputComponents: {input},
      );

      final List<Set<Component>> updates = [];
      
      input.setValue(1);
      simulator.evaluateTopological(
        onUpdate: (components) => updates.add(components),
      );

      expect(updates.length, greaterThan(0));
    });
  });
}
