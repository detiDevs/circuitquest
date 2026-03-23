import 'package:circuitquest/core/components/input_source.dart';
import 'package:circuitquest/core/components/output_probe.dart';
import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/levels/level.dart';

/// Service for validating circuit solutions against level test cases
class LevelValidator {
  /// Validates a circuit solution by running all test cases
  /// 
  /// Returns a validation result containing whether the solution is correct
  /// and any error details if incorrect.
  static LevelValidationResult validateCircuit(
    List<Component> components,
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

  /// Validates a circuit solution by running simulation for each test case.
  ///
  /// For every test:
  /// - inputs are configured
  /// - optional reset callback is invoked
  /// - simulation callback is awaited
  /// - outputs are verified
  static Future<LevelValidationResult> validateCircuitWithSimulation({
    required List<Component> components,
    required List<LevelTest> tests,
    int? maxComponentCount,
    required Future<void> Function() runSimulation,
    void Function()? resetBeforeTest,
  }) async {
    try {
      final inputSources = <InputSource>[];
      final outputProbes = <OutputProbe>[];

      for (final component in components) {
        if (component is InputSource) {
          inputSources.add(component);
        } else if (component is OutputProbe) {
          outputProbes.add(component);
        }
      }

      if (maxComponentCount != null && components.length > maxComponentCount) {
        return LevelValidationResult(
          isCorrect: false,
          errorMessage: 'Circuit has ${components.length} components, but maximum allowed is $maxComponentCount',
        );
      }

      if (inputSources.isEmpty || outputProbes.isEmpty) {
        return LevelValidationResult(
          isCorrect: false,
          errorMessage: 'Circuit must have inputs and outputs',
        );
      }

      for (int testIndex = 0; testIndex < tests.length; testIndex++) {
        final test = tests[testIndex];

        if (test.inputs.length > inputSources.length) {
          return LevelValidationResult(
            isCorrect: false,
            errorMessage:
                'Test ${testIndex + 1} failed: expected ${inputSources.length} inputs but got ${test.inputs.length}',
          );
        }

        if (test.expectedOutput.length != outputProbes.length) {
          return LevelValidationResult(
            isCorrect: false,
            errorMessage:
                'Test ${testIndex + 1} failed: expected ${outputProbes.length} outputs but got ${test.expectedOutput.length}',
          );
        }

        resetBeforeTest?.call();

        for (int i = 0; i < test.inputs.length; i++) {
          final inputValues = test.inputs[i];
          if (inputValues.isNotEmpty) {
            inputSources[i].setValue(inputValues[0]);
          }
        }

        await runSimulation();

        for (int i = 0; i < test.expectedOutput.length; i++) {
          final expectedValues = test.expectedOutput[i];
          final actualValue = outputProbes[i].value;

          if (expectedValues.isEmpty || expectedValues[0] != actualValue) {
            final expectedText =
                expectedValues.isNotEmpty ? expectedValues[0].toString() : 'N/A';
            return LevelValidationResult(
              isCorrect: false,
              errorMessage:
                  'Test ${testIndex + 1} failed: expected $expectedText but got $actualValue',
            );
          }
        }
      }

      return LevelValidationResult(isCorrect: true);
    } catch (e) {
      return LevelValidationResult(
        isCorrect: false,
        errorMessage: 'Error during validation: $e',
      );
    }
  }

  /// Runs a single test case and returns whether it passed
  static bool _runTestCase(List<Component> components, LevelTest test) {
    // Find all input sources and output probes
    final inputSources = <InputSource>[];
    final outputProbes = <OutputProbe>[];
    
    for (final component in components) {
      if (component is InputSource) {
        inputSources.add(component);
      } else if (component is OutputProbe) {
        outputProbes.add(component);
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
      component.evaluate();
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
