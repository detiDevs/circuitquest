// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CircuitQuest';

  @override
  String get appDescription => 'Master Digital Logic and Processor Design';

  @override
  String get sandboxModeTitle => 'Sandbox Mode';

  @override
  String get sandboxModeDescription =>
      'Design circuits freely\nwithout constraints';

  @override
  String get levelModeTitle => 'Level Mode';

  @override
  String get levelModeDescription =>
      'Complete circuit challenges and progress through levels';

  @override
  String get failedToLoadLevels => 'Failed to load levels';

  @override
  String get failedToLoadLevel => 'Failed to load level';

  @override
  String get selectALevel => 'Select a level';

  @override
  String get noLevelsAvailable => 'No levels available';

  @override
  String get recommendedLevel => 'Recommended level';

  @override
  String get availableComponents => 'Available components';

  @override
  String get levelDescription => 'Description';

  @override
  String get levelObjectives => 'Objectives';

  @override
  String get levelHints => 'Hints';

  @override
  String get controlsTitle => 'Controls';

  @override
  String get evaluateCircuit => 'Evaluate Circuit';

  @override
  String get circuitEvaluated => 'Circuit evaluated';

  @override
  String get startSimulation => 'Start Simulation';

  @override
  String get stopSimulation => 'Stop Simulation';

  @override
  String get clearCircuit => 'Clear Circuit';

  @override
  String get clearCircuitConfirmTitle => 'Clear Circuit';

  @override
  String get clearCircuitConfirmMessage =>
      'Are you sure you want to clear the entire circuit? This action cannot be undone.';

  @override
  String get circuitCleared => 'Circuit cleared';

  @override
  String get clear => 'Clear';

  @override
  String get circuitInfoTitle => 'Circuit Info';

  @override
  String get componentsLabel => 'Components';

  @override
  String get connectionsLabel => 'Connections';

  @override
  String get statusLabel => 'Status';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusStopped => 'Stopped';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get instructionDragComponents =>
      'Drag components from the palette to the canvas';

  @override
  String get instructionMoveComponents =>
      'Move components by dragging them on the canvas';

  @override
  String get instructionStartWires => 'Tap output pins to start drawing wires';

  @override
  String get instructionCompleteWires =>
      'Tap input pins to complete wire connections';

  @override
  String get instructionDeleteComponents =>
      'Long-press components to delete them';

  @override
  String get instructionEvaluate => 'Evaluate to run the circuit once';

  @override
  String get pinColorsInfo => 'Pin colors: Green = HIGH (1), Red = LOW (0)';

  @override
  String get componentPaletteTitle => 'Components';

  @override
  String componentSelected(String componentName) {
    return '$componentName selected';
  }

  @override
  String get andGate => 'AND Gate';

  @override
  String get orGate => 'OR Gate';

  @override
  String get notGate => 'NOT Gate';

  @override
  String get nandGate => 'NAND Gate';

  @override
  String get norGate => 'NOR Gate';

  @override
  String get xorGate => 'XOR Gate';

  @override
  String get clock => 'Clock';

  @override
  String get dLatch => 'D-Latch';

  @override
  String get dFlipFlop => 'D-Flip-Flop';

  @override
  String get inputSource => 'Input';

  @override
  String get outputProbe => 'Output';

  @override
  String componentMenuTitle(String componentType) {
    return '$componentType Component';
  }

  @override
  String get componentMenuPrompt => 'What would you like to do?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get toggleBitwidth => 'Toggle bitwidth';

  @override
  String bitwidthLabel(int bitWidth) {
    return '$bitWidth-bit';
  }

  @override
  String outputLabel(int bitWidth) {
    return '$bitWidth-bit output';
  }

  @override
  String rangeLabel(String min, String max) {
    return '$min .. $max';
  }

  @override
  String get util => '';

  @override
  String get retry => 'Retry';

  @override
  String get selected => 'Selected';
}
