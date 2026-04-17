//TODO: Split up this file for modularity

import 'package:circuitquest/constants.dart';
import 'package:circuitquest/core/components/base/component.dart';
import 'package:flutter/material.dart';

/// Represents a component instance placed on the canvas.
class PlacedComponent {
  /// The component type (e.g., "And", "Or", "Not")
  final String type;

  /// The actual logic component instance
  final Component component;

  /// Position on the canvas grid
  final Offset position;

  /// Unique identifier for this placed component
  final String id;

  /// Whether this component can be moved/removed by the player
  final bool immovable;

  /// Whether user-editable values/properties for this component are locked
  final bool immutable;

  /// Optional display label from level configuration (e.g., "A", "B")
  final String? label;

  PlacedComponent({
    required this.type,
    required this.component,
    required this.position,
    required this.id,
    this.immovable = false,
    this.immutable = false,
    this.label,
  });

  /// Converts this PlacedComponent to JSON format
  Map<String, dynamic> toJson() {
    final canvasCenter = Constants.kGridSizeInPixels / 2;
    final logicalX = ((position.dx - canvasCenter) / Constants.kGridCellSize)
        .round();
    final logicalY = ((position.dy - canvasCenter) / Constants.kGridCellSize)
        .round();

    return {
      'type': type,
      'position': [logicalX, logicalY],
      'id': id,
      if (immovable) 'immovable': immovable,
      if (immutable) 'immutable': immutable,
      if (label != null) 'label': label,
    };
  }
}
