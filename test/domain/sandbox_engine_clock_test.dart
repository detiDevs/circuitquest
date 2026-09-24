import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/components/custom_component_data.dart';
import 'package:circuitquest/core/components/input_source.dart';
import 'package:circuitquest/core/components/output_probe.dart';
import 'package:circuitquest/core/components/sequential/d_flip_flop.dart';
import 'package:circuitquest/core/simulation/clock_manager.dart';
import 'package:circuitquest/data/repositories/custom_component_repository.dart';
import 'package:circuitquest/domain/use_cases/sandbox_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCustomComponentRepository implements CustomComponentRepository {
  @override
  List<CustomComponentEntry> get components => const [];

  @override
  CustomComponentData? getByName(String name) => null;

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<bool> saveCustomComponent(
    CustomComponentData data, {
    String? spriteSourcePath,
  }) async => true;

  @override
  Future<bool> deleteCustomComponentByName(String name) async => true;
}

void main() {
  group('SandboxEngine clock handling', () {
    test('engine always has a clock manager (disabled by default)', () {
      final engine = SandboxEngine(_FakeCustomComponentRepository());

      expect(engine.clockManager.isEnabled, false);
      expect(engine.clockManager.clockMode, ClockMode.disabled);
    });

    test('manual clock update commits staged state and propagates it', () {
      final engine = SandboxEngine(_FakeCustomComponentRepository());
      final input = InputSource(value: 1);
      final flipflop = DFlipflop();
      final probe = OutputProbe();

      engine.placeComponent('InputSource', const Offset(0, 0), input);
      engine.placeComponent('DFlipflop', const Offset(80, 0), flipflop);
      engine.placeComponent('OutputProbe', const Offset(160, 0), probe);

      engine.addConnection('0', 'outValue', '1', 'D');
      engine.addConnection('1', 'Q', '2', 'input');

      // Input is 1, but with the clock disabled no state is committed.
      expect(flipflop.outputs['Q']!.value, 0);
      expect(probe.value, 0);

      // A manual trigger with the clock disabled is a no-op.
      engine.triggerManualClockUpdate();
      expect(flipflop.outputs['Q']!.value, 0);

      // Enable the clock and trigger one manual update.
      engine.setClockMode(ClockMode.componentUpdate);
      engine.triggerManualClockUpdate();

      expect(flipflop.outputs['Q']!.value, 1);
      expect(probe.value, 1);
    });

    test('manual clock update works with automatic mode as well', () {
      final engine = SandboxEngine(_FakeCustomComponentRepository());
      final input = InputSource(value: 1);
      final flipflop = DFlipflop();
      final probe = OutputProbe();

      engine.placeComponent('InputSource', const Offset(0, 0), input);
      engine.placeComponent('DFlipflop', const Offset(80, 0), flipflop);
      engine.placeComponent('OutputProbe', const Offset(160, 0), probe);

      engine.addConnection('0', 'outValue', '1', 'D');
      engine.addConnection('1', 'Q', '2', 'input');

      engine.setClockMode(ClockMode.enabled);
      engine.triggerManualClockUpdate();

      expect(flipflop.outputs['Q']!.value, 1);
      expect(probe.value, 1);
    });

    test('clock config is persisted in serialized circuits', () {
      final engine = SandboxEngine(_FakeCustomComponentRepository());
      engine.setClockMode(ClockMode.enabled);
      engine.setTicksPerClockCycle(5);

      final json = engine.serializeCircuit(name: 'test');

      final restored = SandboxEngine(_FakeCustomComponentRepository());
      final success = restored.loadCircuitFromJson(json);

      expect(success, true);
      expect(restored.clockManager.clockMode, ClockMode.enabled);
      expect(restored.clockManager.ticksPerClockCycle, 5);
    });

    test('loading a circuit without clock config resets to disabled', () {
      final engine = SandboxEngine(_FakeCustomComponentRepository());
      engine.setClockMode(ClockMode.componentUpdate);
      engine.setTicksPerClockCycle(4);

      final circuitJson =
          '{"name":"old","description":"old save","components":[],"connections":[]}';
      final success = engine.loadCircuitFromJson(circuitJson);

      expect(success, true);
      expect(engine.clockManager.clockMode, ClockMode.disabled);
      expect(engine.clockManager.ticksPerClockCycle, 8);
    });

    test('setClockMode and setTicksPerClockCycle update the manager', () {
      final engine = SandboxEngine(_FakeCustomComponentRepository());

      engine.setClockMode(ClockMode.enabled);
      expect(engine.clockManager.clockMode, ClockMode.enabled);

      engine.setTicksPerClockCycle(12);
      expect(engine.clockManager.ticksPerClockCycle, 12);
    });
  });
}
