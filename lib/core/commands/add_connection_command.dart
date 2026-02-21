import 'package:circuitquest/core/commands/command.dart';
import 'package:circuitquest/state/sandbox_state.dart';

class AddConnectionCommand extends Command {
  final SandboxState _sandboxState;
  final String _sourceComponentId;
  final String _sourcePinName;
  final String _targetComponentId;
  final String _targetPinName;
  final void Function(String message)? _onError;

  WireConnection? _connection;

  AddConnectionCommand(
    this._sandboxState,
    this._sourceComponentId,
    this._sourcePinName,
    this._targetComponentId,
    this._targetPinName, {
    void Function(String message)? onError,
  }) : _onError = onError;

  @override
  void execute() {
    if (_connection != null) {
      // This is a redo - find and restore the connection by properties
      final existingConnection = _sandboxState.connections.firstWhere(
        (conn) =>
            conn.sourceComponentId == _sourceComponentId &&
            conn.sourcePin == _sourcePinName &&
            conn.targetComponentId == _targetComponentId &&
            conn.targetPin == _targetPinName,
        orElse: () {
          // Connection doesn't exist, create it again
          return _sandboxState.addConnection(
            _sourceComponentId,
            _sourcePinName,
            _targetComponentId,
            _targetPinName,
            onError: _onError,
          )!;
        },
      );
      _connection = existingConnection;
    } else {
      // First execution - create new connection
      _connection = _sandboxState.addConnection(
        _sourceComponentId,
        _sourcePinName,
        _targetComponentId,
        _targetPinName,
        onError: _onError,
      );
    }
  }

  @override
  void undo() {
    if (_connection != null) {
      // Find the current connection by properties (it might be a different instance)
      final currentConnection = _sandboxState.connections.firstWhere(
        (conn) =>
            conn.sourceComponentId == _sourceComponentId &&
            conn.sourcePin == _sourcePinName &&
            conn.targetComponentId == _targetComponentId &&
            conn.targetPin == _targetPinName,
        orElse: () => _connection!,
      );
      _sandboxState.removeConnection(currentConnection);
    }
  }

  @override
  String get description => 'Add connection from $_sourceComponentId.$_sourcePinName to $_targetComponentId.$_targetPinName';
}
