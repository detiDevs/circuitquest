/// Result of level validation
abstract class LevelValidationResult {
  final bool isCorrect;

  const LevelValidationResult({required this.isCorrect});
}

class ValidationSuccess extends LevelValidationResult {
  const ValidationSuccess() : super(isCorrect: true);
}

class NumberOfComponentsMismatch extends LevelValidationResult {
  final int expectedMax;
  final int actual;

  const NumberOfComponentsMismatch({
    required this.expectedMax,
    required this.actual,
  }) : super(isCorrect: false);
}

class MissingInputsOrOutputs extends LevelValidationResult {
  final int inputCount;
  final int outputCount;

  const MissingInputsOrOutputs({
    required this.inputCount,
    required this.outputCount,
  }) : super(isCorrect: false);
}

class NumberOfInputsMismatch extends LevelValidationResult {
  final int testIndex;
  final int expected;
  final int actual;

  const NumberOfInputsMismatch({
    required this.testIndex,
    required this.expected,
    required this.actual,
  }) : super(isCorrect: false);
}

class NumberOfOutputsMismatch extends LevelValidationResult {
  final int testIndex;
  final int expected;
  final int actual;

  const NumberOfOutputsMismatch({
    required this.testIndex,
    required this.expected,
    required this.actual,
  }) : super(isCorrect: false);
}

class FailedInputConfigurationEntry {
  final int componentId;
  final int value;

  const FailedInputConfigurationEntry({
    required this.componentId,
    required this.value,
  });
}

class TestFailed extends LevelValidationResult {
  final int testIndex;
  final int outputIndex;
  final int outputComponentId;
  final int expectedOutput;
  final int actualOutput;

  // The input configuration that led to the test failure.
  // Includes component id and value.
  final List<FailedInputConfigurationEntry> failedInputConfiguration;

  const TestFailed({
    required this.testIndex,
    required this.outputIndex,
    required this.outputComponentId,
    required this.expectedOutput,
    required this.actualOutput,
    required this.failedInputConfiguration,
  }) : super(isCorrect: false);
}