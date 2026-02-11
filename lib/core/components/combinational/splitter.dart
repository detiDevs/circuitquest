import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Splits a wide input bus into equally sized output slices.
class Splitter extends Component {
  /// Number of output slices.
  final int sliceCount;

  /// Bit width of each slice.
  final int sliceBitWidth;

  /// Total input width derived from sliceCount * sliceBitWidth.
  late final int inputBitWidth;

  Splitter({required this.sliceCount, required this.sliceBitWidth}) {
    if (sliceCount <= 0 || sliceBitWidth <= 0) {
      throw ArgumentError('sliceCount and sliceBitWidth must be positive');
    }
    inputBitWidth = sliceCount * sliceBitWidth;

    inputs['input'] = InputPin(this, bitWidth: inputBitWidth);
    for (int i = 0; i < sliceCount; i++) {
      outputs['outValue${1 << i}'] = OutputPin(this, bitWidth: sliceBitWidth);
      outputs['outValue${1 << i}']!.value = 0;
    }
  }

  /// Extracts slices from the input bus and drives each output slice.
  @override
  bool evaluate() {
    inputs['input']!.updateFromSource();
    final int value = inputs['input']!.value;
    final int sliceMask = (1 << sliceBitWidth) - 1;

    bool changed = false;
    for (int i = 0; i < sliceCount; i++) {
      final int shifted = value >> (i * sliceBitWidth);
      final int slice = shifted & sliceMask;
      final OutputPin outPin = outputs['outValue${1 << i}']!;
      if (outPin.value != slice) {
        changed = true;
        outPin.value = slice;
      } else {
        outPin.value = slice; // ensure value is written even if unchanged
      }
    }
    return changed;
  }
}
