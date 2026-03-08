import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/components/base/sequentialComponent.dart';
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

class Clockmanager {
  int _currentTick = 0;
  late final int ticksPerClockCycle;
  final ClockMode clockMode;

  Clockmanager({
    this.ticksPerClockCycle = 0,
    this.clockMode = ClockMode.disabled,
  });

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
