import 'package:circuitquest/domain/models/level.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/ui/level_mode/view_models/level_mode_view_model.dart';
import 'package:circuitquest/ui/level_mode/widgets/level_bottom_app_bar.dart';
import 'package:circuitquest/ui/level_mode/widgets/level_component_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/constants.dart';
import '../../shared/widgets/circuit_canvas/circuit_canvas.dart';
import '../../shared/widgets/control_panel.dart';
import 'package:circuitquest/ui/sandbox_mode/view_models/sandbox_view_model.dart';
import 'package:circuitquest/ui/shared/providers/level_providers.dart';
import '../../../domain/commands/command_controller.dart';
import 'level_info_dialog.dart';

/// Screen for playing a specific level.
///
/// This screen displays:
/// - Circuit canvas with grid
/// - Limited component palette (only components available for the level)
/// - Control panel for simulation
/// - Level info accessible via dialog and FAB
class LevelScreen extends ConsumerStatefulWidget {
  final int levelId;

  LevelScreen({super.key, required this.levelId});

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen> {
  bool _dialogShown = false;
  late final Future<Level> _levelFuture;

  @override
  void initState() {
    super.initState();

    final viewModel = ref.read(levelModeViewModelProvider);
    _levelFuture = viewModel.loadLevel(widget.levelId);
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
    final isMobile =
        MediaQuery.of(context).size.width < Constants.kMobileThreshold;

    return FutureBuilder<Level>(
      future: _levelFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Level'),
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Text(
                'Failed to load level.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading level...'),
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final level = snapshot.requireData;

        if (!_dialogShown) {
          _dialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showLevelInfoDialog(level);
            initializeLevelClock(ref, level);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(level.name),
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
          body: _LevelScreenBody(level: level),
          floatingActionButton: isMobile
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showLevelInfoDialog(level),
                  label: Text(
                    AppLocalizations.of(context)!.levelInformationTooltip,
                  ),
                  icon: Icon(Icons.info),
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: isMobile ? LevelBottomAppBar(level: level) : null,
        );
      },
    );
  }

  void _showLevelInfoDialog(Level level) {
    showDialog(
      context: context,
      builder: (context) => LevelInfoDialog(level: level),
    );
  }
}

/// Main body of the level screen with responsive layout.
class _LevelScreenBody extends StatelessWidget {
  final Level level;

  const _LevelScreenBody({required this.level});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < Constants.kMobileThreshold;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!isMobile) {
          // Desktop layout: Canvas with overlaid component and control panels
          return Stack(
            children: [
              Positioned.fill(child: CircuitCanvas(level: level)),
              Positioned(
                top: 16,
                left: 16,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight - 32,
                  ),
                  child: SizedBox(
                    width: 220,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: LevelComponentPalette(level: level),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight - 32,
                  ),
                  child: SizedBox(
                    width: 300,
                    child: Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: ControlPanel(level: level),
                    ),
                  ),
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
