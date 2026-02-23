import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'CircuitQuest'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Master Digital Logic and Processor Design'**
  String get appDescription;

  /// Title for sandbox mode screen
  ///
  /// In en, this message translates to:
  /// **'Sandbox Mode'**
  String get sandboxModeTitle;

  /// No description provided for @sandboxModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Design circuits freely\nwithout constraints'**
  String get sandboxModeDescription;

  /// No description provided for @levelModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Mode'**
  String get levelModeTitle;

  /// No description provided for @levelModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete circuit challenges and progress through levels'**
  String get levelModeDescription;

  /// No description provided for @failedToLoadLevels.
  ///
  /// In en, this message translates to:
  /// **'Failed to load levels'**
  String get failedToLoadLevels;

  /// No description provided for @failedToLoadLevel.
  ///
  /// In en, this message translates to:
  /// **'Failed to load level'**
  String get failedToLoadLevel;

  /// No description provided for @selectALevel.
  ///
  /// In en, this message translates to:
  /// **'Select a level'**
  String get selectALevel;

  /// No description provided for @noLevelsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No levels available'**
  String get noLevelsAvailable;

  /// No description provided for @availableComponents.
  ///
  /// In en, this message translates to:
  /// **'Available components'**
  String get availableComponents;

  /// No description provided for @levelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get levelDescription;

  /// No description provided for @levelObjectives.
  ///
  /// In en, this message translates to:
  /// **'Objectives'**
  String get levelObjectives;

  /// No description provided for @levelHints.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get levelHints;

  /// Control panel title
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get controlsTitle;

  /// Button to evaluate the circuit once
  ///
  /// In en, this message translates to:
  /// **'Evaluate Circuit'**
  String get evaluateCircuit;

  /// Snackbar message after circuit evaluation
  ///
  /// In en, this message translates to:
  /// **'Circuit evaluated'**
  String get circuitEvaluated;

  /// Button to start continuous simulation
  ///
  /// In en, this message translates to:
  /// **'Start Simulation'**
  String get startSimulation;

  /// Button to stop continuous simulation
  ///
  /// In en, this message translates to:
  /// **'Stop Simulation'**
  String get stopSimulation;

  /// No description provided for @simulationSpeed.
  ///
  /// In en, this message translates to:
  /// **'Simulation speed'**
  String get simulationSpeed;

  /// No description provided for @simulationSpeedInstant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get simulationSpeedInstant;

  /// No description provided for @resetCircuitToInitialState.
  ///
  /// In en, this message translates to:
  /// **'Reset to Initial State'**
  String get resetCircuitToInitialState;

  /// No description provided for @circuitWasResetToInitialState.
  ///
  /// In en, this message translates to:
  /// **'Circuit reset to initial state'**
  String get circuitWasResetToInitialState;

  /// No description provided for @fileOperationsTitle.
  ///
  /// In en, this message translates to:
  /// **'File Operations'**
  String get fileOperationsTitle;

  /// No description provided for @saveCircuit.
  ///
  /// In en, this message translates to:
  /// **'Save Circuit'**
  String get saveCircuit;

  /// No description provided for @saveAsCustomComponent.
  ///
  /// In en, this message translates to:
  /// **'Save as Custom Component'**
  String get saveAsCustomComponent;

  /// No description provided for @customComponentsNeedInputOutputError.
  ///
  /// In en, this message translates to:
  /// **'Custom components need at least one input and one output.'**
  String get customComponentsNeedInputOutputError;

  /// No description provided for @loadCircuit.
  ///
  /// In en, this message translates to:
  /// **'Load Circuit'**
  String get loadCircuit;

  /// No description provided for @checkSolution.
  ///
  /// In en, this message translates to:
  /// **'Check solution'**
  String get checkSolution;

  /// Button to clear all components from canvas
  ///
  /// In en, this message translates to:
  /// **'Clear Circuit'**
  String get clearCircuit;

  /// Title for clear circuit confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Clear Circuit'**
  String get clearCircuitConfirmTitle;

  /// Message for clear circuit confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the entire circuit? This action cannot be undone.'**
  String get clearCircuitConfirmMessage;

  /// Snackbar message after circuit is cleared
  ///
  /// In en, this message translates to:
  /// **'Circuit cleared'**
  String get circuitCleared;

  /// Clear button in confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Circuit information section title
  ///
  /// In en, this message translates to:
  /// **'Circuit Info'**
  String get circuitInfoTitle;

  /// Label for number of components
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get componentsLabel;

  /// Label for number of wire connections
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connectionsLabel;

  /// Label for simulation status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// Status when simulation is running
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get statusRunning;

  /// Status when simulation is stopped
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get statusStopped;

  /// Instructions section title
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsTitle;

  /// Instruction for dragging components
  ///
  /// In en, this message translates to:
  /// **'Drag components from the palette to the canvas'**
  String get instructionDragComponents;

  /// Instruction for moving components
  ///
  /// In en, this message translates to:
  /// **'Move components by dragging them on the canvas'**
  String get instructionMoveComponents;

  /// Instruction for starting wire connections
  ///
  /// In en, this message translates to:
  /// **'Tap output pins to start drawing wires'**
  String get instructionStartWires;

  /// Instruction for completing wire connections
  ///
  /// In en, this message translates to:
  /// **'Tap input pins to complete wire connections'**
  String get instructionCompleteWires;

  /// Instruction for deleting components
  ///
  /// In en, this message translates to:
  /// **'Long-press components to delete them'**
  String get instructionDeleteComponents;

  /// Instruction for circuit evaluation
  ///
  /// In en, this message translates to:
  /// **'Evaluate to run the circuit once'**
  String get instructionEvaluate;

  /// Information about pin color coding
  ///
  /// In en, this message translates to:
  /// **'Pin colors: Green = HIGH (1), Red = LOW (0)'**
  String get pinColorsInfo;

  /// Component palette title
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get componentPaletteTitle;

  /// Snackbar message when component is selected
  ///
  /// In en, this message translates to:
  /// **'{componentName} selected'**
  String componentSelected(String componentName);

  /// No description provided for @andGate.
  ///
  /// In en, this message translates to:
  /// **'AND Gate'**
  String get andGate;

  /// No description provided for @orGate.
  ///
  /// In en, this message translates to:
  /// **'OR Gate'**
  String get orGate;

  /// No description provided for @notGate.
  ///
  /// In en, this message translates to:
  /// **'NOT Gate'**
  String get notGate;

  /// No description provided for @nandGate.
  ///
  /// In en, this message translates to:
  /// **'NAND Gate'**
  String get nandGate;

  /// No description provided for @norGate.
  ///
  /// In en, this message translates to:
  /// **'NOR Gate'**
  String get norGate;

  /// No description provided for @xorGate.
  ///
  /// In en, this message translates to:
  /// **'XOR Gate'**
  String get xorGate;

  /// No description provided for @clock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get clock;

  /// No description provided for @dLatch.
  ///
  /// In en, this message translates to:
  /// **'D-Latch'**
  String get dLatch;

  /// No description provided for @dFlipFlop.
  ///
  /// In en, this message translates to:
  /// **'D-Flip-Flop'**
  String get dFlipFlop;

  /// No description provided for @inputSource.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get inputSource;

  /// No description provided for @outputProbe.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get outputProbe;

  /// Title for component context menu
  ///
  /// In en, this message translates to:
  /// **'{componentType} Component'**
  String componentMenuTitle(String componentType);

  /// Prompt in component context menu
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get componentMenuPrompt;

  /// Tooltip for bitwidth toggle button
  ///
  /// In en, this message translates to:
  /// **'Toggle bitwidth'**
  String get toggleBitwidth;

  /// Bitwidth display label
  ///
  /// In en, this message translates to:
  /// **'{bitWidth}-bit'**
  String bitwidthLabel(int bitWidth);

  /// Output component bitwidth label
  ///
  /// In en, this message translates to:
  /// **'{bitWidth}-bit output'**
  String outputLabel(int bitWidth);

  /// Value range display
  ///
  /// In en, this message translates to:
  /// **'{min} .. {max}'**
  String rangeLabel(String min, String max);

  /// No description provided for @customComponentName.
  ///
  /// In en, this message translates to:
  /// **'Component name'**
  String get customComponentName;

  /// Default name for a new custom component
  ///
  /// In en, this message translates to:
  /// **'My Custom Component'**
  String get customComponentDefaultName;

  /// Section title for custom component input keys
  ///
  /// In en, this message translates to:
  /// **'Input keys'**
  String get customComponentInputKeysLabel;

  /// Section title for custom component output keys
  ///
  /// In en, this message translates to:
  /// **'Output keys'**
  String get customComponentOutputKeysLabel;

  /// Label for custom component input name field
  ///
  /// In en, this message translates to:
  /// **'Input {index} (bitwidth: {bitWidth})'**
  String customComponentInputLabel(int index, int bitWidth);

  /// Label for custom component output name field
  ///
  /// In en, this message translates to:
  /// **'Output {index} (bitwidth: {bitWidth})'**
  String customComponentOutputLabel(int index, int bitWidth);

  /// No description provided for @customComponentSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get customComponentSelectImage;

  /// No description provided for @customComponentNameCannotBeEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Component name cannot be empty.'**
  String get customComponentNameCannotBeEmptyError;

  /// No description provided for @customComponentKeysCannotBeEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Input/output keys cannot be empty.'**
  String get customComponentKeysCannotBeEmptyError;

  /// No description provided for @customComponentBuildDataError.
  ///
  /// In en, this message translates to:
  /// **'Unable to build custom component data.'**
  String get customComponentBuildDataError;

  /// No description provided for @customComponentSavingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save custom component.'**
  String get customComponentSavingError;

  /// No description provided for @customComponentSaved.
  ///
  /// In en, this message translates to:
  /// **'Custom component saved.'**
  String get customComponentSaved;

  /// Default name for a new circuit
  ///
  /// In en, this message translates to:
  /// **'My Circuit'**
  String get circuitDefaultName;

  /// Default description for a new circuit
  ///
  /// In en, this message translates to:
  /// **'Circuit created in sandbox mode'**
  String get circuitDefaultDescription;

  /// Label for circuit name text field
  ///
  /// In en, this message translates to:
  /// **'Circuit Name'**
  String get circuitNameLabel;

  /// Snackbar message after saving a circuit
  ///
  /// In en, this message translates to:
  /// **'Circuit saved to {path}'**
  String circuitSavedTo(String path);

  /// Snackbar message when saving a circuit fails
  ///
  /// In en, this message translates to:
  /// **'Error saving circuit: {error}'**
  String circuitSaveError(String error);

  /// Confirmation message before loading a circuit
  ///
  /// In en, this message translates to:
  /// **'Loading a circuit will clear the current circuit. Continue?'**
  String get loadCircuitConfirmMessage;

  /// Button label to confirm loading a circuit
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get loadCircuitAction;

  /// Snackbar message after loading a circuit
  ///
  /// In en, this message translates to:
  /// **'Circuit loaded successfully'**
  String get circuitLoadedSuccess;

  /// Snackbar message when circuit loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading circuit'**
  String get circuitLoadedError;

  /// Snackbar message when circuit loading throws an error
  ///
  /// In en, this message translates to:
  /// **'Error loading circuit: {error}'**
  String circuitLoadError(String error);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @util.
  ///
  /// In en, this message translates to:
  /// **''**
  String get util;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Label to show details or hints
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// Label to hide details or hints
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Tooltip for level info button
  ///
  /// In en, this message translates to:
  /// **'Level Information'**
  String get levelInformationTooltip;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @cantChangeBitwidth.
  ///
  /// In en, this message translates to:
  /// **'Cannot change bitwidth if input has active wires'**
  String get cantChangeBitwidth;

  /// No description provided for @enterComponentLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter a display name'**
  String get enterComponentLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
