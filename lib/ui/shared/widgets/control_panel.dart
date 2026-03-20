import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/sandbox_state.dart';
import '../../../levels/levels.dart';
import 'circuit_file_manager.dart';

/// Control panel for circuit simulation and evaluation.
///
/// Provides controls for:
/// - Evaluating the circuit
/// - Starting/stopping simulation
/// - Clearing the circuit
/// - Viewing circuit state
class ControlPanel extends ConsumerWidget {
  const ControlPanel({super.key, this.isSandbox = false, this.level});

  /// When true, shows sandbox-only controls like save/load circuit.
  final bool isSandbox;

  /// The current level being played (if in level mode).
  final Level? level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sandboxProvider);

    // Build content as a list
    final content = [
      // Header
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          AppLocalizations.of(context)!.controlsTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      const Divider(height: 1),

      // Control buttons
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Play/Pause simulation button
            ElevatedButton.icon(
              onPressed: state.placedComponents.isEmpty
                  ? null
                  : () {
                      if (state.isSimulating) {
                        state.pauseSimulation();
                      } else {
                        state.startSimulation();
                      }
                    },
              icon: Icon(state.isSimulating ? Icons.pause : Icons.play_arrow),
              label: Text(
                state.isSimulating
                    ? AppLocalizations.of(context)!.stopSimulation
                    : AppLocalizations.of(context)!.startSimulation,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isSimulating
                    ? Colors.orange
                    : Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Speed slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.simulationSpeed,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getSpeedDisplayValue(state.tickSpeed) == 0
                          ? AppLocalizations.of(context)!.simulationSpeedInstant
                          : '${_getSpeedDisplayValue(state.tickSpeed).toStringAsFixed(0)} tick/s',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Slider(
                  value: _getSliderValue(state.tickSpeed),
                  min: 1,
                  max: 11,
                  divisions: 10,
                  label: _getSpeedDisplayValue(state.tickSpeed) == 0
                      ? AppLocalizations.of(context)!.simulationSpeedInstant
                      : '${_getSpeedDisplayValue(state.tickSpeed).toStringAsFixed(0)} tick/s',
                  onChanged: (value) {
                    state.setTickSpeed(_getTickSpeedFromSlider(value));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1 tick/s',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    Text(
                      '5 tick/s',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    Text(
                      AppLocalizations.of(context)!.simulationSpeedInstant,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reset button (only show if simulation was paused)
            if (state.canReset) ...[
              OutlinedButton.icon(
                onPressed: () {
                  state.resetSimulation();
                  SnackBarUtils.showInfo(
                    context,
                    AppLocalizations.of(context)!.circuitWasResetToInitialState,
                  );
                },
                icon: const Icon(Icons.restore),
                label: Text(
                  AppLocalizations.of(context)!.resetCircuitToInitialState,
                ),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
              ),
              const SizedBox(height: 8),
            ],

            // Check Solution button (level mode only)
            if (!isSandbox && level != null) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: state.placedComponents.isEmpty
                    ? null
                    : () => state.checkLevelSolution(context, ref, level!),
                icon: const Icon(Icons.check_circle),
                label: Text(AppLocalizations.of(context)!.checkSolution),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (isSandbox) ...[
              const Divider(),
              const SizedBox(height: 8),

              // File operations (sandbox only)
              Text(
                AppLocalizations.of(context)!.fileOperationsTitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const CircuitFileManager(),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
            ],

            // Clear button
            OutlinedButton.icon(
              onPressed: state.placedComponents.isEmpty
                  ? null
                  : () {
                      _showClearConfirmation(context, state);
                    },
              icon: const Icon(Icons.delete_outline),
              label: Text(AppLocalizations.of(context)!.clearCircuit),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),

      const Divider(),

      // Circuit info
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.circuitInfoTitle,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: AppLocalizations.of(context)!.componentsLabel,
              value: '${state.placedComponents.length}',
            ),
            _InfoRow(
              label: AppLocalizations.of(context)!.connectionsLabel,
              value: '${state.connections.length}',
            ),
            _InfoRow(
              label: AppLocalizations.of(context)!.statusLabel,
              value: state.isSimulating
                  ? AppLocalizations.of(context)!.statusRunning
                  : AppLocalizations.of(context)!.statusStopped,
              valueColor: state.isSimulating ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),

      const Divider(),

      // Instructions
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.instructionsTitle,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _InstructionItem(
              icon: Icons.touch_app,
              text: AppLocalizations.of(context)!.instructionDragComponents,
            ),
            _InstructionItem(
              icon: Icons.pan_tool,
              text: AppLocalizations.of(context)!.instructionMoveComponents,
            ),
            _InstructionItem(
              icon: Icons.cable,
              text: AppLocalizations.of(context)!.instructionStartWires,
            ),
            _InstructionItem(
              icon: Icons.touch_app,
              text: AppLocalizations.of(context)!.instructionCompleteWires,
            ),
            _InstructionItem(
              icon: Icons.delete,
              text: AppLocalizations.of(context)!.instructionDeleteComponents,
            ),
            _InstructionItem(
              icon: Icons.play_arrow,
              text: AppLocalizations.of(context)!.instructionEvaluate,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.pinColorsInfo,
                      style: TextStyle(fontSize: 11, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: content,
        ),
      ),
    );
  }

  /// Converts tick speed to slider value (1-11, where 11 is instant)
  double _getSliderValue(double tickSpeed) {
    if (tickSpeed == 0) return 11; // Instant
    return tickSpeed.clamp(1, 10);
  }

  /// Converts slider value to tick speed (0 for instant, 1-10 for ticks/s)
  double _getTickSpeedFromSlider(double sliderValue) {
    if (sliderValue == 11) return 0; // Instant
    return sliderValue.clamp(1, 10);
  }

  /// Gets display value for speed (0 for instant, 1-10 for ticks/s)
  double _getSpeedDisplayValue(double tickSpeed) {
    return tickSpeed;
  }

  /// Shows a confirmation dialog before clearing the circuit.
  void _showClearConfirmation(BuildContext context, SandboxState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearCircuitConfirmTitle),
        content: Text(AppLocalizations.of(context)!.clearCircuitConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              state.clearCircuit();
              Navigator.of(context).pop();
              SnackBarUtils.showInfo(context, AppLocalizations.of(context)!.circuitCleared);
            },
            child: Text(
              AppLocalizations.of(context)!.clear,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display an info row.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display an instruction item.
class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
