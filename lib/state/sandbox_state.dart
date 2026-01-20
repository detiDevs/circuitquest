import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/components/base/component.dart';
import '../core/logic/wire.dart';
import '../core/simulation/simulator.dart';

/// Riverpod provider for sandbox state.
final sandboxProvider = ChangeNotifierProvider<SandboxState>(
  (ref) => SandboxState(),
);

/// Represents a component instance placed on the canvas.
class PlacedComponent {
  /// The component type (e.g., "And", "Or", "Not")
  final String type;
  
  /// The actual logic component instance
  final Component component;
  
  /// Position on the canvas grid
  final Offset position;
  
  /// Unique identifier for this placed component
  final String id;

  PlacedComponent({
    required this.type,
    required this.component,
    required this.position,
    required this.id,
  });
}

/// Represents a wire connection between two component pins.
class WireConnection {
  /// Source component ID
  final String sourceComponentId;
  
  /// Source output pin name
  final String sourcePin;
  
  /// Target component ID
  final String targetComponentId;
  
  /// Target input pin name
  final String targetPin;

  WireConnection({
    required this.sourceComponentId,
    required this.sourcePin,
    required this.targetComponentId,
    required this.targetPin,
  });
}

/// State management for the sandbox circuit designer.
///
/// Manages:
/// - Placed components on the canvas
/// - Wire connections between components
/// - Circuit simulation and evaluation
/// - Drag and drop interactions
class SandboxState extends ChangeNotifier {
  /// All components placed on the canvas
  final List<PlacedComponent> _placedComponents = [];
  
  /// All wire connections in the circuit
  final List<WireConnection> _connections = [];
  
  /// The simulator instance for evaluating the circuit
  Simulator? _simulator;
  
  /// Currently selected component type for placement
  String? _selectedComponentType;
  
  /// Component being dragged (if any)
  PlacedComponent? _draggingComponent;
  
  /// Wire being drawn (source component and pin)
  ({String componentId, String pinName})? _wireDrawingStart;
  
  /// Current simulation running state
  bool _isSimulating = false;
  
  /// Auto-increment counter for component IDs
  int _nextComponentId = 0;

  // Getters
  List<PlacedComponent> get placedComponents => List.unmodifiable(_placedComponents);
  List<WireConnection> get connections => List.unmodifiable(_connections);
  String? get selectedComponentType => _selectedComponentType;
  PlacedComponent? get draggingComponent => _draggingComponent;
  bool get isSimulating => _isSimulating;
  ({String componentId, String pinName})? get wireDrawingStart => _wireDrawingStart;

  /// Sets the currently selected component type for placement.
  void selectComponentType(String? type) {
    _selectedComponentType = type;
    notifyListeners();
  }

  /// Adds a new component to the canvas at the specified position.
  ///
  /// Returns the ID of the newly placed component.
  String placeComponent(String type, Offset position, Component component) {
    final id = 'component_${_nextComponentId++}';
    final placed = PlacedComponent(
      type: type,
      component: component,
      position: position,
      id: id,
    );
    _placedComponents.add(placed);
    notifyListeners();
    return id;
  }

  /// Removes a component from the canvas.
  ///
  /// Also removes all connections involving this component.
  void removeComponent(String componentId) {
    _placedComponents.removeWhere((c) => c.id == componentId);
    _connections.removeWhere(
      (conn) => conn.sourceComponentId == componentId || 
                conn.targetComponentId == componentId,
    );
    notifyListeners();
  }

  /// Moves a component to a new position.
  void moveComponent(String componentId, Offset newPosition) {
    final index = _placedComponents.indexWhere((c) => c.id == componentId);
    if (index != -1) {
      final component = _placedComponents[index];
      _placedComponents[index] = PlacedComponent(
        type: component.type,
        component: component.component,
        position: newPosition,
        id: component.id,
      );
      notifyListeners();
    }
  }

  /// Starts drawing a wire from the specified component pin.
  void startWireDrawing(String componentId, String pinName) {
    _wireDrawingStart = (componentId: componentId, pinName: pinName);
    notifyListeners();
  }

  /// Completes a wire connection to the specified target component pin.
  ///
  /// Returns true if the connection was created successfully.
  bool completeWireDrawing(String targetComponentId, String targetPinName) {
    if (_wireDrawingStart == null) return false;

    final sourceComponentId = _wireDrawingStart!.componentId;
    final sourcePinName = _wireDrawingStart!.pinName;

    // Find the components
    final sourceComponent = _placedComponents
        .firstWhere((c) => c.id == sourceComponentId)
        .component;
    final targetComponent = _placedComponents
        .firstWhere((c) => c.id == targetComponentId)
        .component;

    // Create the actual wire connection in the component graph
    final sourcePin = sourceComponent.outputs[sourcePinName];
    final targetPin = targetComponent.inputs[targetPinName];

    if (sourcePin != null && targetPin != null) {
      // Wire constructor automatically connects the pins
      Wire(sourcePin, targetPin);

      // Track the connection
      _connections.add(WireConnection(
        sourceComponentId: sourceComponentId,
        sourcePin: sourcePinName,
        targetComponentId: targetComponentId,
        targetPin: targetPinName,
      ));

      _wireDrawingStart = null;
      notifyListeners();
      return true;
    }

    _wireDrawingStart = null;
    notifyListeners();
    return false;
  }

  /// Cancels the current wire drawing operation.
  void cancelWireDrawing() {
    _wireDrawingStart = null;
    notifyListeners();
  }

  /// Removes a wire connection.
  void removeConnection(WireConnection connection) {
    // Find components
    final sourceComponent = _placedComponents
        .firstWhere((c) => c.id == connection.sourceComponentId)
        .component;
    final targetComponent = _placedComponents
        .firstWhere((c) => c.id == connection.targetComponentId)
        .component;

    // Disconnect the wire
    final sourcePin = sourceComponent.outputs[connection.sourcePin];
    final targetPin = targetComponent.inputs[connection.targetPin];

    if (sourcePin != null && targetPin != null) {
      sourcePin.connections.removeWhere((wire) => wire.to == targetPin);
      if (targetPin.source?.from == sourcePin) {
        targetPin.source = null;
      }
    }

    _connections.remove(connection);
    notifyListeners();
  }

  /// Evaluates the circuit using event-driven simulation.
  void evaluateCircuit() {
    final allComponents = _placedComponents.map((pc) => pc.component).toSet();
    if (allComponents.isEmpty) return;
    
    // Create a new simulator instance with current components
    _simulator = Simulator(
      components: allComponents,
      inputComponents: {}, // For sandbox mode, no specific input components
    );
    
    _simulator!.evaluateEventDriven();
    notifyListeners();
  }

  /// Starts continuous simulation mode.
  void startSimulation() {
    _isSimulating = true;
    notifyListeners();
  }

  /// Stops continuous simulation mode.
  void stopSimulation() {
    _isSimulating = false;
    notifyListeners();
  }

  /// Clears the entire circuit (all components and connections).
  void clearCircuit() {
    _placedComponents.clear();
    _connections.clear();
    _wireDrawingStart = null;
    _isSimulating = false;
    notifyListeners();
  }

  /// Gets a component by its ID.
  PlacedComponent? getComponent(String id) {
    try {
      return _placedComponents.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
