import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/components/base/component.dart';
import '../core/logic/wire.dart';
import '../core/simulation/simulator.dart';
import '../core/components/input_source.dart';
import '../core/components/output_probe.dart';
import '../core/components/component_registry.dart';
import '../core/components/custom_component.dart';
import '../core/components/custom_component_data.dart';
import '../state/custom_component_library.dart';

/// Riverpod provider for sandbox state.
final sandboxProvider = ChangeNotifierProvider<SandboxState>(
  (ref) => SandboxState(ref.read(customComponentProvider)),
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

  /// Whether this component can be moved/removed by the player
  final bool immovable;

  /// Optional display label from level configuration (e.g., "A", "B")
  final String? label;

  PlacedComponent({
    required this.type,
    required this.component,
    required this.position,
    required this.id,
    this.immovable = false,
    this.label,
  });

  /// Converts this PlacedComponent to JSON format
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'position': [position.dx.toInt(), position.dy.toInt()],
      'id': id,
      if (immovable) 'immovable': immovable,
      if (label != null) 'label': label,
    };
  }
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

  factory WireConnection.fromJson(Map<String, dynamic> json) {
    return WireConnection(
      sourceComponentId: json['origin'].toString(),
      sourcePin: json['originKey'],
      targetComponentId: json['destination'].toString(),
      targetPin: json['destinationKey'],
    );
  }

  /// Converts this WireConnection to JSON format
  Map<String, dynamic> toJson() {
    return {
      'sourceComponentId': sourceComponentId,
      'sourcePin': sourcePin,
      'targetComponentId': targetComponentId,
      'targetPin': targetPin,
    };
  }
}

/// State management for the sandbox circuit designer.
///
/// Manages:
/// - Placed components on the canvas
/// - Wire connections between components
/// - Circuit simulation and evaluation
/// - Drag and drop interactions
class SandboxState extends ChangeNotifier {
  SandboxState(this._customComponentLibrary);

  final CustomComponentLibrary _customComponentLibrary;
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

  /// Simulation tick speed (ticks per second, 0 = instant)
  double _tickSpeed = 0.0;

  /// Saved component states before simulation for reset
  Map<String, Map<String, int>>? _savedComponentStates;

  /// Flag to cancel ongoing simulation
  bool _cancelSimulation = false;

  /// Components that are currently being evaluated (for visualization)
  Set<String> _activeComponentIds = {};

  /// Auto-increment counter for component IDs
  int _nextComponentId = 0;

  // Getters
  List<PlacedComponent> get placedComponents =>
      List.unmodifiable(_placedComponents);
  List<WireConnection> get connections => List.unmodifiable(_connections);
  String? get selectedComponentType => _selectedComponentType;
  PlacedComponent? get draggingComponent => _draggingComponent;
  bool get isSimulating => _isSimulating;
  double get tickSpeed => _tickSpeed;
  bool get canReset => _savedComponentStates != null;
  Set<String> get activeComponentIds => Set.unmodifiable(_activeComponentIds);
  ({String componentId, String pinName})? get wireDrawingStart =>
      _wireDrawingStart;

  /// Sets the currently selected component type for placement.
  void selectComponentType(String? type) {
    _selectedComponentType = type;
    notifyListeners();
  }

  /// Adds a new component to the canvas at the specified position.
  ///
  /// Returns the ID of the newly placed component.
  String placeComponent(
    String type,
    Offset position,
    Component component, {
    bool immovable = false,
    String? label,
  }) {
    final id = '${_nextComponentId++}';
    final placed = PlacedComponent(
      type: type,
      component: component,
      position: position,
      id: id,
      immovable: immovable,
      label: label,
    );
    _placedComponents.add(placed);
    print("Placed component with id: ${placed.id} and type ${placed.type}");
    notifyListeners();
    return id;
  }

