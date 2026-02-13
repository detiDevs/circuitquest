import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix4;
import '../../l10n/app_localizations.dart';
import '../../state/sandbox_state.dart';
import '../../core/components/input_source.dart';
import '../../core/components/output_probe.dart';
import '../../core/components/cpu/instruction_memory.dart';
import '../../core/components/cpu/data_memory.dart';
import '../../core/components/cpu/register_block.dart';
import 'package:circuitquest/levels/level.dart';
import '../../core/components/base/component.dart';
import 'component_palette.dart';
import 'input_source_widget.dart';
import 'output_probe_widget.dart';
import '../../state/custom_component_library.dart';
import '../../core/components/custom_component.dart';
import '../utils/snackbar_utils.dart';

/// The main canvas where components are placed and connected.
///
/// Features:
/// - Grid background for alignment
/// - Drag and drop component placement
/// - Draggable components for repositioning
/// - Wire drawing between component pins
/// - Interactive component visualization
class CircuitCanvas extends ConsumerStatefulWidget {
  /// Optional level for pre-placing components on the canvas
  final Level? level;

  const CircuitCanvas({super.key, this.level});

  @override
  ConsumerState<CircuitCanvas> createState() => _CircuitCanvasState();
}

class _CircuitCanvasState extends ConsumerState<CircuitCanvas> {
  /// Grid size in pixels
  static const double gridSize = 80.0;

  /// Current mouse/touch position for wire drawing
  Offset? _currentPointerPosition;

  /// Whether initial components were placed from the level
  bool _initializedFromLevel = false;

