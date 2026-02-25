import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/logic/wire.dart';

enum PinPosition { TOP, RIGHT, BOTTOM, LEFT }

abstract class Pin {
  final Component component;
  int _bitWidth;

  int _value = 0;

  Pin(this.component, {int bitWidth = 1}) : _bitWidth = bitWidth;

  /// Gets the bit width of this pin
  int get bitWidth => _bitWidth;

  /// Sets the bit width of this pin and updates the value mask
  set bitWidth(int newBitWidth) {
    if (newBitWidth <= 0) {
      throw ArgumentError('bitWidth must be positive');
    }
    _bitWidth = newBitWidth;
    // Re-apply mask to current value to ensure it fits the new bit width
    final mask = (1 << _bitWidth) - 1;
    _value = _value & mask;
  }

  int get value => _value;

  set value(int newValue) {
    // use a bitmask to make sure the value is compatible with the bitwidth
    final mask = (1 << bitWidth) - 1;
    _value = newValue & mask;
  }

  int get mask => (1 << bitWidth) - 1;
}

class InputPin extends Pin {
  Wire? source;

  InputPin(super.component, {super.bitWidth});

  bool get hasSource => source != null;

  void updateFromSource() {
    if (source != null) {
      value = source!.value;
    } else {
      value = 0;
    }
  }
}

class OutputPin extends Pin {
  final List<Wire> connections = [];

  OutputPin(super.component, {super.bitWidth});

  void connect(Wire wire) {
    connections.add(wire);
  }

  /// Creates a new OutputPin with the same component but different bitwidth.
  OutputPin copyWith(int newBitWidth) {
    final newPin = OutputPin(component, bitWidth: newBitWidth);
    newPin.value = value; // Preserve the value, it will be masked
    return newPin;
  }
}
