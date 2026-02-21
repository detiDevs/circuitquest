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
  
  String? _componentId; // Will be set after first execution
  PlacedComponent? _placedComponent; // Store the full component for restoration

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
    if (_placedComponent != null) {
      // This is a redo - restore the component with its original ID
      _sandboxState.restoreComponentWithId(_placedComponent!);
    } else {
      // This is the first execution - create new component
      _componentId = _sandboxState.placeComponent(
        _componentType,
        _position,
        _component,
        immovable: _immovable,
        label: _label,
      );
      // Store the placed component for future redo operations
      _placedComponent = _sandboxState.getComponent(_componentId!);
    }
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