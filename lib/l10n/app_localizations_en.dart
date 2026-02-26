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
  String get simulationSpeed => 'Simulation speed';

  @override
  String get simulationSpeedInstant => 'Instant';

  @override
  String get resetCircuitToInitialState => 'Reset to Initial State';

  @override
  String get circuitWasResetToInitialState => 'Circuit reset to initial state';

  @override
  String get fileOperationsTitle => 'File Operations';

  @override
  String get saveCircuit => 'Save Circuit';

  @override
  String get saveAsCustomComponent => 'Save as Custom Component';

  @override
  String get customComponentsNeedInputOutputError =>
      'Custom components need at least one input and one output.';

  @override
  String get loadCircuit => 'Load Circuit';

  @override
  String get checkSolution => 'Check solution';

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
  String get customComponentName => 'Component name';

  @override
  String get customComponentDefaultName => 'My Custom Component';

  @override
  String get customComponentInputKeysLabel => 'Input keys';

  @override
  String get customComponentOutputKeysLabel => 'Output keys';

  @override
  String customComponentInputLabel(int index, int bitWidth) {
    return 'Input $index (bitwidth: $bitWidth)';
  }

  @override
  String customComponentOutputLabel(int index, int bitWidth) {
    return 'Output $index (bitwidth: $bitWidth)';
  }

  @override
  String get customComponentSelectImage => 'Select image';

  @override
  String get customComponentNameCannotBeEmptyError =>
      'Component name cannot be empty.';

  @override
  String get customComponentKeysCannotBeEmptyError =>
      'Input/output keys cannot be empty.';

  @override
  String get customComponentBuildDataError =>
      'Unable to build custom component data.';

  @override
  String get customComponentSavingError => 'Failed to save custom component.';

  @override
  String get customComponentSaved => 'Custom component saved.';

  @override
  String get deleteCustomComponent => 'Delete Custom Component';

  @override
  String get circuitDefaultName => 'My Circuit';

  @override
  String get circuitDefaultDescription => 'Circuit created in sandbox mode';

  @override
  String get circuitNameLabel => 'Circuit Name';

  @override
  String circuitSavedTo(String path) {
    return 'Circuit saved to $path';
  }

  @override
  String circuitSaveError(String error) {
    return 'Error saving circuit: $error';
  }

  @override
  String get loadCircuitConfirmMessage =>
      'Loading a circuit will clear the current circuit. Continue?';

  @override
  String get loadCircuitAction => 'Load';

  @override
  String get circuitLoadedSuccess => 'Circuit loaded successfully';

  @override
  String get circuitLoadedError => 'Error loading circuit';

  @override
  String circuitLoadError(String error) {
    return 'Error loading circuit: $error';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get util => '';

  @override
  String get retry => 'Retry';

  @override
  String get selected => 'Selected';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get ok => 'OK';

  @override
  String get levelInformationTooltip => 'Level Information';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get description => 'Description';

  @override
  String get cantChangeBitwidth =>
      'Cannot change bitwidth if input has active wires';

  @override
  String get enterComponentLabel => 'Enter a display name';

  @override
  String areYouSureYouWantToDeleteX(String itemToDelete) {
    return 'Are you sure you want to delete $itemToDelete?';
  }

  @override
  String successfullyDeletedX(String itemToDelete) {
    return '$itemToDelete deleted successfully';
  }

  @override
  String failedToDeleteX(String itemToDelete) {
    return 'Failed to delete $itemToDelete';
  }
}
