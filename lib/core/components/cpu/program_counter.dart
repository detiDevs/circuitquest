import 'package:circuitquest/core/components/base/sequentialComponent.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Program Counter component for MIPS processor
class ProgramCounter extends SequentialComponent {
  late InputPin _nextPcInput;
  late OutputPin _pcOutput;
  int _currentPC = 0;
  int _nextValue = 0;
  bool _hasInitialized = false;
  bool _clockUpdated = false; // Flag für Clock-Updates

  ProgramCounter() {
    _nextPcInput = InputPin(this, bitWidth: 32);
    _pcOutput = OutputPin(this, bitWidth: 32);

    inputs['input'] = _nextPcInput;
    outputs['outValue'] = _pcOutput;
    // WICHTIG: Output zeigt immer den aktuellen PC-Wert (_currentPC)
    outputs['outValue']!.value = _currentPC; // Zeigt 0 beim Start
  }

  @override
  bool evaluate() {
    _nextPcInput.updateFromSource();
    final nextValue = _nextPcInput.value;
    _nextValue = nextValue;

    // WICHTIG: PC propagiert NUR bei Clock-Flanken, nicht bei jeder Evaluation!
    // Der Output zeigt immer den aktuellen PC-Wert, aber propagiert nicht automatisch
    // Das verhindert, dass der PC zu schnell läuft in Eintaktprozessoren
    _pcOutput.value = _currentPC;

    // Propagieren bei: 1) Erstem Mal, 2) Nach Clock-Update
    if (!_hasInitialized) {
      _hasInitialized = true;
      return true;
    }
    
    if (_clockUpdated) {
      _clockUpdated = false; // Reset flag
      return true; // Propagiere nach Clock-Update
    }

    // Sonst keine automatische Propagation
    return false;
  }

  @override
  void applyNewState(){
    if (_currentPC != _nextValue) {
      _currentPC = _nextValue;
      // KRITISCH: Output-Pin muss auch aktualisiert werden!
      _pcOutput.value = _currentPC;
      // WICHTIG: Flag setzen, damit nächste evaluate() propagiert
      _clockUpdated = true;
    }
  }
}
