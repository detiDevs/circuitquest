import 'package:circuitquest/core/components/base/sequentialComponent.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// D Latch - stores a value when clock is high
/// When clock is high (1), output Q follows input D
/// When clock is low (0), output Q holds its previous value
class DFlipflop extends SequentialComponent {
  int _storedValue = 0;
  int _newState = 0;

  DFlipflop({int bitWidth = 1}) {
    inputs['D'] = InputPin(this, bitWidth: bitWidth);
    outputs['Q'] = OutputPin(this, bitWidth: bitWidth);
    outputs['!Q'] = OutputPin(this, bitWidth: bitWidth);
    outputs['Q']!.value = 0;
    outputs['!Q']!.value = 1;
  }

  @override
  bool evaluate() {
    inputs['D']!.updateFromSource();

    final d = inputs['D']!.value;

      _newState = d;

    return true;
  }

  @override
  void applyNewState(){
    _storedValue = _newState;
    final mask = outputs['Q']!.mask;
    final newQ = _storedValue;
    final newNotQ = (~_storedValue) & mask;

    outputs['Q']!.value = newQ;
    outputs['!Q']!.value = newNotQ;
  }

}
