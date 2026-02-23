import 'dart:io';
import 'package:circuitquest/core/commands/command_controller.dart';
import 'package:circuitquest/core/commands/move_component_command.dart';
import 'package:circuitquest/core/commands/remove_component_command.dart';
import 'package:circuitquest/core/commands/remove_connection_command.dart';
import 'package:circuitquest/core/components/custom_component.dart';
import 'package:circuitquest/core/components/input_source.dart';
import 'package:circuitquest/core/components/output_probe.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/custom_component_library.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:circuitquest/ui/shared/utils/snackbar_utils.dart';
import 'package:circuitquest/ui/shared/widgets/circuit_canvas/component_detail_dialog.dart';
import 'package:circuitquest/ui/shared/widgets/component_palette.dart';
import 'package:circuitquest/ui/shared/widgets/circuit_canvas/input_source_widget.dart';
import 'package:circuitquest/ui/shared/widgets/circuit_canvas/output_probe_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget representing a placed component on the canvas.
class PlacedComponentWidget extends ConsumerStatefulWidget {
  final PlacedComponent placedComponent;
  final double gridSize;
  final bool isActive;

  const PlacedComponentWidget({
    super.key,
    required this.placedComponent,
    required this.gridSize,
    this.isActive = false,
  });

  @override
  ConsumerState<PlacedComponentWidget> createState() => _PlacedComponentWidgetState();
}

class _PlacedComponentWidgetState extends ConsumerState<PlacedComponentWidget> {
  bool paning = false;
  late Offset oldPosition;

