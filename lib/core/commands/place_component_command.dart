import 'package:circuitquest/core/commands/command.dart';
import 'package:circuitquest/core/components/base/component.dart';
import 'package:flutter/material.dart';
import '../../state/sandbox_state.dart';

/// Command to place a component on the canvas.
class PlaceComponentCommand extends Command {
  final SandboxState _sandboxState;
  final String _componentType;
  final Offset _position;
  final Component _component;
  final bool _immovable;
  final String? _label;
  
  String? _componentId; // Will be set after execution

  PlaceComponentCommand(
    this._sandboxState,
    this._componentType,
    this._position,
    this._component, {
    bool immovable = false,
    String? label,
  }) : _immovable = immovable,
       _label = label;

  @override
  void execute() {
    _componentId = _sandboxState.placeComponent(
      _componentType,
      _position,
      _component,
      immovable: _immovable,
      label: _label,
    );
  }

  @override
  void undo() {
    if (_componentId != null) {
      _sandboxState.removeComponent(_componentId!);
    }
  }

  @override
  String get description => 'Place $_componentType';
}