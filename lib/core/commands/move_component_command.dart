import 'package:circuitquest/core/commands/command.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:flutter/material.dart';

class MoveComponentCommand extends Command {
  final SandboxState _sandboxState;
  final String _componentId;
  final Offset _newPosition;
  final Offset _oldPosition;

  MoveComponentCommand(
    this._sandboxState,
    this._componentId,
    this._newPosition,
    this._oldPosition
  );

  @override
  void execute(){
    _sandboxState.moveComponent(_componentId, _newPosition);
  }

  @override
  void undo(){
    _sandboxState.moveComponent(_componentId, _oldPosition);
  }

  @override
  String get description => 'Move component';

}
