import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BottomAppBar<
  TSheet extends Enum,
  TWidget extends ConsumerStatefulWidget
>
    extends ConsumerState<TWidget> {
  PersistentBottomSheetController? _sheetController;
  TSheet? _activeSheet;

  @protected
  TSheet? get activeSheet => _activeSheet;

  @override
  void dispose() {
    _sheetController?.close();
    super.dispose();
  }

  @protected
  void toggleBottomSheet({
    required TSheet type,
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
