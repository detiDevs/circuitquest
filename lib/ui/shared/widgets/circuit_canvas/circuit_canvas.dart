import 'package:circuitquest/constants.dart';
import 'package:circuitquest/core/commands/command_controller.dart';
import 'package:circuitquest/core/commands/place_component_command.dart';
import 'package:circuitquest/core/logic/pin.dart';
import 'package:circuitquest/ui/shared/utils/pin_positioning_utils.dart';
import 'package:circuitquest/ui/shared/widgets/circuit_canvas/placed_component_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/sandbox_state.dart';
import '../../../../core/components/component_registry.dart';
import 'package:circuitquest/levels/level.dart';

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
  static const double gridSize = Constants.kGridCellSize;
  // Absolute scene-scale limits (independent from initial fit scale).
  static const double _absoluteMinScale = 0.1;
  static const double _absoluteMaxScale = 8.0;

  // Large boundary so pan constraints do not effectively raise min zoom
  // depending on where the circuit is centered.
  static const double _boundaryMarginSize =
      Constants.kGridSizeInPixels / _absoluteMinScale;

  // Initial viewport fit should not start already at max zoom.
  static const double _maxInitialFitScale = 2.0;

  // Last applied initial fit scale used to derive InteractiveViewer
  // relative min/max limits so absolute zoom range remains constant.
  double _initialFitScale = 1.0;

  /// Current mouse/touch position for wire drawing
  Offset? _currentPointerPosition;

  /// Controller for handling pan and zoom transformations
  final TransformationController _transformationController =
      TransformationController();

  /// Cached reference to sandbox state for cleanup
  late final SandboxState _sandboxState;

  /// Last handled recenter request id from SandboxState.
  int _lastViewportCenterRequestId = -1;

  @override
  void dispose() {
    _transformationController.dispose();
    _sandboxState.reset();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    // Store sandbox state reference for cleanup in dispose
    _sandboxState = ref.read(sandboxProvider);
    // Try to initialize from level after first frame to ensure provider readiness
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sandboxState.initializeFromLevelIfNeeded(
        widget.level,
        gridSize: gridSize,
      );
      _lastViewportCenterRequestId = _sandboxState.viewportCenterRequestId;
      _centerViewportOnCircuit(_sandboxState.placedComponents);
    });
  }

  /// Centers the viewport on the loaded circuit bounds.
  /// If there are no components, centers on the canvas origin.
  void _centerViewportOnCircuit(List<PlacedComponent> components) {
    // Schedule after interactive viewer is laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final size = renderBox.size;

        final canvasCenter = Offset(
          Constants.kGridSizeInPixels / 2,
          Constants.kGridSizeInPixels / 2,
        );

        Offset targetCenter = canvasCenter;
        double scale = 1.0;

        if (components.isNotEmpty) {
          double minX = components.first.position.dx;
          double minY = components.first.position.dy;
          double maxX = components.first.position.dx + gridSize;
          double maxY = components.first.position.dy + gridSize;

          for (final component in components.skip(1)) {
            minX = component.position.dx < minX ? component.position.dx : minX;
            minY = component.position.dy < minY ? component.position.dy : minY;
            final componentMaxX = component.position.dx + gridSize;
            final componentMaxY = component.position.dy + gridSize;
            maxX = componentMaxX > maxX ? componentMaxX : maxX;
            maxY = componentMaxY > maxY ? componentMaxY : maxY;
          }

          // Add padding so components are not exactly touching viewport edges.
          final padding = gridSize * 2;
          minX -= padding;
          minY -= padding;
          maxX += padding;
          maxY += padding;

          targetCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);

          final boundsWidth = (maxX - minX).clamp(1.0, double.infinity);
          final boundsHeight = (maxY - minY).clamp(1.0, double.infinity);
          final scaleX = size.width / boundsWidth;
          final scaleY = size.height / boundsHeight;
          scale = scaleX < scaleY ? scaleX : scaleY;
        }
        final clampedScale = scale.clamp(
          _absoluteMinScale,
          _maxInitialFitScale,
        );
        final offsetX = size.width / 2 - (targetCenter.dx * clampedScale);
        final offsetY = size.height / 2 - (targetCenter.dy * clampedScale);
        if ((_initialFitScale - clampedScale).abs() > 0.0001) {
          setState(() {
            _initialFitScale = clampedScale;
          });
        }

        _transformationController.value = Matrix4.identity()
          ..setEntry(0, 0, clampedScale)
          ..setEntry(1, 1, clampedScale)
          ..setTranslationRaw(offsetX, offsetY, 0);
      } catch (e) {
        // Silently ignore if called before render object is ready
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sandboxProvider);

    ref.listen<SandboxState>(sandboxProvider, (_, next) {
      if (next.viewportCenterRequestId == _lastViewportCenterRequestId) {
        return;
      }

      _lastViewportCenterRequestId = next.viewportCenterRequestId;
      _centerViewportOnCircuit(next.placedComponents);
    });

    return DragTarget<ComponentType>(
      onAcceptWithDetails: (details) {
        // Convert global drop offset into viewport coordinates.
        final renderBox = context.findRenderObject() as RenderBox;
        final viewportPosition = renderBox.globalToLocal(details.offset);

        // Convert viewport coordinates to scene (canvas) coordinates,
        // accounting for current pan/zoom/initial centering transform.
        final scenePosition = _transformationController.toScene(
          viewportPosition,
        );
        final gridPosition = _snapToGrid(scenePosition);

        // Create and place the component using command pattern
        final component = details.data.createComponent();
        final sandboxState = ref.read(sandboxProvider);

        final command = PlaceComponentCommand(
          sandboxState,
          details.data.name,
          gridPosition,
          component,
        );

        // Execute command (this will also add it to undo history if SandboxState supports it)
        CommandController.executeCommand(command);
      },
      builder: (context, candidateData, rejectedData) {
        final effectiveMinScale = (_absoluteMinScale / _initialFitScale).clamp(
          0.01,
          1000.0,
        );
        final effectiveMaxScale = (_absoluteMaxScale / _initialFitScale).clamp(
          0.01,
          1000.0,
        );

        return InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(_boundaryMarginSize),
          minScale: effectiveMinScale,
          maxScale: effectiveMaxScale,
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
                  _currentPointerPosition = event.localPosition;
                });
              }
            },
            child: GestureDetector(
              onTapDown: (details) {
                // Cancel wire drawing only when tapping empty space
                if (state.wireDrawingStart != null) {
                  final hitComponent = _hitTestComponent(
                    state,
                    details.localPosition,
                  );
                  if (hitComponent == null) {
                    state.cancelWireDrawing();
                    setState(() {
                      _currentPointerPosition = null;
                    });
                  }
                }
              },
              child: SizedBox(
                width: Constants.kGridSizeInPixels,
                height: Constants.kGridSizeInPixels,
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
                          cellSize: gridSize,
                          activeComponentIds: state.activeComponentIds,
                        ),
                        child: Container(),
                      ),
                      // Draw components
                      ...state.placedComponents.map((placed) {
                        return PlacedComponentWidget(
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
}

/// Painter for the grid background.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[500]!
      ..strokeWidth = 0.5;

    const cellSize = Constants.kGridCellSize;
    const canvasCenter =
        (Constants.kGridSizeInPixels / 2); // Center of the 4000x4000 canvas

    // Calculate grid line positions centered at canvasCenter
    final gridStartX = (canvasCenter % cellSize).toInt();
    final gridStartY = (canvasCenter % cellSize).toInt();

    final int offsetGridX = ((canvasCenter - gridStartX) / cellSize)
        .floor()
        .toInt();
    final int offsetGridY = ((canvasCenter - gridStartY) / cellSize)
        .floor()
        .toInt();

    // Draw vertical lines
    for (
      int i = -offsetGridX - 1;
      i < (size.width / cellSize).ceil() + 1;
      i++
    ) {
      final x = (Constants.kGridSizeInPixels / 2) + i * cellSize;
      if (x >= 0 && x <= size.width) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    // Draw horizontal lines
    for (
      int i = -offsetGridY - 1;
      i < (size.height / cellSize).ceil() + 1;
      i++
    ) {
      final y = (Constants.kGridSizeInPixels / 2) + i * cellSize;
      if (y >= 0 && y <= size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
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
  final double cellSize;
  final Set<String> activeComponentIds;

  _WirePainter({
    required this.connections,
    required this.placedComponents,
    this.wireDrawingStart,
    this.currentPointerPosition,
    required this.cellSize,
    this.activeComponentIds = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[700]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final componentsById = {
      for (final component in placedComponents) component.id: component,
    };

    // Draw existing connections
    for (final connection in connections) {
      final sourceComponent = componentsById[connection.sourceComponentId];
      final targetComponent = componentsById[connection.targetComponentId];
      if (sourceComponent == null || targetComponent == null) {
        continue;
      }

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
      final sourcePinPosition = PinPositioningUtils.getPinPosition(
        connection.sourcePin,
        false,
        sourceComponent.component.pinPositions,
      );

      final targetPos = _pinCenter(
        targetComponent,
        connection.targetPin,
        isInput: true,
      );
      final targetPinPosition = PinPositioningUtils.getPinPosition(
        connection.targetPin,
        true,
        targetComponent.component.pinPositions,
      );

      // Use brighter color and wider stroke for active connections
      if (isActive) {
        paint.color = Colors.orange;
        paint.strokeWidth = 3.5;
      } else {
        paint.color = Colors.blue[700]!;
        paint.strokeWidth = 2.0;
      }

      _drawWire(
        canvas,
        paint,
        sourcePos,
        targetPos,
        sourcePinPosition: sourcePinPosition,
        targetPinPosition: targetPinPosition,
      );
    }

    // Draw wire being drawn
    if (wireDrawingStart != null && currentPointerPosition != null) {
      final sourceComponent = componentsById[wireDrawingStart!.componentId];
      if (sourceComponent == null) {
        return;
      }
      final sourcePos = _pinCenter(
        sourceComponent,
        wireDrawingStart!.pinName,
        isInput: false,
      );
      final sourcePinPosition = PinPositioningUtils.getPinPosition(
        wireDrawingStart!.pinName,
        false,
        sourceComponent.component.pinPositions,
      );

      paint.color = Colors.blue[300]!;
      paint.strokeWidth = 2.0;
      paint.strokeCap = StrokeCap.round;

      _drawWire(
        canvas,
        paint,
        sourcePos,
        currentPointerPosition!,
        sourcePinPosition: sourcePinPosition,
      );
    }
  }

  /// Draws a wire connection with intelligent routing.
  /// Routes around components when connecting to TOP or BOTTOM pins.
  void _drawWire(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end, {
    PinPosition? sourcePinPosition,
    PinPosition? targetPinPosition,
  }) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final hasVerticalPin =
        sourcePinPosition == PinPosition.TOP ||
        sourcePinPosition == PinPosition.BOTTOM ||
        targetPinPosition == PinPosition.TOP ||
        targetPinPosition == PinPosition.BOTTOM;

    if (hasVerticalPin) {
      // Route vertically first to avoid going through components
      Offset midPoint1;
      Offset midPoint2;

      if (sourcePinPosition == PinPosition.TOP) {
        midPoint1 = Offset(start.dx, start.dy - 60);
      } else if (sourcePinPosition == PinPosition.BOTTOM) {
        midPoint1 = Offset(start.dx, start.dy + 60);
      } else {
        midPoint1 = Offset(
          start.dx + (sourcePinPosition == PinPosition.LEFT ? -40 : 40),
          start.dy,
        );
      }

      if (targetPinPosition == PinPosition.TOP) {
        midPoint2 = Offset(end.dx, end.dy - 60);
      } else if (targetPinPosition == PinPosition.BOTTOM) {
        midPoint2 = Offset(end.dx, end.dy + 60);
      } else {
        midPoint2 = Offset(
          end.dx + (targetPinPosition == PinPosition.LEFT ? -40 : 40),
          end.dy,
        );
      }

      final controlPoint1 = Offset(midPoint1.dx, (start.dy + midPoint1.dy) / 2);
      final controlPoint2 = Offset(
        midPoint1.dx,
        (midPoint1.dy + midPoint2.dy) / 2,
      );
      final controlPoint3 = Offset(
        midPoint2.dx,
        (midPoint1.dy + midPoint2.dy) / 2,
      );
      final controlPoint4 = Offset(midPoint2.dx, (midPoint2.dy + end.dy) / 2);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        (midPoint1.dx + midPoint2.dx) / 2,
        (midPoint1.dy + midPoint2.dy) / 2,
      );

      path.cubicTo(
        controlPoint3.dx,
        controlPoint3.dy,
        controlPoint4.dx,
        controlPoint4.dy,
        end.dx,
        end.dy,
      );
    } else {
      // For LEFT-RIGHT connections, use simple bezier curve
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
    }

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

  /// Returns the canvas-space center for a given pin using pin positioning utilities.
  /// This respects custom pin positions defined in the component's pinPositions map.
  Offset _pinCenter(
    PlacedComponent component,
    String pinName, {
    required bool isInput,
  }) {
    final inputs = component.component.inputs.entries.toList();
    final outputs = component.component.outputs.entries.toList();
    final pinPositions = component.component.pinPositions;

    // Determine which side this pin is on
    final pinPosition = PinPositioningUtils.getPinPosition(
      pinName,
      isInput,
      pinPositions,
    );

    // Get all pin keys
    final inputKeys = inputs.map((e) => e.key).toList();
    final outputKeys = outputs.map((e) => e.key).toList();

    // Calculate total pins on this side
    final totalOnSide = PinPositioningUtils.getTotalPinsOnSide(
      pinPosition,
      inputKeys,
      outputKeys,
      pinPositions,
    );

    if (totalOnSide == 0) {
      // Fallback if no pins on this side
      return component.position + Offset(cellSize / 2, cellSize / 2);
    }

    // Find the index of this pin among all pins on the same side
    int pinIndex = 0;
    for (int i = 0; i < inputs.length + outputs.length; i++) {
      final entry = i < inputs.length ? inputs[i] : outputs[i - inputs.length];
      final isInputPin = i < inputs.length;

      final entryPosition = PinPositioningUtils.getPinPosition(
        entry.key,
        isInputPin,
        pinPositions,
      );

      if (entryPosition == pinPosition) {
        if (entry.key == pinName) {
          break;
        }
        pinIndex++;
      }
    }

    // Calculate the offset using the utility
    final offsetWithinGrid = PinPositioningUtils.calculatePinOffset(
      pinIndex,
      totalOnSide,
      cellSize,
      pinPosition,
    );

    // Return the center of the 20px pin (offset is for top-left, add 10 to center it)
    return component.position + offsetWithinGrid + Offset(10, 10);
  }
}
