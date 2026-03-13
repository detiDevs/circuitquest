import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/core/components/base/sequentialComponent.dart';
import 'package:circuitquest/core/components/cpu/program_counter.dart';

import 'package:circuitquest/core/simulation/clockManager.dart';

/// Shared evaluation algorithms for circuit simulation.
class EvaluationAlgorithms {
  /// Event-driven evaluation algorithm.
  ///
  /// Propagates changes through the circuit starting from the given components.
  /// Supports optional callbacks for visualization when called asynchronously.
  /// Returns true if evaluation completed successfully, false if it hit the max cycles limit.
  static Future<bool> evaluateEventDriven({
    required Set<Component> allComponents,
    required Set<Component> startingComponents,
    Clockmanager? clockManager,
    void Function(Set<Component> components)? onUpdate,
    Future<void> Function()? onWait,
    int maxEvalCycles = 1000,
    bool clock = true,
  }) async {
    Set<Component> current = startingComponents.toSet();

    if (current.isEmpty) {
      return false;
    }

    // Check if there's an InstructionMemory and increase max cycles accordingly
    int actualMaxCycles = maxEvalCycles;
    for (final component in allComponents) {
      if (component.runtimeType.toString() == 'InstructionMemory') {
        // Increase max cycles to allow all instructions to execute
        actualMaxCycles = maxEvalCycles + 500;
        break;
      }
    }

    int tick = 0;
    if (clockManager != null && clockManager.shouldUpdateManually()) {
      // update sequential components (for Levels without PC but with sequential Compoenents)
      final sequentialComponents = allComponents.where(
        (c) => c is SequentialComponent,
      );
      for (final comp in sequentialComponents) {
        if (comp is SequentialComponent) {
          comp.applyNewState();
        }
      }
    }

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
        }
      }

      onUpdate?.call(current);
      if (onWait != null) {
        await onWait();
      }

      if (clockManager?.tickAndCheckClock() == true) {
        // update sequential components
        final sequentialComponents = allComponents.where(
          (c) => c is SequentialComponent,
        );
        for (final comp in sequentialComponents) {
          if (comp is SequentialComponent) {
            comp.applyNewState();
          }
        }

        // add only pc to next eval cycle
        final programCounters = allComponents.where(
          (c) => c.runtimeType.toString() == 'ProgramCounter',
        );
        next.addAll(programCounters);
      }

      current = next;
      tick++;

      // continue clock if current cycle is shorter than clock cycle
      if (current.isEmpty &&
          clockManager != null &&
          clockManager.ticksPerClockCycle > 0 &&
          clockManager.shouldContinue(allComponents)) {
        bool clockSwitched = false;
        int emptyTicks = 0;
        const maxEmptyTicks =
            50; // technically not neccessary but second safety

        while (!clockSwitched && emptyTicks < maxEmptyTicks) {
          clockSwitched = clockManager.tickAndCheckClock();
          emptyTicks++;
          tick++;

          if (onWait != null) {
            await onWait();
          }
        }

        if (clockSwitched) {
          // when clock switched: update sequential components
          final sequentialComponents = allComponents.where(
            (c) => c is SequentialComponent,
          );
          for (final comp in sequentialComponents) {
            if (comp is SequentialComponent) {
              comp.applyNewState();
            }
          }

          // start next cycle from PC
          final programCounters = allComponents.where(
            (e) => e is ProgramCounter
          );
          current.addAll(programCounters.toSet());
          current = current.toSet();
          
        }
      }

      if (tick > actualMaxCycles * allComponents.length) {
        // Likely oscillation / unstable feedback
        return false;
      }
    }

    return true;
  }

  /// Topological (Kahn's algorithm) evaluation.
  ///
  /// Evaluates components in dependency order, useful for acyclic circuits.
  /// Returns true if successful, false if a cycle is detected.
  static Future<bool> evaluateTopological({
    required Set<Component> allComponents,
    required Set<Component> inputComponents,
    void Function(Set<Component> components)? onUpdate,
    Future<void> Function()? onWait,
  }) async {
    final Map<Component, int> indegree = {};
    final Map<int, Set<Component>> tickBuckets = {};

    // Initialize indegrees
    for (final component in allComponents) {
      indegree[component] = 0;
    }

    for (final component in allComponents) {
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

    return true;
  }
}
