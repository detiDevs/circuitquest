import 'package:circuitquest/constants.dart';
import 'package:flutter/material.dart';

/// Painter for the grid background.
class GridPainter extends CustomPainter {
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
