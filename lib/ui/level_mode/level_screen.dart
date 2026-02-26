import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/shared/widgets/expandable_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/levels/levels.dart';
import 'package:circuitquest/constants.dart';
import '../shared/widgets/component_palette/component_palette.dart';
import '../shared/widgets/circuit_canvas/circuit_canvas.dart';
import '../shared/widgets/control_panel.dart';
import '../../state/sandbox_state.dart';
import '../../core/commands/command_controller.dart';
import './level_info_dialog.dart';

/// Screen for playing a specific level.
///
/// This screen displays:
/// - Circuit canvas with grid
/// - Limited component palette (only components available for the level)
/// - Control panel for simulation
/// - Level info accessible via dialog and FAB
class LevelScreen extends ConsumerStatefulWidget {
  final Level level;

  const LevelScreen({super.key, required this.level});

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    // Show level info dialog on first entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dialogShown && mounted) {
        _showLevelInfoDialog();
        _dialogShown = true;
      }
    });
  }

  @override
  void dispose() {
    // Clear undo/redo stacks when leaving level
    CommandController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sandboxState = ref.watch(sandboxProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${Constants.kAppName} - ${widget.level.name}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          // Undo button
          IconButton(
            onPressed: sandboxState.canUndo ? sandboxState.undo : null,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
          ),
          // Redo button
          IconButton(
            onPressed: sandboxState.canRedo ? sandboxState.redo : null,
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
          ),
        ],
      ),
      body: _LevelScreenBody(level: widget.level),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLevelInfoDialog,
        tooltip: AppLocalizations.of(context)!.levelInformationTooltip,
        child: const Icon(Icons.info),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  void _showLevelInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => LevelInfoDialog(level: widget.level),
    );
  }
}

/// Main body of the level screen with responsive layout.
class _LevelScreenBody extends StatelessWidget {
  final Level level;

  const _LevelScreenBody({required this.level});

  @override
  Widget build(BuildContext context) {
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
                  child: _LimitedComponentPalette(level: level),
                ),
              ),
              // Center: Circuit Canvas
              Expanded(
                child: CircuitCanvas(level: level),
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
                  child: ControlPanel(level: level),
                ),
              ),
            ],
          );
        } else {
          // Mobile layout: Vertical stack with collapsible sections
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
                  title: Text(AppLocalizations.of(context)!.availableComponents),
                  controlAffinity: ListTileControlAffinity.leading,
                  initiallyExpanded: false,
                  children: [
                    SizedBox(
                      height: 200,
                      child: _LimitedComponentPalette(level: level),
                    ),
                  ],
                ),
              ),
              // Canvas takes remaining space
              Expanded(
                child: CircuitCanvas(level: level),
              ),
              // Control panel at bottom
              ExpandableControlPanel(level: level),
            ],
          );
        }
      },
    );
  }
}

/// Component palette limited to components available for this level.
class _LimitedComponentPalette extends ConsumerWidget {
  final Level level;

  const _LimitedComponentPalette({required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter available components based on level requirements
    final limitedComponents = availableComponents.where((comp) {
      return level.availableComponents.any((ac) => ac.type == comp.name);
    }).toList();

    // Reuse the responsive component list builder from component_palette.dart
    return buildResponsiveComponentList(
      context,
      components: limitedComponents,
      headerText: AppLocalizations.of(context)!.availableComponents,
    );
  }
}