  /// Controller for handling pan and zoom transformations
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    final state = ref.watch(sandboxProvider);
    state.reset();
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    // Try to initialize from level after first frame to ensure provider readiness
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromLevelIfNeeded();
    });
  }

  void _initializeFromLevelIfNeeded() {
    if (_initializedFromLevel) return;
    final level = widget.level;
    if (level == null) return;

    final state = ref.read(sandboxProvider);
    state.reset();

    for(var c in level.components) {
      print(c.type);
    }
    for (final lc in level.components) {
      final resolved = _resolveComponentForLevelType(lc.type);
      if (resolved == null) continue;

      final position = Offset(
        (lc.position[0]) * gridSize,
        (lc.position[1]) * gridSize,
      );

      // Load memory contents if applicable
      if (resolved.component is InstructionMemory && level.memoryContents != null) {
        (resolved.component as InstructionMemory).loadInstructions(
          level.memoryContents!.instructionMemory,
        );
      } else if (resolved.component is DataMemory && level.memoryContents != null) {
        (resolved.component as DataMemory).loadData(
          level.memoryContents!.dataMemory,
        );
      } else if (resolved.component is RegisterBlock && lc.initialRegisterValues != null) {
        (resolved.component as RegisterBlock).loadRegisters(
          lc.initialRegisterValues!,
        );
      }

      state.placeComponent(
        resolved.typeName,
        position,
        resolved.component,
        immovable: lc.immovable,
        label: lc.label,
      );
    }
    
    for (final connection in level.connections) {
      print("Adding connection: ${connection.toJson()}");
      state.addConnection(
        connection.sourceComponentId,
        connection.sourcePin,
        connection.targetComponentId,
        connection.targetPin,
      );
    }

    _initializedFromLevel = true;
  }

  /// Maps a level component type to a concrete component and canonical type name.
  ({String typeName, Component component})? _resolveComponentForLevelType(
    String type,
  ) {
    switch (type) {
      case 'Input':
        return (typeName: 'InputSource', component: InputSource());
      case 'Output':
        return (typeName: 'OutputProbe', component: OutputProbe());
      default:
        // Try to resolve via availableComponents mapping
        try {
          final ct = availableComponents.firstWhere((c) => c.name == type);
          return (typeName: ct.name, component: ct.createComponent());
        } catch (_) {
          return null;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sandboxProvider);

    return DragTarget<ComponentType>(
      onAcceptWithDetails: (details) {
        // Convert global drop offset into local canvas coordinates, accounting for zoom/pan
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.offset);
        // Transform the position to account for zoom and pan
        final transformedPosition = _transformPosition(localPosition);
        final gridPosition = _snapToGrid(transformedPosition);

        // Create and place the component
        final component = details.data.createComponent();
        ref
            .read(sandboxProvider)
            .placeComponent(details.data.name, gridPosition, component);
      },
      builder: (context, candidateData, rejectedData) {
        return InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(1000),
          minScale: 0.1,
          maxScale: 4.0,
          constrained: false,
          onInteractionEnd: (details) {
            // Cancel wire drawing when zoom/pan interaction ends
            if (state.wireDrawingStart != null) {
              state.cancelWireDrawing();
              setState(() {
                _currentPointerPosition = null;
              });
            }
          },
          child: MouseRegion(
            onHover: (event) {
              // Track mouse position for wire drawing feedback
              if (state.wireDrawingStart != null) {
                setState(() {
                  _currentPointerPosition = _transformPosition(
                    event.localPosition,
                  );
                });
              }
            },
            child: GestureDetector(
              onTapDown: (details) {
                // Cancel wire drawing only when tapping empty space
                if (state.wireDrawingStart != null) {
                  final transformedPos = _transformPosition(
                    details.localPosition,
                  );
                  final hitComponent = _hitTestComponent(state, transformedPos);
                  if (hitComponent == null) {
                    state.cancelWireDrawing();
                    setState(() {
                      _currentPointerPosition = null;
                    });
                  }
                }
              },
              child: SizedBox(
                width: 4000,
                height: 4000,
                child: CustomPaint(
                  painter: _GridPainter(),
                  child: Stack(
                    children: [
                      // Draw wires
                      CustomPaint(
                        painter: _WirePainter(
                          connections: state.connections,
                          placedComponents: state.placedComponents,
                          wireDrawingStart: state.wireDrawingStart,
                          currentPointerPosition: _currentPointerPosition,
                          gridSize: gridSize,
                          activeComponentIds: state.activeComponentIds,
                        ),
                        child: Container(),
                      ),
                      // Draw components
                      ...state.placedComponents.map((placed) {
                        return _PlacedComponentWidget(
                          key: ValueKey(placed.id),
                          placedComponent: placed,
                          gridSize: gridSize,
                          isActive: state.activeComponentIds.contains(
                            placed.id,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Snaps a position to the nearest grid point.
  Offset _snapToGrid(Offset position) {
    return Offset(
      (position.dx / gridSize).round() * gridSize,
      (position.dy / gridSize).round() * gridSize,
    );
  }

  /// Returns the component under the given local canvas position, if any.
  PlacedComponent? _hitTestComponent(SandboxState state, Offset position) {
    for (final component in state.placedComponents) {
      final rect = Rect.fromLTWH(
        component.position.dx,
        component.position.dy,
        gridSize,
        gridSize,
      );
      if (rect.contains(position)) {
        return component;
      }
    }
    return null;
  }

  /// Transforms screen coordinates to canvas coordinates accounting for zoom/pan
  Offset _transformPosition(Offset screenPosition) {
    final Matrix4 transform = _transformationController.value;
    final Matrix4 inverseTransform = Matrix4.inverted(transform);
    final Vector3 transformed = inverseTransform.transform3(
      Vector3(screenPosition.dx, screenPosition.dy, 0),
    );
    return Offset(transformed.x, transformed.y);
  }
}

/// Painter for the grid background.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[500]!
      ..strokeWidth = 0.5;

    const gridSize = 80.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for wire connections.
class _WirePainter extends CustomPainter {
  final List<WireConnection> connections;
  final List<PlacedComponent> placedComponents;
  final ({String componentId, String pinName})? wireDrawingStart;
  final Offset? currentPointerPosition;
  final double gridSize;
  final Set<String> activeComponentIds;

  _WirePainter({
    required this.connections,
    required this.placedComponents,
    this.wireDrawingStart,
    this.currentPointerPosition,
    required this.gridSize,
    this.activeComponentIds = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[700]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw existing connections
    for (final connection in connections) {
      final sourceComponent = placedComponents.firstWhere(
        (c) => c.id == connection.sourceComponentId,
      );
      final targetComponent = placedComponents.firstWhere(
        (c) => c.id == connection.targetComponentId,
      );

      // Check if this connection is active (either endpoint is being evaluated)
      final isActive =
          activeComponentIds.contains(connection.sourceComponentId) ||
          activeComponentIds.contains(connection.targetComponentId);

      // Calculate pin centers for the specific pins involved
      final sourcePos = _pinCenter(
        sourceComponent,
        connection.sourcePin,
        isInput: false,
      );
      final targetPos = _pinCenter(
        targetComponent,
        connection.targetPin,
        isInput: true,
      );

      // Use brighter color and wider stroke for active connections
      if (isActive) {
        paint.color = Colors.orange;
        paint.strokeWidth = 3.5;
      } else {
        paint.color = Colors.blue[700]!;
        paint.strokeWidth = 2.0;
      }

      _drawWire(canvas, paint, sourcePos, targetPos);
    }

    // Draw wire being drawn
    if (wireDrawingStart != null && currentPointerPosition != null) {
      final sourceComponent = placedComponents.firstWhere(
        (c) => c.id == wireDrawingStart!.componentId,
      );
      final sourcePos = _pinCenter(
        sourceComponent,
        wireDrawingStart!.pinName,
        isInput: false,
      );

      paint.color = Colors.blue[300]!;
      paint.strokeWidth = 2.0;
      paint.strokeCap = StrokeCap.round;

      _drawWire(canvas, paint, sourcePos, currentPointerPosition!);
    }
  }

  /// Draws a wire connection with optional bezier curve.
  void _drawWire(Canvas canvas, Paint paint, Offset start, Offset end) {
    // Use a simple bezier curve for better visual appearance
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final controlPoint1 = Offset(start.dx + 50, start.dy);
    final controlPoint2 = Offset(end.dx - 50, end.dy);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);

    // Draw circles at endpoints
    canvas.drawCircle(start, 4, Paint()..color = paint.color);
    canvas.drawCircle(end, 4, Paint()..color = paint.color);
  }

  @override
  bool shouldRepaint(covariant _WirePainter oldDelegate) {
    return connections != oldDelegate.connections ||
        wireDrawingStart != oldDelegate.wireDrawingStart ||
        currentPointerPosition != oldDelegate.currentPointerPosition ||
        activeComponentIds != oldDelegate.activeComponentIds;
  }

  /// Returns the canvas-space center for a given pin.
  Offset _pinCenter(
    PlacedComponent component,
    String pinName, {
    required bool isInput,
  }) {
    final pins = isInput
        ? component.component.inputs.keys.toList()
        : component.component.outputs.keys.toList();

    if (pins.isEmpty) {
      return component.position + Offset(isInput ? 0 : gridSize, gridSize / 2);
    }

    final index = pins.indexOf(pinName);
    if (index == -1) {
      // Fallback to first pin if name not found
      return _pinCenter(component, pins.first, isInput: isInput);
    }

    final spacing = gridSize / (pins.length + 1);
    final yCenter = spacing * (index + 1);
    final xCenter = isInput ? 0.0 : gridSize;

    return component.position + Offset(xCenter, yCenter);
  }
}

/// Widget representing a placed component on the canvas.
class _PlacedComponentWidget extends ConsumerWidget {
  final PlacedComponent placedComponent;
  final double gridSize;
  final bool isActive;

  const _PlacedComponentWidget({
    super.key,
    required this.placedComponent,
    required this.gridSize,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sandboxProvider);
    final customLibrary = ref.watch(customComponentProvider);
    ComponentType? componentType;
    try {
      componentType = availableComponents.firstWhere(
        (ct) => ct.name == placedComponent.type,
      );
    } catch (_) {
      CustomComponentEntry? entry;
      try {
        entry = customLibrary.components.firstWhere(
          (c) => c.data.name == placedComponent.type,
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

    return Positioned(
      left: placedComponent.position.dx,
      top: placedComponent.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (placedComponent.immovable) return;
          // Move component
          final newPosition = placedComponent.position + details.delta;
          ref
              .read(sandboxProvider)
              .moveComponent(placedComponent.id, newPosition);
        },
        onPanEnd: (details) {
          if (placedComponent.immovable) return;
          // Snap to grid when done dragging
          final snapped = Offset(
            (placedComponent.position.dx / gridSize).round() * gridSize,
            (placedComponent.position.dy / gridSize).round() * gridSize,
          );
          ref.read(sandboxProvider).moveComponent(placedComponent.id, snapped);
        },
        onSecondaryTapDown: (details) {
          if (placedComponent.immovable) return;
          // Show context menu on right-click
          _showContextMenu(
            context,
            details.globalPosition,
            ref.read(sandboxProvider),
          );
        },
        onLongPress: () {
          if (placedComponent.immovable) return;
          // Show context menu on long press (for touch devices)
          _showComponentMenu(context, ref.read(sandboxProvider));
        },
        child: Container(
          width: gridSize,
          height: gridSize,
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
          child: placedComponent.component is InputSource
              ? _buildInputControls(
                  placedComponent.component as InputSource,
                  placedComponent,
                  ref,
                )
              : placedComponent.component is OutputProbe
              ? _buildOutputProbe(
                  placedComponent.component as OutputProbe,
                  placedComponent,
                  ref,
                )
              : Stack(
                  children: [
                    if (placedComponent.label != null)
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
                            placedComponent.label!,
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
                        placedComponent.type,
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

  Widget _buildComponentIcon(ComponentType? componentType, String fallbackText) {
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
    final inputs = placedComponent.component.inputs.entries.toList();
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
                  placedComponent.id, 
                  entry.key,
                  onError: (message) => SnackBarUtils.showError(context, message),
                );
                return;
              }

              // If already connected, delete the connection by tapping the input pin
              final existing = state.connections.where(
                (c) =>
                    c.targetComponentId == placedComponent.id &&
                    c.targetPin == entry.key,
              );
              if (existing.isNotEmpty) {
                state.removeConnection(existing.first);
              }
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: entry.value.value > 0 ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: isActive
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
    final outputs = placedComponent.component.outputs.entries.toList();
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
              state.startWireDrawing(placedComponent.id, entry.key);
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: entry.value.value > 0 ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: isActive
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
    final spacing = gridSize / (total + 1);
    final y = spacing * (index + 1) - 10; // -6 to center the 12px pin

    return Offset(
      isInput ? 0 : gridSize - 20, // Left or right edge
      y,
    );
  }

  /// Shows a context menu for component actions.
  void _showComponentMenu(BuildContext context, SandboxState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(
            context,
          )!.componentMenuTitle(placedComponent.type),
        ),
        content: Text(AppLocalizations.of(context)!.componentMenuPrompt),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              state.removeComponent(placedComponent.id);
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a context menu at the cursor position (for right-click).
  void _showContextMenu(
    BuildContext context,
    Offset position,
    SandboxState state,
  ) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.delete),
            ],
          ),
          onTap: () {
            // Use Future.delayed to avoid closing before tap completes
            Future.delayed(Duration.zero, () {
              state.removeComponent(placedComponent.id);
            });
          },
        ),
      ],
    );
  }
}
