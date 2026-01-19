import 'package:cirquitquest_flutter/core/components/base/component.dart';
import 'package:cirquitquest_flutter/core/logic/wire.dart';

abstract class Pin {
  final Component component;
  final int bitWidth;

  int _value = 0;
  
  Pin(this.component, {this.bitWidth = 1});

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
    }
  }
}


class OutputPin extends Pin {
  final List<Wire> connections = [];

  OutputPin(super.component, {super.bitWidth});

  void connect(Wire wire) {
    connections.add(wire);
  }
}

