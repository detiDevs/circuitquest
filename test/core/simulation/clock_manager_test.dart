import 'package:circuitquest/core/simulation/clock_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClockMode', () {
    test('fromInt returns matching mode', () {
      expect(ClockMode.fromInt(0), ClockMode.disabled);
      expect(ClockMode.fromInt(1), ClockMode.enabled);
      expect(ClockMode.fromInt(2), ClockMode.componentUpdate);
    });

    test('fromInt falls back to disabled for unknown values', () {
      expect(ClockMode.fromInt(99), ClockMode.disabled);
      expect(ClockMode.fromInt(-1), ClockMode.disabled);
    });
  });

  group('ClockManager', () {
    test('tickAndCheckClock fires after configured ticks', () {
      final manager = ClockManager(
        ticksPerClockCycle: 3,
        clockMode: ClockMode.enabled,
      );

      expect(manager.tickAndCheckClock(), false);
      expect(manager.currentTick, 1);
      expect(manager.tickAndCheckClock(), false);
      expect(manager.currentTick, 2);
      expect(manager.tickAndCheckClock(), true);
      expect(manager.currentTick, 0);
    });

    test('never fires when ticksPerClockCycle is 0', () {
      final manager = ClockManager(
        ticksPerClockCycle: 0,
        clockMode: ClockMode.componentUpdate,
      );

      for (int i = 0; i < 100; i++) {
        expect(manager.tickAndCheckClock(), false);
      }
    });

    test('updateTicksPerClockCycle resets tick counter', () {
      final manager = ClockManager(
        ticksPerClockCycle: 5,
        clockMode: ClockMode.enabled,
      );

      manager.tickAndCheckClock();
      manager.tickAndCheckClock();
      expect(manager.currentTick, 2);

      manager.updateTicksPerClockCycle(2);
      expect(manager.ticksPerClockCycle, 2);
      expect(manager.currentTick, 0);
    });

    test('updateClockMode resets tick counter and changes mode', () {
      final manager = ClockManager(
        ticksPerClockCycle: 5,
        clockMode: ClockMode.enabled,
      );

      manager.tickAndCheckClock();
      expect(manager.isEnabled, true);

      manager.updateClockMode(ClockMode.disabled);
      expect(manager.clockMode, ClockMode.disabled);
      expect(manager.currentTick, 0);
      expect(manager.isEnabled, false);

      manager.updateClockMode(ClockMode.componentUpdate);
      expect(manager.shouldUpdateManually(), true);
    });
  });
}
