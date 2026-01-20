import 'package:cirquitquest_flutter/core/components/base/component.dart';
import 'package:cirquitquest_flutter/core/logic/pin.dart';

/// Multiplexer that forwards one of several data inputs to a single output
/// based on the binary value of the select input.
///
/// The number of select bits is derived from the number of data inputs:
/// selectBitWidth = max(1, (inputCount - 1).bitLength).
class Multiplexer extends Component {
  /// Total number of data inputs (must be >= 2).
  final int inputCount;

  /// Bit width of each data input and the output.
  final int dataBitWidth;

  /// Bit width of the select input, derived from [inputCount].
  late final int selectBitWidth;

  Multiplexer({required this.inputCount, this.dataBitWidth = 1}) {
    if (inputCount < 2) {
      throw ArgumentError('Multiplexer requires at least 2 inputs');
    }
    selectBitWidth = (inputCount - 1).bitLength == 0
        ? 1
        : (inputCount - 1).bitLength;

    // Create data inputs
    for (int i = 0; i < inputCount; i++) {
      inputs['in$i'] = InputPin(this, bitWidth: dataBitWidth);
    }

    // Create select input
    inputs['sel'] = InputPin(this, bitWidth: selectBitWidth);

    // Create output
    outputs['out'] = OutputPin(this, bitWidth: dataBitWidth);
  }

  /// Evaluates the multiplexer and routes the selected input to the output.
  @override
  bool evaluate() {
    // Refresh all input values from their sources
    for (int i = 0; i < inputCount; i++) {
      inputs['in$i']!.updateFromSource();
    }
    inputs['sel']!.updateFromSource();

    // Determine selected index, wrap into range to avoid invalid access
    final int rawSel = inputs['sel']!.value;
    final int selectedIndex = inputCount == 0 ? 0 : rawSel % inputCount;

    // Forward selected data
    final int newValue = inputs['in$selectedIndex']!.value;
    final OutputPin outPin = outputs['out']!;
    final bool changed = outPin.value != newValue;
    outPin.value = newValue;
    return changed;
  }
}
