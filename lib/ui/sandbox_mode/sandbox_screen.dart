import 'package:circuitquest/constants.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/shared/widgets/expandable_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/widgets/component_palette/component_palette.dart';
import '../shared/widgets/circuit_canvas/circuit_canvas.dart';
import '../shared/widgets/control_panel.dart';
import '../../state/sandbox_state.dart';
import '../../core/commands/command_controller.dart';

/// Main sandbox screen where users can design and simulate circuits.
///
/// This screen provides:
/// - A component palette for selecting components to place
/// - A grid-based canvas for placing and connecting components
/// - Control panel for circuit evaluation and simulation
///
/// The layout adapts for mobile (vertical) and desktop (horizontal) layouts.
class SandboxScreen extends ConsumerStatefulWidget {
  const SandboxScreen({super.key});

  @override
  ConsumerState<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends ConsumerState<SandboxScreen> {
  @override
  void dispose() {
    // Clear undo/redo stacks when leaving sandbox
    CommandController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sandboxState = ref.watch(sandboxProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${Constants.kAppName} - ${AppLocalizations.of(context)!.sandboxModeTitle}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          // Undo Button
          IconButton(
            onPressed: sandboxState.canUndo ? () => sandboxState.undo() : null,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
          ),
          // Redo Button
          IconButton(
            onPressed: sandboxState.canRedo ? () => sandboxState.redo() : null,
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const _SandboxBody(),
    );
  }
}

/// The main body of the sandbox screen with responsive layout.
class _SandboxBody extends StatelessWidget {
  const _SandboxBody();

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to determine responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          // Desktop layout: Palette on left, Canvas in center, Controls on right
          return Row(
            children: [
              // Left panel: Component Palette
              SizedBox(
                width: 200,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  child: const ComponentPalette(),
                ),
              ),
              // Center: Circuit Canvas
              const Expanded(
                child: CircuitCanvas(),
              ),
              // Right panel: Control Panel
              SizedBox(
                width: 250,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  child: const ControlPanel(isSandbox: true),
                ),
              ),
            ],
          );
        } else {
          // Mobile layout: Vertical stack with tabs for palette
          return Column(
            children: [
              // Collapsible palette at top
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
                child: ExpansionTile(
                  title: const Text('Components'),
                  initiallyExpanded: false,
                  children: const [
                    SizedBox(
                      height: 200,
                      child: ComponentPalette(),
                    ),
                  ],
                ),
              ),
              // Canvas takes remaining space
              const Expanded(
                child: CircuitCanvas(),
              ),
              // Control panel at bottom
              const ExpandableControlPanel(isSandbox: true,),
            ],
          );
        }
      },
    );
  }
}