  /// Removes a component from the canvas.
  ///
  /// Also removes all connections involving this component.
  void removeComponent(String componentId) {
    _placedComponents.removeWhere((c) => c.id == componentId);
    _connections.removeWhere(
      (conn) =>
          conn.sourceComponentId == componentId ||
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
        immovable: component.immovable,
        label: component.label,
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
  bool completeWireDrawing(
    String targetComponentId, 
    String targetPinName, {
    void Function(String message)? onError,
  }) {
    if (_wireDrawingStart == null) return false;

    final sourceComponentId = _wireDrawingStart!.componentId;
    final sourcePinName = _wireDrawingStart!.pinName;

    bool result = false;
    if (addConnection(
      sourceComponentId,
      sourcePinName,
      targetComponentId,
      targetPinName,
      onError: onError,
    )) {
      result = true;
    }
    _wireDrawingStart = null;
    notifyListeners();
    return result;
  }

  bool addConnection(
    String sourceComponentId,
    String sourcePinName,
    String targetComponentId,
    String targetPinName, {
    void Function(String message)? onError,
  }) {
    bool result = false;

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
      if (targetPin.hasSource){
        onError?.call("This input pin already has a connection!");
        return false;
      }
      // Wire constructor automatically connects the pins
      Wire(sourcePin, targetPin);

      // Track the connection
      _connections.add(
        WireConnection(
          sourceComponentId: sourceComponentId,
          sourcePin: sourcePinName,
          targetComponentId: targetComponentId,
          targetPin: targetPinName,
        ),
      );
      result = true;
      print("Connection was added.");
      
      // Trigger event-driven evaluation starting from the target component
      _evaluateCircuitFromComponent(targetComponent);
    } else {
      print("Connection was not added.");
      if(sourcePin == null) {
        print("Source pin was null");
      }
      if(targetPin == null) {
        print("Target pin was null");
      }
    }
    notifyListeners();
    return result;
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

    _evaluateCircuitFromComponent(targetComponent);

    _connections.remove(connection);
    notifyListeners();
  }

  /// Evaluates the circuit using event-driven simulation.
  void evaluateCircuit() {
    final allComponents = _placedComponents.map((pc) => pc.component).toSet();
    if (allComponents.isEmpty) return;

    // Treat components with no inputs or explicit InputSources as starting points
    final inputStarts = _placedComponents
        .where(
          (pc) => pc.component.inputs.isEmpty || pc.component is InputSource,
        )
        .map((pc) => pc.component)
        .toSet();
    
    // Also include ProgramCounter components as starting points (for processor simulation)
    final programCounters = _placedComponents
        .where((pc) => pc.component.runtimeType.toString() == 'ProgramCounter')
        .map((pc) => pc.component)
        .toSet();
    
    final startingSet = inputStarts.isEmpty 
        ? (programCounters.isEmpty ? allComponents : programCounters)
        : inputStarts..addAll(programCounters);

    _simulator = Simulator(
      components: allComponents,
      inputComponents: startingSet,
    );

    _simulator!.evaluateEventDriven(startingComponents: startingSet);
    notifyListeners();
  }

  /// Evaluates the circuit starting from a specific component.
  /// This is used when a new connection is added to trigger evaluation
  /// starting from the target component of the connection.
  void _evaluateCircuitFromComponent(Component targetComponent) {
    final allComponents = _placedComponents.map((pc) => pc.component).toSet();
    if (allComponents.isEmpty) return;

    // Create or update simulator with current components
    _simulator = Simulator(
      components: allComponents,
      inputComponents: {targetComponent}, // Only the target component as input
    );

    // Run event-driven evaluation starting from the target component
    _simulator!.evaluateEventDriven(startingComponents: {targetComponent});
    
    // Note: We don't call notifyListeners() here since addConnection already does it
  }

  /// Sets the tick speed for simulation (0 = instant, >0 = ticks per second)
  void setTickSpeed(double ticksPerSecond) {
    _tickSpeed = ticksPerSecond;
    notifyListeners();
  }

  /// Triggers event-driven evaluation starting from a specific component.
  /// This is used when an input source value changes to propagate the change.
  void evaluateFromComponent(Component component) {
    final allComponents = _placedComponents.map((pc) => pc.component).toSet();
    if (allComponents.isEmpty) return;

    // Create or update simulator with current components
    _simulator = Simulator(
      components: allComponents,
      inputComponents: {component}, // Use the changed component as starting point
    );

    // Run event-driven evaluation starting from the changed component
    _simulator!.evaluateEventDriven(startingComponents: {component});
    notifyListeners(); // Notify UI to update with new component states
  }

  /// Starts simulation with tick-based evaluation
  Future<void> startSimulation() async {
    if (_placedComponents.isEmpty) return;

    // Save current state for reset
    _saveComponentStates();
    _cancelSimulation = false;
    _isSimulating = true;
    _activeComponentIds = {};
    notifyListeners();

    final allComponents = _placedComponents.map((pc) => pc.component).toSet();
    final inputStarts = _placedComponents
        .where(
          (pc) => pc.component.inputs.isEmpty || pc.component is InputSource,
        )
        .map((pc) => pc.component)
        .toSet();
    
    // Also include ProgramCounter components as starting points (for processor simulation)
    final programCounters = _placedComponents
        .where((pc) => pc.component.runtimeType.toString() == 'ProgramCounter')
        .map((pc) => pc.component)
        .toSet();
    
    final startingSet = inputStarts.isEmpty 
        ? (programCounters.isEmpty ? allComponents : programCounters)
        : inputStarts..addAll(programCounters);

    _simulator = Simulator(
      components: allComponents,
      inputComponents: startingSet,
    );

    if (_tickSpeed == 0) {
      // Instant evaluation
      _simulator!.evaluateEventDriven(startingComponents: startingSet);
    } else {
      // Timed evaluation with onWait and onUpdate callbacks
      await _simulator!.evaluateEventDriven(
        startingComponents: startingSet,
        onUpdate: (updatedComponents) {
          // Track which components are active in this tick
          _activeComponentIds = _placedComponents
              .where((pc) => updatedComponents.contains(pc.component))
              .map((pc) => pc.id)
              .toSet();
        },
        onWait: () async {
          if (_cancelSimulation) return;
          notifyListeners();
          await Future.delayed(
            Duration(milliseconds: (1000 / _tickSpeed).round()),
          );
        },
      );
    }

    // Simulation complete
    _isSimulating = false;
    _activeComponentIds = {};
    _savedComponentStates = null;
    notifyListeners();
  }

  /// Pauses the simulation
  void pauseSimulation() {
    _cancelSimulation = true;
    _isSimulating = false;
    _activeComponentIds = {};
    notifyListeners();
  }

  /// Resets circuit to state before simulation started
  void resetSimulation() {
    _cancelSimulation = true;
    _isSimulating = false;
    _activeComponentIds = {};
    _restoreComponentStates();
    _savedComponentStates = null;
    notifyListeners();
  }

  /// Internal: Save component output states
  void _saveComponentStates() {
    _savedComponentStates = {};
    for (final placed in _placedComponents) {
      final outputs = <String, int>{};
      for (final entry in placed.component.outputs.entries) {
        outputs[entry.key] = entry.value.value;
      }
      _savedComponentStates![placed.id] = outputs;
    }
  }

  /// Internal: Restore component output states
  void _restoreComponentStates() {
    if (_savedComponentStates == null) return;

    for (final placed in _placedComponents) {
      final savedOutputs = _savedComponentStates![placed.id];
      if (savedOutputs != null) {
        for (final entry in savedOutputs.entries) {
          final output = placed.component.outputs[entry.key];
          if (output != null) {
            output.value = entry.value;
          }
        }
      }
    }
  }

  /// Clears the entire circuit (all components and connections).
  void clearCircuit() {
    _cancelSimulation = true;
    _placedComponents.clear();
    _connections.clear();
    _wireDrawingStart = null;
    _isSimulating = false;
    _savedComponentStates = null;
    notifyListeners();
  }

  /// Fully reset the sandbox state (used when entering a fresh scene).
  void reset() {
    _cancelSimulation = true;
    _placedComponents.clear();
    _connections.clear();
    _wireDrawingStart = null;
    _isSimulating = false;
    _selectedComponentType = null;
    _draggingComponent = null;
    _simulator = null;
    _nextComponentId = 0;
    _tickSpeed = 0.0;
    _savedComponentStates = null;
  }

  @override
  void dispose() {
    _cancelSimulation = true;
    super.dispose();
  }

  /// Serializes the current circuit to JSON format
  String serializeCircuit({String? name, String? description}) {
    final circuitData = {
      'name': name ?? 'Saved Circuit',
      'description': description ?? 'Circuit saved from sandbox mode',
      'components': _placedComponents.map((pc) => pc.toJson()).toList(),
      'connections': _connections.map((wc) => wc.toJson()).toList(),
    };
    return jsonEncode(circuitData);
  }

  /// Deserializes a circuit from JSON and loads it into the sandbox
  bool loadCircuitFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Stop any running simulation
      if (_isSimulating) {
        pauseSimulation();
      }

      // Clear existing circuit
      _placedComponents.clear();
      _connections.clear();
      _wireDrawingStart = null;
      _savedComponentStates = null;

      // Load components
      final components = data['components'] as List<dynamic>;
      for (final compData in components) {
        final type = compData['type'] as String;
        final positionList = compData['position'] as List<dynamic>;
        final position = Offset(
          (positionList[0] as num).toDouble(),
          (positionList[1] as num).toDouble(),
        );
        final id = compData['id'] as String;
        final immovable = compData['immovable'] as bool? ?? false;
        final label = compData['label'] as String?;

        // Create component instance
        Component? component;
        if (type == 'InputSource') {
          component = InputSource();
        } else if (type == 'OutputProbe') {
          component = OutputProbe();
        } else {
          component = createComponentByName(type);
          component ??= _createCustomComponent(type);
        }

        if (component == null) {
          print('Unknown component type: $type');
          continue;
        }

        _placedComponents.add(
          PlacedComponent(
            type: type,
            component: component,
            position: position,
            id: id,
            immovable: immovable,
            label: label,
          ),
        );
      }

      // Load connections
      final connections = data['connections'] as List<dynamic>;
      for (final connData in connections) {
        _connections.add(
          WireConnection(
            sourceComponentId: connData['sourceComponentId'] as String,
            sourcePin: connData['sourcePin'] as String,
            targetComponentId: connData['targetComponentId'] as String,
            targetPin: connData['targetPin'] as String,
          ),
        );
      }

      // Rebuild wire connections
      _rebuildWireConnections();

      notifyListeners();
      return true;
    } catch (e) {
      print('Error loading circuit: $e');
      return false;
    }
  }

  CustomComponent? _createCustomComponent(String name) {
    final data = _customComponentLibrary.getByName(name);
    if (data == null) return null;
    return CustomComponent(data);
  }

  CustomComponentData? buildCustomComponentData({
    required String name,
    required List<String> inputKeys,
    required List<String> outputKeys,
  }) {
    final inputComponents = _placedComponents
        .where((c) => c.component is InputSource)
        .toList();
    final outputComponents = _placedComponents
        .where((c) => c.component is OutputProbe)
        .toList();

    if (inputKeys.length != inputComponents.length ||
        outputKeys.length != outputComponents.length) {
      return null;
    }

    final inputMap = LinkedHashMap<String, int>();
    for (int i = 0; i < inputComponents.length; i++) {
      final input = inputComponents[i].component as InputSource;
      final bitWidth = input.outputs['outValue']?.bitWidth ?? 1;
      inputMap[inputKeys[i]] = bitWidth;
    }

    final outputMap = LinkedHashMap<String, int>();
    for (int i = 0; i < outputComponents.length; i++) {
      final output = outputComponents[i].component as OutputProbe;
      outputMap[outputKeys[i]] = output.bitWidth;
    }

    final components = _placedComponents.map((pc) => pc.type).toList();
    final idToIndex = <String, int>{};
    for (int i = 0; i < _placedComponents.length; i++) {
      idToIndex[_placedComponents[i].id] = i;
    }

    final connections = _connections.map((conn) {
      final origin = idToIndex[conn.sourceComponentId] ?? -1;
      final destination = idToIndex[conn.targetComponentId] ?? -1;
      return CustomComponentConnection(
        origin: origin,
        originKey: conn.sourcePin,
        destination: destination,
        destinationKey: conn.targetPin,
      );
    }).toList();

    return CustomComponentData(
      name: name,
      inputMap: inputMap,
      outputMap: outputMap,
      components: components,
      connections: connections,
    );
  }

  /// Rebuilds wire connections between components
  void _rebuildWireConnections() {
    // Clear existing wire connections by setting sources to null
    for (final placed in _placedComponents) {
      for (final input in placed.component.inputs.values) {
        input.source = null;
      }
    }

    // Recreate connections based on WireConnection list
    for (final conn in _connections) {
      final source = getComponent(conn.sourceComponentId);
      final target = getComponent(conn.targetComponentId);

      if (source != null && target != null) {
        final sourceOutput = source.component.outputs[conn.sourcePin];
        final targetInput = target.component.inputs[conn.targetPin];

        if (sourceOutput != null && targetInput != null) {
          Wire(sourceOutput, targetInput);
        }
      }
    }
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
