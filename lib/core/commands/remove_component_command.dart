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
    
    // Re-add the component with the same ID by temporarily storing it
    final originalId = _removedComponent!.id;
    
    // Place component (this will generate a new ID)
    final newId = _sandboxState.placeComponent(
      _removedComponent!.type,
      _removedComponent!.position,
      _removedComponent!.component,
      immovable: _removedComponent!.immovable,
      label: _removedComponent!.label,
    );
    
    // We need to update the connection IDs to match the new component ID
    // For now, we'll restore connections with the new ID
    for (final conn in _removedConnections) {
      final sourceId = conn.sourceComponentId == originalId ? newId : conn.sourceComponentId;
      final targetId = conn.targetComponentId == originalId ? newId : conn.targetComponentId;
      
      // Add the connection back (addConnection will create the WireConnection automatically)
      _sandboxState.addConnection(
        sourceId,
        conn.sourcePin,
        targetId,
        conn.targetPin,
      );
    }
  }

  @override
  String get description => 'Remove component';
}