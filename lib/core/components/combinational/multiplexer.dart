import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/pin.dart';

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

  Multiplexer({
    required this.inputCount,
    this.dataBitWidth = 0 // accept any bitwidth by default
  }) {
    if (inputCount < 2) {
      throw ArgumentError('Multiplexer requires at least 2 inputs');
    }
    selectBitWidth = (inputCount - 1).bitLength == 0
        ? 1
        : (inputCount - 1).bitLength;

    // Create data inputs
    for (int i = 0; i < inputCount; i++) {
      inputs['input${i+1}'] = InputPin(this, bitWidth: dataBitWidth);
    }

    // Create select input
    inputs['selection'] = InputPin(this, bitWidth: selectBitWidth);

    // Create output
    outputs['outValue'] = OutputPin(this, bitWidth: dataBitWidth);
  }

  /// Evaluates the multiplexer and routes the selected input to the output.
  @override
  bool evaluate() {
    // Refresh all input values from their sources
    for (int i = 0; i < inputCount; i++) {
      inputs['input${i+1}']!.updateFromSource();
    }
    inputs['selection']!.updateFromSource();

    // Determine selected index, wrap into range to avoid invalid access
    final int rawSel = inputs['selection']!.value;
    final int selectedIndex = inputCount == 0 ? 0 : rawSel % inputCount;

    // Forward selected data
    final int newValue = inputs['input${selectedIndex+1}']!.value;
    final OutputPin outPin = outputs['outValue']!;
    final bool changed = outPin.value != newValue;
    outPin.value = newValue;
    return changed;
  }
}
