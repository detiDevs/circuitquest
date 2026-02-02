import 'package:circuitquest/core/components/base/component.dart';

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
    Set<Component> current =
        startingComponents?.toSet() ?? inputComponents.toSet();
    print("current: $current");

    if (current.isEmpty) {
      print("current is empty");
      return false;
    }

    // Check if there's an InstructionMemory and increase max cycles accordingly
    int actualMaxCycles = maxEvalCycles;
    for (final component in components) {
      if (component.runtimeType.toString() == 'InstructionMemory') {
        // Increase max cycles to allow all instructions to execute
        actualMaxCycles = maxEvalCycles + 500;
        break;
      }
    }

    int tick = 0;

    while (current.isNotEmpty) {
      final Set<Component> next = {};

      for (final component in current) {
        final changed = component.evaluate();

        if (changed) {
          // Schedule all downstream components
          for (final output in component.outputs.values) {
            for (final wire in output.connections) {
              next.add(wire.to.component);
            }
          }
        } else {
          print("No change");
        }
      }

      onUpdate?.call(current);
      if (onWait != null) {
        await onWait();
      }

      current = next;
      tick++;

      if (tick > actualMaxCycles * components.length) {
        // Likely oscillation / unstable feedback
        return false;
      }
    }
    print("Evaluated event driven");
    return true;
  }

  // Kahn / frontier evaluation. Useful for circuits without oscillation
  Future<bool> evaluateTopological({UpdateCallback? onUpdate, WaitCallback? onWait}) async {
    final Map<Component, int> indegree = {};
    final Map<int, Set<Component>> tickBuckets = {};

    // Initialize indegrees
    for (final component in components) {
      indegree[component] = 0;
    }

    for (final component in components) {
      for (final output in component.outputs.values) {
        for (final wire in output.connections) {
          indegree[wire.to.component] = (indegree[wire.to.component] ?? 0) + 1;
        }
      }
    }

    // Start with inputs
    Set<Component> current = inputComponents.toSet();
    int tick = 0;

    while (current.isNotEmpty) {
      tickBuckets[tick] = current.toSet();
      final Set<Component> next = {};

      for (final c in current) {
        for (final output in c.outputs.values) {
          for (final wire in output.connections) {
            final target = wire.to.component;
            indegree[target] = indegree[target]! - 1;
            if (indegree[target] == 0) {
              next.add(target);
            }
          }
        }
      }

      current = next;
      tick++;
    }

    // Cycle detection
    if (indegree.values.any((v) => v > 0)) {
      return false;
    }

    // Evaluate tick by tick
    for (final entry in tickBuckets.entries) {
      for (final component in entry.value) {
        component.evaluate();
      }
      onUpdate?.call(entry.value);
      if (onWait != null) {
        await onWait();
      }
    }
    print("Evaluated topologically");
    return true;
  }
}
