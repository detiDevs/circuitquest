import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/components/cpu/instruction_memory.dart';
import 'package:circuitquest/core/components/cpu/program_counter.dart';

/// Clock configuration modes
enum ClockMode {
  disabled(0), // Clock disabled
  enabled(1), // Clock enabled for processor simulation
  componentUpdate(2); // Sequential components update on input evaluation

  const ClockMode(this.value);
  final int value;

  static ClockMode fromInt(int value) {
    return ClockMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => ClockMode.disabled,
    );
  }
}

class ClockManager {
  int _currentTick = 0;
  int ticksPerClockCycle;
  ClockMode clockMode;

  ClockManager({
    this.ticksPerClockCycle = 0,
    this.clockMode = ClockMode.disabled,
  });

  /// Sets the number of ticks between clock highs.
  /// Values below 1 mean the clock never fires automatically.
  void updateTicksPerClockCycle(int ticks) {
    ticksPerClockCycle = ticks;
    _currentTick = 0;
  }

  /// Sets the clock mode and resets the tick counter.
  void updateClockMode(ClockMode mode) {
    clockMode = mode;
    _currentTick = 0;
  }

  /// Returns the current tick within the clock cycle
  int get currentTick => _currentTick;

  bool tickAndCheckClock() {
    _currentTick++;
    if (ticksPerClockCycle > 0 && _currentTick >= ticksPerClockCycle) {
      _currentTick = 0;
      // trigger components with return
      return true;
    }
    return false;
  }

  /// Returns the current clock mode
  ClockMode get mode => clockMode;

  /// Returns true if clock is enabled in any mode
  bool get isEnabled => clockMode != ClockMode.disabled;

  bool shouldUpdateManually() {
    return clockMode == ClockMode.componentUpdate;
  }

  bool shouldContinue(Set<Component> components) {
    InstructionMemory? instructionMemory = null;
    ProgramCounter? programCounter = null;
    for (Component comp in components) {
      if (comp is InstructionMemory) {
        instructionMemory = comp;
      }
      if (comp is ProgramCounter) {
        programCounter = comp;
      }
    }
    if (instructionMemory != null &&
        programCounter != null &&
        instructionMemory.getInstructionListLenght() >
            programCounter.currentPC) {
              return true;
            }
    return false;
  }
}
