import 'package:circuitquest/ui/level_mode/level_bottom_app_bar.dart';
import 'package:circuitquest/ui/level_mode/level_component_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/levels/levels.dart';
import 'package:circuitquest/constants.dart';
import '../shared/widgets/circuit_canvas/circuit_canvas.dart';
import '../shared/widgets/control_panel.dart';
import '../../state/sandbox_state.dart';
import '../../state/level_state.dart';
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

      // Initialize clock for this level
      initializeLevelClock(ref, widget.level);
    });
  }

  @override
  void dispose() {
    // Clear undo/redo stacks when leaving level
    CommandController.clear();

    // Reset level clock
    resetLevelClock(ref);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sandboxState = ref.watch(sandboxProvider);
    final isMobile = MediaQuery.of(context).size.width < Constants.kMobileThreshold;

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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _checkSolution(sandboxState),
      //   tooltip: AppLocalizations.of(context)!.checkSolution,
      //   backgroundColor: _isCheckingSolution ? Colors.grey : Colors.purple,
      //   foregroundColor: Colors.white,
      //   shape: CircleBorder(),
      //   child: Icon(Icons.check),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isMobile ? LevelBottomAppBar(level: widget.level) : null,
    );
  }

  // void _checkSolution(SandboxState sandboxState) async {
  //   _isCheckingSolution = true;
  //   await sandboxState.checkLevelSolution(context, ref, widget.level);
  //   _isCheckingSolution = false;
  // }

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
    final isMobile = MediaQuery.of(context).size.width < Constants.kMobileThreshold;
    return LayoutBuilder(
      builder: (context, constraints) {

        if (!isMobile) {
          // Desktop layout: Palette on left, Canvas in center, Controls on right
          return Row(
            children: [
              // Left panel: Component Palette
              SizedBox(
                width: 200,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  child: LevelComponentPalette(level: level),
                ),
              ),
              // Center: Circuit Canvas
              Expanded(child: CircuitCanvas(level: level)),
              // Right panel: Control Panel
              SizedBox(
                width: 250,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
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
              // Canvas takes all body space, everything else is handled by bottom app bar
              Expanded(child: CircuitCanvas(level: level)),
            ],
          );
        }
      },
    );
  }
}

