import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/simulation/evaluation_algorithms.dart';

typedef UpdateCallback = void Function(Set<Component> components);
typedef WaitCallback = Future<void> Function();

class Simulator {
  final Set<Component> components;
  final Set<Component> inputComponents;

  Simulator({required this.components, required this.inputComponents});

  // Event driven evaluation. Useful for oscillating components.
  Future<bool> evaluateEventDriven({
    Set<Component>? startingComponents,
    UpdateCallback? onUpdate,
    WaitCallback? onWait,
    int maxEvalCycles = 1000,
  }) async {
    // Determine starting components
    final starting = startingComponents?.toSet() ?? inputComponents.toSet();
    print("current: $starting");

    if (starting.isEmpty) {
      print("current is empty");
      return false;
    }

    final result = await EvaluationAlgorithms.evaluateEventDriven(
      allComponents: components,
      startingComponents: starting,
      onUpdate: onUpdate,
      onWait: onWait,
      maxEvalCycles: maxEvalCycles,
    );
    
    print("Evaluated event driven");
    return result;
  }

  // Kahn / frontier evaluation. Useful for circuits without oscillation
  Future<bool> evaluateTopological({UpdateCallback? onUpdate, WaitCallback? onWait}) async {
    final result = await EvaluationAlgorithms.evaluateTopological(
      allComponents: components,
      inputComponents: inputComponents,
      onUpdate: onUpdate,
      onWait: onWait,
    );
    
    print("Evaluated topologically");
    return result;
  }
}
