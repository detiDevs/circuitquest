import 'package:circuitquest/core/logic/pin.dart';
import 'package:flutter/material.dart';

/// Utility class for calculating pin positions around a component.
/// Provides reusable pin positioning logic for both canvas and dialog views.
class PinPositioningUtils {
  /// Calculates the pixel offset for a pin based on its index, total count, and orientation.
  ///
  /// Parameters:
  /// - [index]: Zero-based position within the side (0, 1, 2, ...)
  /// - [total]: Total number of pins on this side
  /// - [gridSize]: Size of the container (width or height)
  /// - [orientation]: Which side the pin is on (TOP, RIGHT, BOTTOM, LEFT)
  ///
  /// Returns an [Offset] with the pin's position. The spacing is calculated to
  /// evenly distribute pins along the side, with -10 offset to center the 20px pin.
  static Offset calculatePinOffset(
    int index,
    int total,
    double gridSize,
    PinPosition orientation,
  ) {
    final spacing = gridSize / (total + 1);
    final crossAxis = spacing * (index + 1) - 10; // -10 to center the 20px pin

    switch (orientation) {
      case PinPosition.TOP:
        return Offset(crossAxis, 0);
      case PinPosition.RIGHT:
        return Offset(gridSize - 20, crossAxis);
      case PinPosition.BOTTOM:
        return Offset(crossAxis, gridSize - 20);
      case PinPosition.LEFT:
        return Offset(0, crossAxis);
    }
  }

  /// Determines which side a pin belongs on based on pinPositions and defaults.
  ///
  /// Rules:
  /// - If the pin has a custom position in [pinPositions], use that
  /// - Otherwise: inputs default to LEFT, outputs default to RIGHT
  static PinPosition getPinPosition(
    String pinKey,
    bool isInput,
    Map<String, PinPosition>? pinPositions,
  ) {
    if (pinPositions != null && pinPositions.containsKey(pinKey)) {
      return pinPositions[pinKey]!;
    }
    // Default: inputs on LEFT, outputs on RIGHT
    return isInput ? PinPosition.LEFT : PinPosition.RIGHT;
  }

  /// Calculates how many pins are on each side.
  ///
  /// Returns a map with counts for TOP, RIGHT, BOTTOM, and LEFT.
  static Map<PinPosition, int> calculatePinsPerSide(
    List<String> inputKeys,
    List<String> outputKeys,
    Map<String, PinPosition>? pinPositions,
  ) {
    final counts = {
      PinPosition.TOP: 0,
      PinPosition.RIGHT: 0,
      PinPosition.BOTTOM: 0,
      PinPosition.LEFT: 0,
    };

    // Count inputs
    for (final inputKey in inputKeys) {
      final position = getPinPosition(inputKey, true, pinPositions);
      counts[position] = (counts[position] ?? 0) + 1;
    }

    // Count outputs
    for (final outputKey in outputKeys) {
      final position = getPinPosition(outputKey, false, pinPositions);
      counts[position] = (counts[position] ?? 0) + 1;
    }

    return counts;
  }

  /// Gets the total number of pins on a specific side.
  static int getTotalPinsOnSide(
    PinPosition side,
    List<String> inputKeys,
    List<String> outputKeys,
    Map<String, PinPosition>? pinPositions,
  ) {
    final counts = calculatePinsPerSide(inputKeys, outputKeys, pinPositions);
    return counts[side] ?? 0;
  }
}
