import 'package:circuitquest/domain/commands/command.dart';
import 'package:circuitquest/domain/use_cases/sandbox_engine.dart';
import 'package:flutter/material.dart';

class MoveComponentCommand extends Command {
  final SandboxEngine _sandboxState;
  final String _componentId;
  final Offset _newPosition;
  final Offset _oldPosition;

  MoveComponentCommand(
    this._sandboxState,
    this._componentId,
    this._newPosition,
    this._oldPosition, {
    super.onError,
  });

  @override
  void execute() {
    if (!_sandboxState.moveComponent(_componentId, _newPosition, oldPosition: _oldPosition)) {
      onError!("");
    }
  }

  @override
  void undo() {
    _sandboxState.moveComponent(_componentId, _oldPosition);
  }

  @override
  String get description => 'Move component';
}
