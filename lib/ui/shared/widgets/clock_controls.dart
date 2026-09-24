import 'package:circuitquest/core/simulation/clock_manager.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/sandbox_mode/view_models/sandbox_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls for the circuit clock: clock mode, ticks between clock highs and
/// a manual trigger button that applies one clock edge.
class ClockControls extends ConsumerWidget {
  const ClockControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sandboxProvider);
    final l10n = AppLocalizations.of(context)!;
    final clockManager = state.clockManager;
    final bool controlsEnabled = !state.isSimulating;

    String modeLabel(ClockMode mode) {
      switch (mode) {
        case ClockMode.disabled:
          return l10n.clockModeDisabled;
        case ClockMode.enabled:
          return l10n.clockModeEnabled;
        case ClockMode.componentUpdate:
          return l10n.clockModeComponentUpdate;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.clockSectionTitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Clock mode dropdown
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ClockMode>(
                initialValue: clockManager.clockMode,
                decoration: InputDecoration(
                  labelText: l10n.clockModeLabel,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: ClockMode.disabled,
                    child: Text(modeLabel(ClockMode.disabled)),
                  ),
                  DropdownMenuItem(
                    value: ClockMode.enabled,
                    child: Text(modeLabel(ClockMode.enabled)),
                  ),
                  DropdownMenuItem(
                    value: ClockMode.componentUpdate,
                    child: Text(modeLabel(ClockMode.componentUpdate)),
                  ),
                ],
                onChanged: controlsEnabled
                    ? (mode) {
                        if (mode != null) {
                          state.setClockMode(mode);
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),

        // Ticks per clock high (only relevant when the clock is active)
        if (clockManager.isEnabled) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.ticksPerClockCycleLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${clockManager.ticksPerClockCycle}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: clockManager.ticksPerClockCycle
                .clamp(1, 16)
                .toDouble(),
            min: 1,
            max: 16,
            divisions: 15,
            label: '${clockManager.ticksPerClockCycle}',
            onChanged: controlsEnabled
                ? (value) => state.setTicksPerClockCycle(value.round())
                : null,
          ),
        ],

        const SizedBox(height: 8),

        // Manual clock trigger
        ElevatedButton.icon(
          onPressed:
              controlsEnabled && clockManager.isEnabled
                  ? state.triggerManualClockUpdate
                  : null,
          icon: const Icon(Icons.update),
          label: Text(l10n.triggerClockUpdate),
        ),
      ],
    );
  }
}
