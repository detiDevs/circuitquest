import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:circuitquest/ui/level_mode/level_info_dialog.dart';
import 'package:circuitquest/ui/level_mode/level_component_palette.dart';
import 'package:circuitquest/ui/shared/widgets/bottom_app_bar.dart'
    as shared_bottom_app_bar;
import 'package:circuitquest/ui/shared/widgets/control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _LevelBottomSheetType { components, controls }

class LevelBottomAppBar extends ConsumerStatefulWidget {
  final Level level;

  LevelBottomAppBar({super.key, required this.level});

  @override
  ConsumerState<LevelBottomAppBar> createState() => _LevelBottomAppBarState();
}

class _LevelBottomAppBarState
    extends
        shared_bottom_app_bar.BottomAppBar<
          _LevelBottomSheetType,
          LevelBottomAppBar
        > {
  late final SandboxState sandboxState;
  bool _isCheckingSolution = false;

  @override
  void initState() {
    super.initState();
    sandboxState = ref.read(sandboxProvider);
  }

  @override
  Widget build(BuildContext context) {
    final sandboxState = ref.watch(sandboxProvider);
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.componentsLabel,
            onPressed: _showComponentMenu,
            color: activeSheet == _LevelBottomSheetType.components
                ? Colors.blue
                : null,
            icon: Icon(Icons.extension),
          ),
          Spacer(),
          IconButton(
            tooltip: sandboxState.isSimulating
                ? AppLocalizations.of(context)!.stopSimulation
                : AppLocalizations.of(context)!.startSimulation,
            onPressed: _toggleSimulation,
            color: sandboxState.isSimulating ? Colors.orange : Colors.green,
            icon: Icon(
              sandboxState.isSimulating ? Icons.pause : Icons.play_arrow,
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: _checkSolution,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCheckingSolution
                  ? Colors.grey
                  : Colors.purple,
              iconColor: Colors.white,
              shape: CircleBorder(),
            ),
            child: Icon(Icons.check),
          ),
          Spacer(),
          IconButton(
            tooltip: AppLocalizations.of(context)!.levelInformationTooltip,
            onPressed: _showLevelInfoDialog,
            icon: Icon(Icons.info),
          ),
          Spacer(),
          IconButton(
            tooltip: AppLocalizations.of(context)!.controlsTitle,
            onPressed: _showControlMenu,
            color: activeSheet == _LevelBottomSheetType.controls
                ? Colors.blue
                : null,
            icon: Icon(Icons.tune),
          ),
        ],
      ),
    );
  }

  void _showComponentMenu() {
    toggleBottomSheet(
      type: _LevelBottomSheetType.components,
      builder: (sheetContext) => SizedBox(
        width: MediaQuery.of(context).size.width,
        child: LevelComponentPalette(level: widget.level),
      ),
    );
  }

  void _toggleSimulation() {
    if (sandboxState.isSimulating) {
      sandboxState.pauseSimulation();
    } else {
      sandboxState.startSimulation();
    }
  }

  void _checkSolution() async {
    _isCheckingSolution = true;
    sandboxState.checkLevelSolution(context, ref, widget.level);
    _isCheckingSolution = false;
  }

  void _showLevelInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => LevelInfoDialog(level: widget.level),
    );
  }

  void _showControlMenu() {
    toggleBottomSheet(
      type: _LevelBottomSheetType.controls,
      builder: (sheetContext) => SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ControlPanel(level: widget.level),
      ),
    );
  }
}
