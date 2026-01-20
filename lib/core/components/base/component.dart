import 'package:circuitquest_flutter/core/logic/pin.dart';

abstract class Component {
  static int _nextId = 0;

  final int id;
  final Map<String, InputPin> inputs = {};
  final Map<String, OutputPin> outputs = {};

  Component() : id = _nextId++;

  /// Returns true if output changed
  bool evaluate();

  /// For clocked components
  void tick() {}
}
