import 'package:circuitquest/core/components/input_source.dart';
import 'package:circuitquest/core/components/output_probe.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/state/sandbox_state.dart';

/// Service for validating circuit solutions against level test cases
class LevelValidator {
  /// Validates a circuit solution by running all test cases
  /// 
  /// Returns a validation result containing whether the solution is correct
  /// and any error details if incorrect.
  static LevelValidationResult validateCircuit(
    List<PlacedComponent> components,
    List<LevelTest> tests,
  ) {
    try {
      for (final test in tests) {
        if (!_runTestCase(components, test)) {
          return LevelValidationResult(
            isCorrect: false,
            errorMessage: 'Test case failed: ${test.inputs} should produce ${test.expectedOutput}',
          );
        }
      }
      
      return LevelValidationResult(
        isCorrect: true,
        errorMessage: null,
      );
    } catch (e) {
      return LevelValidationResult(
        isCorrect: false,
        errorMessage: 'Error during validation: $e',
      );
    }
  }

  /// Runs a single test case and returns whether it passed
  static bool _runTestCase(List<PlacedComponent> components, LevelTest test) {
    // Find all input sources and output probes
    final inputSources = <InputSource>[];
    final outputProbes = <OutputProbe>[];
    
    for (final component in components) {
      if (component.component is InputSource) {
        inputSources.add(component.component as InputSource);
      } else if (component.component is OutputProbe) {
        outputProbes.add(component.component as OutputProbe);
      }
    }

    // Set input values
    if (test.inputs.length != inputSources.length) {
      return false;
    }

    for (int i = 0; i < test.inputs.length; i++) {
      final inputValues = test.inputs[i];
      final inputSource = inputSources[i];
      // InputSource typically has an 'output' pin, set its value
      if (inputValues.isNotEmpty) {
        inputSource.setValue(inputValues[0]);
      }
    }

    // Evaluate circuit
    for (final component in components) {
      component.component.evaluate();
    }

    // Check output values
    if (test.expectedOutput.length != outputProbes.length) {
      return false;
    }

    for (int i = 0; i < test.expectedOutput.length; i++) {
      final expectedValues = test.expectedOutput[i];
      final outputProbe = outputProbes[i];
      final actualValue = outputProbe.value;

      if (expectedValues.isEmpty || expectedValues[0] != actualValue) {
        return false;
      }
    }

    return true;
  }
}

/// Result of level validation
class LevelValidationResult {
  final bool isCorrect;
  final String? errorMessage;

  LevelValidationResult({
    required this.isCorrect,
    this.errorMessage,
  });
}
