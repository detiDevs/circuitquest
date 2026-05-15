import 'package:circuitquest/data/repositories/custom_component_repository.dart';
import 'package:circuitquest/data/repositories/custom_component_repository_impl.dart';
import 'package:circuitquest/domain/sandbox/sandbox_engine.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/levels/level_validation_result.dart';
import 'package:circuitquest/levels/level_validator.dart';
import 'package:circuitquest/ui/shared/providers/level_providers.dart';
import 'package:circuitquest/ui/shared/utils/text_rendering_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for sandbox state/view model.
final sandboxProvider = ChangeNotifierProvider<SandboxViewModel>(
  (ref) => SandboxViewModel(ref.read(customComponentRepositoryProvider)),
);

/// View model bridging sandbox engine with UI-level behaviors.
class SandboxViewModel extends SandboxEngine {
  SandboxViewModel(CustomComponentRepository repository) : super(repository);

  Future<void> checkLevelSolution(
    BuildContext context,
    WidgetRef ref,
    Level level,
  ) async {
    try {
      final validationResult =
          await LevelValidator.validateCircuitWithSimulation(
            components: placedComponents.map((pc) => pc.component).toList(),
            tests: level.tests,
            maxComponentCount: level.maxComponentCount,
            resetBeforeTest: resetSimulation,
            runSimulation: startSimulation,
          );

      if (!context.mounted) return;

      if (validationResult.isCorrect) {
        await markLevelCompleted(ref, level.levelId);

        if (!context.mounted) return;

        showDialog(
          context: context,
          builder: (context) {
            final localeCode = Localizations.localeOf(context).languageCode;
            final message = level.getLocalizedString(
              'success_message',
              localeCode,
            );

            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.success),
              content: TextRenderingUtils.renderMaybeMath(
                context,
                message != ''
                    ? message
                    : AppLocalizations.of(context)!.allTestsPassedMessage,
                null,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.continue_,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        final message = _validationFailureMessage(context, validationResult);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.testFailed),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.tryAgain),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error checking solution: $e')));
      }
    }
  }

  String _validationFailureMessage(
    BuildContext context,
    LevelValidationResult result,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (result is NumberOfComponentsMismatch) {
      return l10n.validationTooManyComponents(
        result.actual,
        result.expectedMax,
      );
    }

    if (result is MissingInputsOrOutputs) {
      return l10n.validationMissingInputsOutputs(
        result.inputCount,
        result.outputCount,
      );
    }

    if (result is NumberOfInputsMismatch) {
      return l10n.validationInputCountMismatch(
        result.testIndex + 1,
        result.expected,
        result.actual,
      );
    }

    if (result is NumberOfOutputsMismatch) {
      return l10n.validationOutputCountMismatch(
        result.testIndex + 1,
        result.expected,
        result.actual,
      );
    }

    if (result is TestFailed) {
      if (result.expectedOutput < 0 || result.actualOutput < 0) {
        return l10n.testFailedDescription;
      }

      final inputsText = result.failedInputConfiguration.isNotEmpty
          ? result.failedInputConfiguration
              .map(
                (entry) =>
                    '${_labelForComponentId(entry.componentId) ?? l10n.validationInputIdLabel(entry.componentId)}=${entry.value}',
              )
              .join(', ')
          : l10n.validationInputsUnknown;

      final outputLabel =
          _labelForComponentId(result.outputComponentId) ??
          l10n.validationOutputIdLabel(result.outputComponentId);

      return l10n.validationTestFailed(
        result.testIndex + 1,
        outputLabel,
        result.expectedOutput,
        result.actualOutput,
        inputsText,
      );
    }

    return l10n.testFailedDescription;
  }

  String? _labelForComponentId(int componentId) {
    for (final placed in placedComponents) {
      if (placed.component.id == componentId) {
        return placed.label;
      }
    }
    return null;
  }
}
