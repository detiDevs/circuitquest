import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:circuitquest/ui/shared/utils/snackbar_utils.dart';
import 'package:circuitquest/ui/shared/widgets/component_palette/component_icon.dart';
import 'package:circuitquest/ui/shared/widgets/component_palette/component_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Individual palette item that can be dragged.
class PaletteItem extends ConsumerWidget {
  final ComponentType componentType;

  const PaletteItem({super.key, required this.componentType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Draggable<ComponentType>(
      data: componentType,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ComponentIcon(
            iconPath: componentType.iconPath,
            isAsset: componentType.isAsset,
            size: 60,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildChild(context, ref, isMobile),
      ),
      child: _buildChild(context, ref, isMobile),
    );
  }

  Widget _buildChild(BuildContext context, WidgetRef ref, bool isMobile) {
    if (isMobile) {
      return _buildMobileChild(context, ref);
    } else {
      return _buildDesktopChild(context, ref);
    }
  }

  Widget _buildMobileChild(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: componentType.displayName,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            ref.read(sandboxProvider).selectComponentType(componentType.name);
            SnackBarUtils.showInfo(
              context,
              AppLocalizations.of(
                context,
              )!.componentSelected(componentType.displayName),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ComponentIcon(
              iconPath: componentType.iconPath,
              isAsset: componentType.isAsset,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopChild(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ComponentIcon(
          iconPath: componentType.iconPath,
          isAsset: componentType.isAsset,
          size: 40,
        ),
        title: Text(
          componentType.displayName,
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () {
          // Select this component type
          ref.read(sandboxProvider).selectComponentType(componentType.name);
          SnackBarUtils.showInfo(
            context,
            AppLocalizations.of(
              context,
            )!.componentSelected(componentType.displayName),
          );
        },
      ),
    );
  }
}
