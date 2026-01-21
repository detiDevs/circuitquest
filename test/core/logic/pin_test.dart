import 'package:circuitquest/core/logic/pin.dart';
import 'package:circuitquest/core/logic/wire.dart';
import 'package:flutter_test/flutter_test.dart';

import '../components/dummy_component.dart';

void main() {
  group('Pin', () {
    test('should mask values correctly for single bit', () {
      final component = DummyComponent();
      final pin = InputPin(component, bitWidth: 1);

      pin.value = 7; // 111 in binary
      expect(pin.value, 1); // Should be masked to 1
    });

    test('should mask values correctly for 4 bits', () {
      final component = DummyComponent();
      final pin = InputPin(component, bitWidth: 4);

      pin.value = 255; // 11111111 in binary
      expect(pin.value, 15); // Should be masked to 1111 (15)
    });

    test('should handle zero correctly', () {
      final component = DummyComponent();
      final pin = InputPin(component, bitWidth: 8);

      pin.value = 0;
      expect(pin.value, 0);
    });

    test('should calculate mask correctly', () {
      final component = DummyComponent();
      
      final pin1 = InputPin(component, bitWidth: 1);
      expect(pin1.mask, 1); // 0b1
      
      final pin4 = InputPin(component, bitWidth: 4);
      expect(pin4.mask, 15); // 0b1111
      
      final pin8 = InputPin(component, bitWidth: 8);
      expect(pin8.mask, 255); // 0b11111111
    });
  });

  group('InputPin', () {
    test('should start with no source', () {
      final component = DummyComponent();
      final pin = InputPin(component);

      expect(pin.hasSource, false);
      expect(pin.source, isNull);
    });

    test('should update value from source when wire is connected', () {
      final source = DummyComponent();
      final target = DummyComponent();
      
      final outputPin = OutputPin(source, bitWidth: 4);
      final inputPin = InputPin(target, bitWidth: 4);
      
      outputPin.value = 12;
      Wire(outputPin, inputPin);
      
      inputPin.updateFromSource();
      expect(inputPin.value, 12);
    });

    test('should not update if no source', () {
      final component = DummyComponent();
      final pin = InputPin(component);
      
      pin.value = 5;
      pin.updateFromSource();
      
      // Value is masked to bitWidth (default 1), so 5 becomes 1
      expect(pin.value, 1);
    });
  });

  group('OutputPin', () {
    test('should start with empty connections', () {
      final component = DummyComponent();
      final pin = OutputPin(component);

      expect(pin.connections, isEmpty);
    });

    test('should track connections when wires are created', () {
      final source = DummyComponent();
      final target1 = DummyComponent();
      final target2 = DummyComponent();
      
      final outputPin = OutputPin(source);
      final inputPin1 = InputPin(target1);
      final inputPin2 = InputPin(target2);
      
      Wire(outputPin, inputPin1);
      Wire(outputPin, inputPin2);
      
      expect(outputPin.connections.length, 2);
    });
  });
}
