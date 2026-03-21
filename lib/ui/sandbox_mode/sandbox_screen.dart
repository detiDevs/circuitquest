import 'package:circuitquest/constants.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/sandbox_mode/sandbox_bottom_app_bar.dart';
import 'package:circuitquest/ui/sandbox_mode/desktop_sandbox_component_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final bool isMobile = MediaQuery.of(context).size.width < Constants.kMobileThreshold;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sandboxModeTitle),
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
      bottomNavigationBar: isMobile ? SandboxBottomAppBar(): null,
    );
  }
}

/// The main body of the sandbox screen with responsive layout.
class _SandboxBody extends StatelessWidget {
  const _SandboxBody();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < Constants.kMobileThreshold;

    // Use LayoutBuilder to determine responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {

        if (!isMobile) {
          // Desktop layout: Canvas with overlaid palette and controls
          return Stack(
            children: [
              const Positioned.fill(
                child: CircuitCanvas(),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight - 32),
                  child: const SizedBox(
                    width: 220,
                    child: DesktopSandboxComponentPalette(),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight - 32),
                  child: SizedBox(
                    width: 300,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: const ControlPanel(isSandbox: true),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile layout: only canvas, rest is done by bottom app bar
          return Column(
            children: [
              const Expanded(
                child: CircuitCanvas(),
              ),
            ],
          );
        }
      },
    );
  }
}
