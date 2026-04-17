import 'package:circuitquest/core/components/input_source.dart';
import 'package:circuitquest/core/components/output_probe.dart';
import 'package:circuitquest/core/components/base/component.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/levels/level_validation_result.dart';

/// Service for validating circuit solutions against level test cases
class LevelValidator {


  /// Validates a circuit solution by running simulation for each test case.
  ///
  /// For every test:
  /// - inputs are configured
  /// - optional reset callback is invoked
  /// - simulation callback is awaited
  /// - outputs are verified
  static Future<NumberOfComponentsMismatch> validateCircuitWithSimulation({
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
        return NumberOfComponentsMismatch(
          expectedMax: maxComponentCount,
          actual: components.length,
        );
      }

      if (inputSources.isEmpty || outputProbes.isEmpty) {
        return MissingInputsOrOutputs(
          inputCount: inputSources.length,
          outputCount: outputProbes.length,
        );
      }

      for (int testIndex = 0; testIndex < tests.length; testIndex++) {
        final test = tests[testIndex];

        if (test.inputs.length > inputSources.length) {
          return NumberOfInputsMismatch(
            testIndex: testIndex,
            expected: inputSources.length,
            actual: test.inputs.length,
          );
        }
        if (test.expectedOutput.isEmpty) {
      return ValidationSuccess() // No expected outputs means we only care about successful evaluation or we just want to reach a known state of sequential components
    }
print(test.expectedOutput);
        if (test.expectedOutput.length != outputProbes.length && test.expectedOutput.isNotEmpty) {
          
          return NumberOfOutputsMismatch(
            testIndex: testIndex,
            expected: outputProbes.length,
            actual: test.expectedOutput.length,
          );
        }

        resetBeforeTest?.call();

        for (int i = 0; i < test.inputs.length; i++) {
          final inputValues = test.inputs[i];
          if (inputValues.isNotEmpty) {
            inputSources[i].value = inputValues[0];
          }
        }

        await runSimulation();

        for (int i = 0; i < test.expectedOutput.length; i++) {
          final expectedValues = test.expectedOutput[i];
          final outputProbe = outputProbes[i];
          final actualValue = outputProbe.value;

          if (expectedValues.isEmpty || expectedValues[0] != actualValue) {
            final expectedValue =
                expectedValues.isNotEmpty ? expectedValues[0] : -1;
            return TestFailed(
              testIndex: testIndex,
              outputIndex: i,
              outputComponentId: outputProbe.id,
              expectedOutput: expectedValue,
              actualOutput: actualValue,
              failedInputConfiguration: _buildFailedInputConfiguration(
                inputSources,
              ),
            );
          }
        }
      }

      return const ValidationSuccess();
    } catch (e) {
      return const TestFailed(
        testIndex: 0,
        outputIndex: 0,
        outputComponentId: -1,
        expectedOutput: -1,
        actualOutput: -1,
        failedInputConfiguration: [],
      );
    }
  }

  /// Runs a single test case and returns whether it passed


  static List<FailedInputConfigurationEntry> _buildFailedInputConfiguration(
    List<InputSource> inputSources,
  ) {
    return inputSources
        .map(
          (input) => FailedInputConfigurationEntry(
            componentId: input.id,
            value: input.value,
          ),
        )
        .toList();
  }
}

