import 'package:circuitquest/core/logic/pin.dart';
import 'package:circuitquest/state/sandbox_state.dart';
import 'package:circuitquest/ui/shared/utils/pin_positioning_utils.dart';
import 'package:flutter/material.dart';

/// Painter for wire connections.
class WirePainter extends CustomPainter {
  final List<WireConnection> connections;
  final List<PlacedComponent> placedComponents;
  final ({String componentId, String pinName})? wireDrawingStart;
  final Offset? currentPointerPosition;
  final double cellSize;
  final Set<String> activeComponentIds;

  WirePainter({
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
  bool shouldRepaint(covariant WirePainter oldDelegate) {
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
