import 'package:circuitquest/core/commands/command.dart';
import 'package:circuitquest/state/sandbox_state.dart';

/// Command to remove a wire connection.
class RemoveConnectionCommand extends Command {
  final SandboxState _sandboxState;
  final String _sourceComponentId;
  final String _sourcePinName; 
  final String _targetComponentId;
  final String _targetPinName;
  
  WireConnection? _connection;

  RemoveConnectionCommand(
    this._sandboxState,
    WireConnection connection,
  ) : _sourceComponentId = connection.sourceComponentId,
       _sourcePinName = connection.sourcePin,
       _targetComponentId = connection.targetComponentId,
       _targetPinName = connection.targetPin,
       _connection = connection;

  @override
  void execute() {
    // Find current connection by properties (might be different instance due to undo/redo)
    final currentConnection = _sandboxState.connections.firstWhere(
      (conn) =>
          conn.sourceComponentId == _sourceComponentId &&
          conn.sourcePin == _sourcePinName &&
          conn.targetComponentId == _targetComponentId &&
          conn.targetPin == _targetPinName,
      orElse: () => _connection!,
    );
    _connection = currentConnection;
    _sandboxState.removeConnection(currentConnection);
  }

  @override
  void undo() {
    // Re-add the connection and update reference
    _connection = _sandboxState.addConnection(
      _sourceComponentId,
      _sourcePinName,
      _targetComponentId,
      _targetPinName,
    );
  }

  @override
  String get description => 'Remove connection from $_sourceComponentId.$_sourcePinName to $_targetComponentId.$_targetPinName';
}
