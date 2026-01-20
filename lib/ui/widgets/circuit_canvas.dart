import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/sandbox_state.dart';
import 'component_palette.dart';

/// The main canvas where components are placed and connected.
///
/// Features:
/// - Grid background for alignment
/// - Drag and drop component placement
/// - Draggable components for repositioning
/// - Wire drawing between component pins
/// - Interactive component visualization
class CircuitCanvas extends ConsumerStatefulWidget {
  const CircuitCanvas({super.key});

  @override
  ConsumerState<CircuitCanvas> createState() => _CircuitCanvasState();
}

class _CircuitCanvasState extends ConsumerState<CircuitCanvas> {
  /// Grid size in pixels
  static const double gridSize = 80.0;

  /// Current mouse/touch position for wire drawing
  Offset? _currentPointerPosition;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sandboxProvider);

    return DragTarget<ComponentType>(
      onAcceptWithDetails: (details) {
        // Calculate grid-aligned position
        final localPosition = details.offset;
        final gridPosition = _snapToGrid(localPosition);

        // Create and place the component
        final component = details.data.createComponent();
        ref.read(sandboxProvider).placeComponent(
              details.data.name,
              gridPosition,
              component,
            );
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTapDown: (details) {
            // Handle tap interactions (e.g., cancel wire drawing)
            if (state.wireDrawingStart != null) {
              state.cancelWireDrawing();
            }
          },
          onPanUpdate: (details) {
            // Track pointer position for wire drawing
            setState(() {
              _currentPointerPosition = details.localPosition;
            });
          },
          onPanEnd: (details) {
            setState(() {
              _currentPointerPosition = null;
            });
          },
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
                  ),
                  child: Container(),
                ),
                // Draw components
                ...state.placedComponents.map((placed) {
                  return _PlacedComponentWidget(
                    key: ValueKey(placed.id),
                    placedComponent: placed,
                    gridSize: gridSize,
                  );
                }),
              ],
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
}

/// Painter for the grid background.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    const gridSize = 80.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
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

  _WirePainter({
    required this.connections,
    required this.placedComponents,
    this.wireDrawingStart,
    this.currentPointerPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[700]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw existing connections
    for (final connection in connections) {
      final sourceComponent = placedComponents
          .firstWhere((c) => c.id == connection.sourceComponentId);
      final targetComponent = placedComponents
          .firstWhere((c) => c.id == connection.targetComponentId);

      // Calculate pin positions (right side for outputs, left side for inputs)
      final sourcePos = sourceComponent.position + const Offset(70, 35);
      final targetPos = targetComponent.position + const Offset(10, 35);

      _drawWire(canvas, paint, sourcePos, targetPos);
    }

    // Draw wire being drawn
    if (wireDrawingStart != null && currentPointerPosition != null) {
      final sourceComponent = placedComponents
          .firstWhere((c) => c.id == wireDrawingStart!.componentId);
      final sourcePos = sourceComponent.position + const Offset(70, 35);

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
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy,
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
        currentPointerPosition != oldDelegate.currentPointerPosition;
  }
}

/// Widget representing a placed component on the canvas.
class _PlacedComponentWidget extends ConsumerWidget {
  final PlacedComponent placedComponent;
  final double gridSize;

  const _PlacedComponentWidget({
    super.key,
    required this.placedComponent,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sandboxProvider);
    final componentType = availableComponents
        .firstWhere((ct) => ct.name == placedComponent.type);

    return Positioned(
      left: placedComponent.position.dx,
      top: placedComponent.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          // Move component
          final newPosition = placedComponent.position + details.delta;
          ref.read(sandboxProvider).moveComponent(placedComponent.id, newPosition);
        },
        onPanEnd: (details) {
          // Snap to grid when done dragging
          final snapped = Offset(
            (placedComponent.position.dx / gridSize).round() * gridSize,
            (placedComponent.position.dy / gridSize).round() * gridSize,
          );
          ref.read(sandboxProvider).moveComponent(placedComponent.id, snapped);
        },
        onLongPress: () {
          // Show context menu to delete
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
          child: Stack(
            children: [
              // Component icon
              Center(
                child: SvgPicture.asset(
                  componentType.svgAsset,
                  width: gridSize * 0.7,
                  height: gridSize * 0.7,
                  fit: BoxFit.contain,
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

  /// Builds interactive input pin widgets.
  List<Widget> _buildInputPins(BuildContext context, SandboxState state) {
    final inputs = placedComponent.component.inputs.entries.toList();
    final pins = <Widget>[];

    for (int i = 0; i < inputs.length; i++) {
      final entry = inputs[i];
      final pinPosition = _calculatePinPosition(i, inputs.length, isInput: true);

      pins.add(
        Positioned(
          left: pinPosition.dx,
          top: pinPosition.dy,
          child: GestureDetector(
            onTap: () {
              // Complete wire connection to this input
              if (state.wireDrawingStart != null) {
                state.completeWireDrawing(
                  placedComponent.id,
                  entry.key,
                );
              }
            },
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.value.value > 0 ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
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
      final pinPosition = _calculatePinPosition(i, outputs.length, isInput: false);

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
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.value.value > 0 ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
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
    final y = spacing * (index + 1) - 6; // -6 to center the 12px pin

    return Offset(
      isInput ? -6 : gridSize - 6, // Left or right edge
      y,
    );
  }

  /// Shows a context menu for component actions.
  void _showComponentMenu(BuildContext context, SandboxState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${placedComponent.type} Component'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              state.removeComponent(placedComponent.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
