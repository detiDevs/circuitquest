import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/custom_component_library.dart';
import 'package:circuitquest/ui/shared/utils/snackbar_utils.dart';
import 'package:circuitquest/ui/shared/widgets/component_palette/palette_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomComponentPaletteItem extends PaletteItem {
  const CustomComponentPaletteItem({super.key, required super.componentType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showContextMenu(context, ref, details.globalPosition);
      },
      child: super.build(context, ref),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref, Offset position) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + size.width,
        position.dy + size.height,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(AppLocalizations.of(context)!.delete),
          onTap: () {
            _confirmDelete(context, ref);
          },
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCustomComponent),
        content: Text(
          AppLocalizations.of(context)!.areYouSureYouWantToDeleteX(componentType.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(customComponentProvider)
                  .deleteCustomComponentByName(componentType.name);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  SnackBarUtils.showInfo(
                    context,
                    AppLocalizations.of(context)!.successfullyDeletedX(componentType.name),
                  );
                } else {
                  SnackBarUtils.showError(
                    context,
                    AppLocalizations.of(context)!.failedToDeleteX(componentType.name),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}
