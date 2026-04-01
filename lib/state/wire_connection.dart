//TODO: Split up this file for modularity

/// Represents a wire connection between two component pins.
class WireConnection {
  /// Source component ID
  final String sourceComponentId;

  /// Source output pin name
  final String sourcePin;

  /// Target component ID
  final String targetComponentId;

  /// Target input pin name
  final String targetPin;

  WireConnection({
    required this.sourceComponentId,
    required this.sourcePin,
    required this.targetComponentId,
    required this.targetPin,
  });

  factory WireConnection.fromJson(Map<String, dynamic> json) {
    return WireConnection(
      sourceComponentId: json['origin'].toString(),
      sourcePin: json['originKey'],
      targetComponentId: json['destination'].toString(),
      targetPin: json['destinationKey'],
    );
  }

  /// Converts this WireConnection to JSON format
  Map<String, dynamic> toJson() {
    return {
      'sourceComponentId': sourceComponentId,
      'sourcePin': sourcePin,
      'targetComponentId': targetComponentId,
      'targetPin': targetPin,
    };
  }
}
