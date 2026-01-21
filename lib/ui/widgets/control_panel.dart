import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/sandbox_state.dart';

/// Control panel for circuit simulation and evaluation.
///
/// Provides controls for:
/// - Evaluating the circuit
/// - Starting/stopping simulation
/// - Clearing the circuit
/// - Viewing circuit state
class ControlPanel extends ConsumerWidget {
  const ControlPanel({super.key});

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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      const Divider(height: 1),
      
      // Control buttons
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Evaluate button
            ElevatedButton.icon(
              onPressed: state.placedComponents.isEmpty
                  ? null
                  : () {
                      state.evaluateCircuit();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.circuitEvaluated),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
              icon: const Icon(Icons.play_arrow),
              label: Text(AppLocalizations.of(context)!.evaluateCircuit),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Simulation toggle
            ElevatedButton.icon(
              onPressed: state.placedComponents.isEmpty
                  ? null
                  : () {
                      if (state.isSimulating) {
                        state.stopSimulation();
                      } else {
                        state.startSimulation();
                      }
                    },
              icon: Icon(
                state.isSimulating ? Icons.stop : Icons.autorenew,
              ),
              label: Text(
                state.isSimulating 
                    ? AppLocalizations.of(context)!.stopSimulation 
                    : AppLocalizations.of(context)!.startSimulation,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    state.isSimulating ? Colors.orange : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Clear button
            OutlinedButton.icon(
              onPressed: state.placedComponents.isEmpty
                  ? null
                  : () {
                      _showClearConfirmation(context, state);
                    },
              icon: const Icon(Icons.delete_outline),
              label: Text(AppLocalizations.of(context)!.clearCircuit),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                  Icon(Icons.info_outline, 
                    size: 16, 
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.pinColorsInfo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[900],
                      ),
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

  /// Shows a confirmation dialog before clearing the circuit.
  void _showClearConfirmation(BuildContext context, SandboxState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearCircuitConfirmTitle),
        content: Text(
          AppLocalizations.of(context)!.clearCircuitConfirmMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              state.clearCircuit();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.circuitCleared),
                  duration: const Duration(seconds: 1),
                ),
              );
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

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
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

  const _InstructionItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
