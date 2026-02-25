import 'package:circuitquest/core/logic/pin.dart';

abstract class Component {
  static int _nextId = 0;

  final int id;
  final Map<String, InputPin> inputs = {};
  final Map<String, OutputPin> outputs = {};

  // Optional pin positions.
  // A pin only has to be in here as an entry if it does not go to the default positions
  // (left for input, right for output)
  Map<String, PinPosition>? pinPositions;

  Component() : id = _nextId++;

  /// Returns true if output changed
  bool evaluate();

  /// For clocked components
  void tick() {}
}
