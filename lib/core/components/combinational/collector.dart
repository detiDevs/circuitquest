import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

/// Collects multiple equal-width inputs into a single wider output bus.
class Collector extends Component {
  /// Number of input slices to collect.
  final int sliceCount;

  /// Bit width of each input slice.
  final int sliceBitWidth;

  /// Total output width derived from sliceCount * sliceBitWidth.
  late final int outputBitWidth;

  Collector({required this.sliceCount, required this.sliceBitWidth}) {
    if (sliceCount <= 0 || sliceBitWidth <= 0) {
      throw ArgumentError('sliceCount and sliceBitWidth must be positive');
    }
    outputBitWidth = sliceCount * sliceBitWidth;

    for (int i = 0; i < sliceCount; i++) {
      inputs['in$i'] = InputPin(this, bitWidth: sliceBitWidth);
    }
    outputs['out'] = OutputPin(this, bitWidth: outputBitWidth);
  }

  /// Concatenates the input slices into a single wide value.
  @override
  bool evaluate() {
    // Update all inputs
    for (int i = 0; i < sliceCount; i++) {
      inputs['in$i']!.updateFromSource();
    }

    int aggregated = 0;
    for (int i = 0; i < sliceCount; i++) {
      final int slice = inputs['in$i']!.value & ((1 << sliceBitWidth) - 1);
      aggregated |= (slice << (i * sliceBitWidth));
    }

    final OutputPin outPin = outputs['out']!;
    final bool changed = outPin.value != aggregated;
    outPin.value = aggregated;
    return changed;
  }
}
