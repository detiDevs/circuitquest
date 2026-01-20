import 'package:cirquitquest_flutter/core/logic/pin.dart';
import 'package:cirquitquest_flutter/core/logic/wire.dart';
import 'package:flutter_test/flutter_test.dart';

import '../components/dummy_component.dart';

void main() {
  group('Wire', () {
    test('should connect output pin to input pin', () {
      final source = DummyComponent();
      final target = DummyComponent();
      
      final outputPin = OutputPin(source);
      final inputPin = InputPin(target);
      
      final wire = Wire(outputPin, inputPin);
      
      expect(outputPin.connections, contains(wire));
      expect(inputPin.source, wire);
    });

    test('should propagate values from output to input', () {
      final source = DummyComponent();
      final target = DummyComponent();
      
      final outputPin = OutputPin(source, bitWidth: 4);
      final inputPin = InputPin(target, bitWidth: 4);
      
      outputPin.value = 7;
      final wire = Wire(outputPin, inputPin);
      
      expect(wire.value, 7);
    });

    test('should throw error on bitwidth mismatch', () {
      final source = DummyComponent();
      final target = DummyComponent();
      
      final outputPin = OutputPin(source, bitWidth: 1);
      final inputPin = InputPin(target, bitWidth: 4);
      
      expect(
        () => Wire(outputPin, inputPin),
        throwsArgumentError,
      );
    });

    test('should allow same bitwidth connections', () {
      final source = DummyComponent();
      final target = DummyComponent();
      
      final outputPin = OutputPin(source, bitWidth: 8);
      final inputPin = InputPin(target, bitWidth: 8);
      
      expect(() => Wire(outputPin, inputPin), returnsNormally);
    });
  });
}
