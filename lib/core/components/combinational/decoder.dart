import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Binary decoder: converts an N-bit input into 2^N one-hot outputs.
class Decoder extends Component {
  /// Bit width of the input selector.
  final int selectBitWidth;

  /// Number of outputs = 2^selectBitWidth.
  late final int outputCount;

  Decoder({required this.selectBitWidth}) {
    if (selectBitWidth <= 0) {
      throw ArgumentError('selectBitWidth must be positive');
    }
    outputCount = 1 << selectBitWidth;

    inputs['input'] = InputPin(this, bitWidth: selectBitWidth);
    for (int i = 0; i < outputCount; i++) {
      outputs['out$i'] = OutputPin(this, bitWidth: 1);
    }
  }

  /// Drives exactly one output high corresponding to the input value.
  @override
  bool evaluate() {
    inputs['input']!.updateFromSource();
    final int selector = inputs['input']!.value & ((1 << selectBitWidth) - 1);

    bool changed = false;
    for (int i = 0; i < outputCount; i++) {
      final int newValue = i == selector ? 1 : 0;
      final OutputPin outPin = outputs['out$i']!;
      if (outPin.value != newValue) {
        changed = true;
        outPin.value = newValue;
      } else {
        outPin.value = newValue; // keep values refreshed
      }
    }
    return changed;
  }
}
