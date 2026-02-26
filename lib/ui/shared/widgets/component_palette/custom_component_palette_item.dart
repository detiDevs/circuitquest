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
          child: const Text('Delete'),
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
        title: const Text('Delete Custom Component'),
        content: Text(
          'Are you sure you want to delete "${componentType.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    '${componentType.name} deleted successfully',
                  );
                } else {
                  SnackBarUtils.showError(
                    context,
                    'Failed to delete ${componentType.name}',
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
