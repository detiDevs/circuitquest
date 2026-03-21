import 'package:circuitquest/core/components/component_registry.dart';
import 'package:circuitquest/core/components/custom_component.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/custom_component_library.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:circuitquest/ui/shared/widgets/circuit_file_manager.dart';
import 'package:circuitquest/ui/shared/widgets/component_palette/component_palette.dart';
import 'package:circuitquest/ui/shared/widgets/control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuitquest/ui/shared/widgets/bottom_app_bar.dart'
    as shared_bottom_app_bar;

enum _SandboxBottomSheetType { components, customComponents, file, controls }

class SandboxBottomAppBar extends ConsumerStatefulWidget {
  const SandboxBottomAppBar({super.key});

  @override
  ConsumerState<SandboxBottomAppBar> createState() =>
      _SandboxBottomAppBarState();
}

class _SandboxBottomAppBarState
    extends
        shared_bottom_app_bar.BottomAppBar<
          _SandboxBottomSheetType,
          SandboxBottomAppBar
        > {
  late final SandboxState sandboxState;
  late final CustomComponentLibrary ccl;

  @override
  void initState() {
    super.initState();
    sandboxState = ref.read(sandboxProvider);
    ccl = ref.read(customComponentProvider);
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            tooltip: "Components",
            onPressed: _showComponents,
            color: activeSheet == _SandboxBottomSheetType.components
                ? Colors.blue
                : null,
            icon: Icon(Icons.extension),
          ),
          Spacer(),
          IconButton(
            tooltip: "Custom Components",
            onPressed: _showCustomComponents,
            color: activeSheet == _SandboxBottomSheetType.customComponents
                ? Colors.blue
                : null,
            icon: Icon(Icons.person),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: _toggleSimulation,
            style: ElevatedButton.styleFrom(
              backgroundColor: sandboxState.isSimulating
                  ? Colors.orange
                  : Colors.green,
              iconColor: Colors.white,
              shape: CircleBorder(),
            ),
            child: Icon(
              sandboxState.isSimulating ? Icons.pause : Icons.play_arrow,
            ),
          ),
          Spacer(),
          IconButton(
            tooltip: "File Operations",
            onPressed: _showFileOperations,
            color: activeSheet == _SandboxBottomSheetType.file
                ? Colors.blue
                : null,
            icon: Icon(Icons.save),
          ),
          Spacer(),
          IconButton(
            tooltip: "Controls",
            onPressed: _showControls,
            color: activeSheet == _SandboxBottomSheetType.controls
                ? Colors.blue
                : null,
            icon: Icon(Icons.tune),
          ),
        ],
      ),
    );
  }

  void _showComponents() {
    toggleBottomSheet(
      type: _SandboxBottomSheetType.components,
      builder: (context) => buildResponsiveComponentList(
        context,
        components: availableComponents,
        headerText: AppLocalizations.of(context)!.availableComponents,
      ),
    );
  }

  void _showCustomComponents() {
    toggleBottomSheet(
      type: _SandboxBottomSheetType.customComponents,
      builder: (context) {
        final components = ccl.components
            .map(
              (entry) => ComponentType(
                name: entry.data.name,
                displayName: entry.data.name,
                iconPath: entry.spritePath ?? '',
                isAsset: false,
                createComponent: () => CustomComponent(entry.data),
              ),
            )
            .toList();
        return buildResponsiveComponentList(
          context,
          components: components,
          headerText: AppLocalizations.of(context)!.customComponents,
          custom: true,
        );
      },
    );
  }

  void _toggleSimulation() {
    if (sandboxState.isSimulating) {
      sandboxState.pauseSimulation();
    } else {
      sandboxState.startSimulation();
    }
  }

  void _showFileOperations() {
    toggleBottomSheet(
      type: _SandboxBottomSheetType.file,
      builder: (context) => CircuitFileManager(),
    );
  }

  void _showControls() {
    toggleBottomSheet(
      type: _SandboxBottomSheetType.controls,
      builder: (context) => ControlPanel(),
    );
  }
}
