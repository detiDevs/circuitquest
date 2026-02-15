import 'package:circuitquest/core/commands/command.dart';
import '../../state/sandbox_state.dart';

/// Command to remove a component from the canvas.
class RemoveComponentCommand extends Command {
  final SandboxState _sandboxState;
  final String _componentId;
  
  // Store component data for undo
  PlacedComponent? _removedComponent;
  List<WireConnection> _removedConnections = [];

  RemoveComponentCommand(
    this._sandboxState,
    this._componentId,
  );

  @override
  void execute() {
    // Store component data before removing
    _removedComponent = _sandboxState.getComponent(_componentId);
    
    // Store all connections that will be removed
    _removedConnections = _sandboxState.connections
        .where((conn) =>
            conn.sourceComponentId == _componentId ||
            conn.targetComponentId == _componentId)
        .toList();
    
    // Remove the component
    _sandboxState.removeComponent(_componentId);
  }

  @override
  void undo() {
    if (_removedComponent == null) return;
    
    // Restore the component with its original ID using internal method
    _sandboxState.restoreComponentWithId(_removedComponent!);
    
    // Restore all connections
    for (final conn in _removedConnections) {
      // Add the connection back (addConnection will create the WireConnection automatically)
      _sandboxState.addConnection(
        conn.sourceComponentId,
        conn.sourcePin,
        conn.targetComponentId,
        conn.targetPin,
      );
    }
  }

  @override
  String get description => 'Remove component';
}