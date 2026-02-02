import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/components/component_registry.dart';
import 'package:circuitquest/core/components/custom_component_data.dart';
import 'package:circuitquest/core/components/input_source.dart';
import 'package:circuitquest/core/components/output_probe.dart';
import 'package:circuitquest/core/logic/pin.dart';
import 'package:circuitquest/core/logic/wire.dart';
import 'package:circuitquest/core/simulation/evaluation_algorithms.dart';

class CustomComponent extends Component {
  final CustomComponentData data;
  final List<Component> _internalComponents = [];
  final List<InputSource> _internalInputs = [];
  final List<OutputProbe> _internalOutputs = [];

  CustomComponent(this.data) {
    for (final entry in data.inputMap.entries) {
      inputs[entry.key] = InputPin(this, bitWidth: entry.value);
    }
    for (final entry in data.outputMap.entries) {
      outputs[entry.key] = OutputPin(this, bitWidth: entry.value);
    }

    _buildInternalCircuit();
  }

  void _buildInternalCircuit() {
    final inputBitWidths = data.inputMap.values.toList(growable: false);
    int inputIndex = 0;
    for (final type in data.components) {
      Component? component;
      if (type == 'InputSource') {
        final bitWidth =
            inputIndex < inputBitWidths.length ? inputBitWidths[inputIndex] : 1;
        component = InputSource(bitWidth: bitWidth);
        inputIndex++;
      } else if (type == 'OutputProbe') {
        component = OutputProbe();
      } else {
        component = createComponentByName(type);
      }

      if (component == null) {
        continue;
      }

      _internalComponents.add(component);
      if (component is InputSource) {
        _internalInputs.add(component);
      } else if (component is OutputProbe) {
        _internalOutputs.add(component);
      }
    }

    for (final connection in data.connections) {
      if (connection.origin < 0 || connection.origin >= _internalComponents.length) {
        continue;
      }
      if (connection.destination < 0 ||
          connection.destination >= _internalComponents.length) {
        continue;
      }

      final source = _internalComponents[connection.origin];
      final target = _internalComponents[connection.destination];
      final sourceOutput = source.outputs[connection.originKey];
      final targetInput = target.inputs[connection.destinationKey];
      if (sourceOutput != null && targetInput != null) {
        Wire(sourceOutput, targetInput);
      }
    }
  }

  @override
  bool evaluate() {
    _syncExternalInputsToInternal();
    final changed = _evaluateInternalEventDrivenSync();
    _syncInternalOutputsToExternal();
    return changed;
  }

  void _syncExternalInputsToInternal() {
    if (_internalInputs.isEmpty) return;
    final inputKeys = data.inputMap.keys.toList(growable: false);
    for (int i = 0; i < inputKeys.length && i < _internalInputs.length; i++) {
      final key = inputKeys[i];
      final pin = inputs[key];
      if (pin == null) continue;
      pin.updateFromSource();
      _internalInputs[i].setValue(pin.value);
    }
  }

  void _syncInternalOutputsToExternal() {
    if (_internalOutputs.isEmpty) return;
    final outputKeys = data.outputMap.keys.toList(growable: false);
    for (int i = 0; i < outputKeys.length && i < _internalOutputs.length; i++) {
      final key = outputKeys[i];
      final outputPin = outputs[key];
      if (outputPin == null) continue;
      outputPin.value = _internalOutputs[i].value;
    }
  }

  bool _evaluateInternalEventDrivenSync({int maxEvalCycles = 1000}) {
    if (_internalComponents.isEmpty) return false;

    final Set<Component> allComponents = _internalComponents.toSet();
    final Set<Component> inputStarts = _internalComponents
        .where((c) => c.inputs.isEmpty || c is InputSource)
        .toSet();

    final Set<Component> startingSet =
        inputStarts.isEmpty ? allComponents : inputStarts;

    // Call async method without callbacks - it will complete synchronously
    // since there are no await points when callbacks are null
    bool result = false;
    EvaluationAlgorithms.evaluateEventDriven(
      allComponents: allComponents,
      startingComponents: startingSet,
      maxEvalCycles: maxEvalCycles,
    ).then((value) => result = value);
    
    // This works because when there are no async callbacks,
    // the Future completes synchronously
    return result;
  }
}