  @override
  void initState() {
    super.initState();
    oldPosition = widget.placedComponent.position;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sandboxProvider);
    final customLibrary = ref.watch(customComponentProvider);
    ComponentType? componentType;
    try {
      componentType = availableComponents.firstWhere(
        (ct) => ct.name == widget.placedComponent.type,
      );
    } catch (_) {
      CustomComponentEntry? entry;
      try {
        entry = customLibrary.components.firstWhere(
          (c) => c.data.name == widget.placedComponent.type,
        );
      } catch (_) {
        entry = null;
      }
      if (entry != null) {
        final customData = entry.data;
        final customSprite = entry.spritePath;
        componentType = ComponentType(
          name: customData.name,
          displayName: customData.name,
          iconPath: customSprite ?? '',
          isAsset: false,
          createComponent: () => CustomComponent(customData),
        );
      }
    }
    if (!paning) {
      oldPosition = widget.placedComponent.position;
    }
    return Positioned(
      left: widget.placedComponent.position.dx,
      top: widget.placedComponent.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (widget.placedComponent.immovable) return;
          paning = true;
          // Move component
          final newPosition = widget.placedComponent.position + details.delta;
          ref
              .read(sandboxProvider)
              .moveComponent(widget.placedComponent.id, newPosition);
        },
        onPanEnd: (details) {
          if (widget.placedComponent.immovable) return;
          // Snap to grid when done dragging
          paning = false;
          final snapped = Offset(
            (widget.placedComponent.position.dx / widget.gridSize).round() * widget.gridSize,
            (widget.placedComponent.position.dy / widget.gridSize).round() * widget.gridSize,
          );
          final command = MoveComponentCommand(
            state,
            widget.placedComponent.id,
            snapped,
            oldPosition,
          );
          CommandController.executeCommand(command);
          //ref.read(sandboxProvider).moveComponent(widget.placedComponent.id, snapped);
        },
        onSecondaryTapDown: (details) {
          if (widget.placedComponent.immovable) return;
          // Show context menu on right-click
          ComponentDetailDialog.displayDialog(context, widget.placedComponent, state);
        },
        onLongPress: () {
          if (widget.placedComponent.immovable) return;
          // Show context menu on long press (for touch devices)
          ComponentDetailDialog.displayDialog(context, widget.placedComponent, state);
        },
        child: Container(
          width: widget.gridSize,
          height: widget.gridSize,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue[700]!, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: widget.placedComponent.component is InputSource
              ? _buildInputControls(
                  widget.placedComponent.component as InputSource,
                  widget.placedComponent,
                  ref,
                  widget.gridSize,
                )
              : widget.placedComponent.component is OutputProbe
              ? _buildOutputProbe(
                  widget.placedComponent.component as OutputProbe,
                  widget.placedComponent,
                  ref,
                  widget.gridSize,
                )
              : Stack(
                  children: [
                    if (widget.placedComponent.label != null)
                      Positioned(
                        top: 4,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            widget.placedComponent.label!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Component icon with fallback to name text
                    Center(
                      child: _buildComponentIcon(
                        componentType,
                        widget.placedComponent.type,
                        widget.gridSize,
                      ),
                    ),
                    // Input pins (left side)
                    ..._buildInputPins(context, state),
                    // Output pins (right side)
                    ..._buildOutputPins(context, state),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildComponentIcon(
    ComponentType? componentType,
    String fallbackText,
    double gridSize,
  ) {
    if (componentType == null || componentType.iconPath.isEmpty) {
      return Text(fallbackText, textAlign: TextAlign.center);
    }

    if (componentType.isAsset) {
      return SvgPicture.asset(
        componentType.iconPath,
        width: gridSize * 0.7,
        height: gridSize * 0.7,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Text(fallbackText),
      );
    }

    if (componentType.iconPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        File(componentType.iconPath),
        width: gridSize * 0.7,
        height: gridSize * 0.7,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Text(fallbackText),
      );
    }

    return Image.file(
      File(componentType.iconPath),
      width: gridSize * 0.7,
      height: gridSize * 0.7,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Text(fallbackText),
    );
  }

  /// Builds input controls for InputSource components.
  Widget _buildInputControls(
    InputSource inputComponent,
    PlacedComponent placed,
    WidgetRef ref,
    double gridSize,
  ) {
    return InputSourceWidget(
      inputComponent: inputComponent,
      placedComponent: placed,
      ref: ref,
      gridSize: gridSize,
    );
  }

  Widget _buildOutputProbe(
    OutputProbe outputComponent,
    PlacedComponent placed,
    WidgetRef ref,
    double gridSize,
  ) {
    return OutputProbeWidget(
      outputComponent: outputComponent,
      placedComponent: placed,
      ref: ref,
      gridSize: gridSize,
    );
  }

  /// Builds interactive input pin widgets.
  List<Widget> _buildInputPins(BuildContext context, SandboxState state) {
    final inputs = widget.placedComponent.component.inputs.entries.toList();
    final pins = <Widget>[];

    for (int i = 0; i < inputs.length; i++) {
      final entry = inputs[i];
      final pinPosition = _calculatePinPosition(
        i,
        inputs.length,
        isInput: true,
      );

      pins.add(
        Positioned(
          left: pinPosition.dx,
          top: pinPosition.dy,
          child: GestureDetector(
            onTap: () {
              if (state.wireDrawingStart != null) {
                state.completeWireDrawing(
                  widget.placedComponent.id,
                  entry.key,
                  onError: (message) =>
                      SnackBarUtils.showError(context, message),
                );
                return;
              }

              // If already connected, delete the connection by tapping the input pin
              final existing = state.connections.where(
                (c) =>
                    c.targetComponentId == widget.placedComponent.id &&
                    c.targetPin == entry.key,
              );
              if (existing.isNotEmpty) {
                // Use command pattern for undo/redo support
                final command = RemoveConnectionCommand(state, existing.first);
                CommandController.executeCommand(command);
              }
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: entry.value.value > 0 ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color:
                              (entry.value.value > 0
                                      ? Colors.green
                                      : Colors.red)
                                  .withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      );
    }

    return pins;
  }

  /// Builds interactive output pin widgets.
  List<Widget> _buildOutputPins(BuildContext context, SandboxState state) {
    final outputs = widget.placedComponent.component.outputs.entries.toList();
    final pins = <Widget>[];

    for (int i = 0; i < outputs.length; i++) {
      final entry = outputs[i];
      final pinPosition = _calculatePinPosition(
        i,
        outputs.length,
        isInput: false,
      );

      pins.add(
        Positioned(
          left: pinPosition.dx,
          top: pinPosition.dy,
          child: GestureDetector(
            onTap: () {
              // Start wire drawing from this output
              state.startWireDrawing(widget.placedComponent.id, entry.key);
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: entry.value.value > 0 ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color:
                              (entry.value.value > 0
                                      ? Colors.green
                                      : Colors.red)
                                  .withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      );
    }

    return pins;
  }

  /// Calculates pin position based on index and total count.
  Offset _calculatePinPosition(int index, int total, {required bool isInput}) {
    final spacing = widget.gridSize / (total + 1);
    final y = spacing * (index + 1) - 10; // -6 to center the 12px pin

    return Offset(
      isInput ? 0 : widget.gridSize - 20, // Left or right edge
      y,
    );
  }
}
