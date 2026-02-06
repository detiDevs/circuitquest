import 'package:circuitquest/constants.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/widgets/expandable_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/component_palette.dart';
import '../widgets/circuit_canvas.dart';
import '../widgets/control_panel.dart';

/// Main sandbox screen where users can design and simulate circuits.
///
/// This screen provides:
/// - A component palette for selecting components to place
/// - A grid-based canvas for placing and connecting components
/// - Control panel for circuit evaluation and simulation
///
/// The layout adapts for mobile (vertical) and desktop (horizontal) layouts.
class SandboxScreen extends ConsumerWidget {
  const SandboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${Constants.kAppName} - ${AppLocalizations.of(context)!.sandboxModeTitle}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
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
                    color: Colors.grey[100],
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
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
                    color: Colors.grey[100],
                    border: Border(
                      left: BorderSide(color: Colors.grey[300]!),
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
                    bottom: BorderSide(color: Colors.grey[300]!),
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
