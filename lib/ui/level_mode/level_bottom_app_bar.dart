import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/levels/level.dart';
import 'package:circuitquest/core/components/component_registry.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:circuitquest/ui/level_mode/level_info_dialog.dart';
import 'package:circuitquest/ui/level_mode/level_component_palette.dart';
import 'package:circuitquest/ui/shared/widgets/component_palette/component_palette.dart';
import 'package:circuitquest/ui/shared/widgets/control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _BottomSheetType { components, controls }

class LevelBottomAppBar extends ConsumerStatefulWidget {
  final Level level;

  LevelBottomAppBar({super.key, required this.level});

  @override
  ConsumerState<LevelBottomAppBar> createState() => _LevelBottomAppBarState();
}

class _LevelBottomAppBarState extends ConsumerState<LevelBottomAppBar> {
  PersistentBottomSheetController? _sheetController;
  _BottomSheetType? _activeSheet;
  late final SandboxState sandboxState;
  bool _isCheckingSolution = false;

  @override
  void initState() {
    super.initState();
    sandboxState = ref.read(sandboxProvider);
  }

  @override
  void dispose() {
    _sheetController?.close();
    super.dispose();
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
            color: _activeSheet == _BottomSheetType.components ? Colors.blue : null,
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
              backgroundColor: sandboxState.isSimulating
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
            color: _activeSheet == _BottomSheetType.controls ? Colors.blue : null,
            icon: Icon(Icons.tune),
          ),
        ],
      ),
    );
  }

  void _showComponentMenu() {
    _toggleBottomSheet(
      type: _BottomSheetType.components,
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
    _toggleBottomSheet(
      type: _BottomSheetType.controls,
      builder: (sheetContext) => SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ControlPanel(level: widget.level),
      ),
    );
  }

  void _toggleBottomSheet({
    required _BottomSheetType type,
    required WidgetBuilder builder,
  }) {
    if (_activeSheet == type && _sheetController != null) {
      _sheetController!.close();
      return;
    }

    _sheetController?.close();

    _sheetController = Scaffold.of(context).showBottomSheet(
      (sheetContext) => SafeArea(
        top: false,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: builder(sheetContext),
          ),
        ),
      ),
      enableDrag: true,
      showDragHandle: true,
    );

    setState(() {
      _activeSheet = type;
    });
    _sheetController!.closed.whenComplete(() {
      if (mounted) {
        setState(() {
          _sheetController = null;
          _activeSheet = null;
        });
      }
    });
  }
}
