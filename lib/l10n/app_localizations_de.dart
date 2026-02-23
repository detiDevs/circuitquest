// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'CircuitQuest';

  @override
  String get appDescription =>
      'Meistere Rechnerarchitektur und Prozessorentwicklung';

  @override
  String get sandboxModeTitle => 'Sandbox-Modus';

  @override
  String get sandboxModeDescription =>
      'Entwerfe eigene Schaltungen ohne Einschränkungen';

  @override
  String get levelModeTitle => 'Level Modus';

  @override
  String get levelModeDescription => 'Lerne spielerisch anhand von Levels';

  @override
  String get failedToLoadLevels => 'Fehler beim Laden der Level';

  @override
  String get failedToLoadLevel => 'Fehler beim laden des Levels';

  @override
  String get selectALevel => 'Wähle ein level';

  @override
  String get noLevelsAvailable => 'Keine Level verfügbar';

  @override
  String get availableComponents => 'Verfügbare Komponenten';

  @override
  String get levelDescription => 'Beschreibung';

  @override
  String get levelObjectives => 'Ziele';

  @override
  String get levelHints => 'Tipps';

  @override
  String get controlsTitle => 'Steuerung';

  @override
  String get evaluateCircuit => 'Schaltkreis auswerten';

  @override
  String get circuitEvaluated => 'Schaltkreis ausgewertet';

  @override
  String get startSimulation => 'Simulation starten';

  @override
  String get stopSimulation => 'Simulation stoppen';

  @override
  String get simulationSpeed => 'Geschwindigkeit';

  @override
  String get simulationSpeedInstant => 'Ohne Verzögerung';

  @override
  String get resetCircuitToInitialState => 'Auf Ausgangszustand zurücksetzen';

  @override
  String get circuitWasResetToInitialState =>
      'Auf Ausgangszustand zurückgesetzt';

  @override
  String get fileOperationsTitle => 'Dateioptionen';

  @override
  String get saveCircuit => 'Schaltkreis speichern';

  @override
  String get saveAsCustomComponent => 'Als eigene Komponente speichern';

  @override
  String get customComponentsNeedInputOutputError =>
      'Eigene Komponenten brauchen mindestens einen Input und einen Output.';

  @override
  String get loadCircuit => 'Schaltkreis laden';

  @override
  String get checkSolution => 'Lösung überprüfen';

  @override
  String get clearCircuit => 'Schaltkreis löschen';

  @override
  String get clearCircuitConfirmTitle => 'Schaltkreis löschen';

  @override
  String get clearCircuitConfirmMessage =>
      'Möchten Sie wirklich den gesamten Schaltkreis löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get circuitCleared => 'Schaltkreis gelöscht';

  @override
  String get clear => 'Löschen';

  @override
  String get circuitInfoTitle => 'Schaltkreis-Info';

  @override
  String get componentsLabel => 'Komponenten';

  @override
  String get connectionsLabel => 'Verbindungen';

  @override
  String get statusLabel => 'Status';

  @override
  String get statusRunning => 'Läuft';

  @override
  String get statusStopped => 'Gestoppt';

  @override
  String get instructionsTitle => 'Anleitung';

  @override
  String get instructionDragComponents =>
      'Ziehen Sie Komponenten aus der Palette auf die Arbeitsfläche';

  @override
  String get instructionMoveComponents =>
      'Verschieben Sie Komponenten durch Ziehen auf der Arbeitsfläche';

  @override
  String get instructionStartWires =>
      'Tippen Sie auf Ausgangspins, um Drähte zu zeichnen';

  @override
  String get instructionCompleteWires =>
      'Tippen Sie auf Eingangspins, um Drahtverbindungen abzuschließen';

  @override
  String get instructionDeleteComponents =>
      'Drücken Sie lange auf Komponenten, um sie zu löschen';

  @override
  String get instructionEvaluate =>
      'Auswerten, um den Schaltkreis einmal auszuführen';

  @override
  String get pinColorsInfo => 'Pin-Farben: Grün = HIGH (1), Rot = LOW (0)';

  @override
  String get componentPaletteTitle => 'Komponenten';

  @override
  String componentSelected(String componentName) {
    return '$componentName ausgewählt';
  }

  @override
  String get andGate => 'AND-Gatter';

  @override
  String get orGate => 'OR-Gatter';

  @override
  String get notGate => 'NOT-Gatter';

  @override
  String get nandGate => 'NAND-Gatter';

  @override
  String get norGate => 'NOR-Gatter';

  @override
  String get xorGate => 'XOR-Gatter';

  @override
  String get clock => 'Takt';

  @override
  String get dLatch => 'D-Latch';

  @override
  String get dFlipFlop => 'D-Flipflop';

  @override
  String get inputSource => 'Eingang';

  @override
  String get outputProbe => 'Ausgang';

  @override
  String componentMenuTitle(String componentType) {
    return '$componentType-Komponente';
  }

  @override
  String get componentMenuPrompt => 'Was möchten Sie tun?';

  @override
  String get toggleBitwidth => 'Bitbreite umschalten';

  @override
  String bitwidthLabel(int bitWidth) {
    return '$bitWidth-Bit';
  }

  @override
  String outputLabel(int bitWidth) {
    return '$bitWidth-Bit Ausgang';
  }

  @override
  String rangeLabel(String min, String max) {
    return '$min .. $max';
  }

  @override
  String get customComponentName => 'Komponentenname';

  @override
  String get customComponentDefaultName => 'Meine eigene Komponente';

  @override
  String get customComponentInputKeysLabel => 'Eingangsschlüssel';

  @override
  String get customComponentOutputKeysLabel => 'Ausgangsschlüssel';

  @override
  String customComponentInputLabel(int index, int bitWidth) {
    return 'Eingang $index (Bitbreite: $bitWidth)';
  }

  @override
  String customComponentOutputLabel(int index, int bitWidth) {
    return 'Ausgang $index (Bitbreite: $bitWidth)';
  }

  @override
  String get customComponentSelectImage => 'Bild wählen';

  @override
  String get customComponentNameCannotBeEmptyError =>
      'Komponentenname darf nicht leer sein';

  @override
  String get customComponentKeysCannotBeEmptyError =>
      'Input/output keys dürfen nicht leer sein';

  @override
  String get customComponentBuildDataError =>
      'Fehler beim Erstellen der Komponentendaten';

  @override
  String get customComponentSavingError =>
      'Fehler beim Speichern der Komponente';

  @override
  String get customComponentSaved => 'Komponente gespeichert';

  @override
  String get circuitDefaultName => 'Mein Schaltkreis';

  @override
  String get circuitDefaultDescription =>
      'Schaltkreis im Sandbox-Modus erstellt';

  @override
  String get circuitNameLabel => 'Schaltkreisname';

  @override
  String circuitSavedTo(String path) {
    return 'Schaltkreis gespeichert unter $path';
  }

  @override
  String circuitSaveError(String error) {
    return 'Fehler beim Speichern des Schaltkreises: $error';
  }

  @override
  String get loadCircuitConfirmMessage =>
      'Beim Laden wird der aktuelle Schaltkreis gelöscht. Fortfahren?';

  @override
  String get loadCircuitAction => 'Laden';

  @override
  String get circuitLoadedSuccess => 'Schaltkreis erfolgreich geladen';

  @override
  String get circuitLoadedError => 'Fehler beim Laden des Schaltkreises';

  @override
  String circuitLoadError(String error) {
    return 'Fehler beim Laden des Schaltkreises: $error';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get systemDefault => 'Systemeinstellung';

  @override
  String get util => '';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get selected => 'Ausgewählt';

  @override
  String get show => 'Anzeigen';

  @override
  String get hide => 'Ausblenden';

  @override
  String get ok => 'OK';

  @override
  String get levelInformationTooltip => 'Level-Informationen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get description => 'Beschreibung';

  @override
  String get cantChangeBitwidth =>
      'Bitbreite kann nicht umgestellt werden, solange es aktive Verbindungen gibt';

  @override
  String get enterComponentLabel => 'Anzeigenamen eingeben';
}
