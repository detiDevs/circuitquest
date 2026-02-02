import 'dart:collection';

class CustomComponentConnection {
  final int origin;
  final String originKey;
  final int destination;
  final String destinationKey;

  CustomComponentConnection({
    required this.origin,
    required this.originKey,
    required this.destination,
    required this.destinationKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'originKey': originKey,
      'destination': destination,
      'destinationKey': destinationKey,
    };
  }

  factory CustomComponentConnection.fromJson(Map<String, dynamic> json) {
    return CustomComponentConnection(
      origin: (json['origin'] as num).toInt(),
      originKey: json['originKey'] as String,
      destination: (json['destination'] as num).toInt(),
      destinationKey: json['destinationKey'] as String,
    );
  }
}

class CustomComponentData {
  final String name;
  final LinkedHashMap<String, int> inputMap;
  final LinkedHashMap<String, int> outputMap;
  final List<String> components;
  final List<CustomComponentConnection> connections;

  CustomComponentData({
    required this.name,
    required LinkedHashMap<String, int> inputMap,
    required LinkedHashMap<String, int> outputMap,
    required this.components,
    required this.connections,
  })  : inputMap = LinkedHashMap<String, int>.from(inputMap),
        outputMap = LinkedHashMap<String, int>.from(outputMap);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'inputMap': inputMap,
      'outputMap': outputMap,
      'components': components,
      'connections': connections.map((c) => c.toJson()).toList(),
    };
  }

  factory CustomComponentData.fromJson(Map<String, dynamic> json) {
    final rawInput = json['inputMap'] as Map<String, dynamic>;
    final rawOutput = json['outputMap'] as Map<String, dynamic>;
    return CustomComponentData(
      name: json['name'] as String,
      inputMap: LinkedHashMap<String, int>.from(
        rawInput.map((key, value) => MapEntry(key, (value as num).toInt())),
      ),
      outputMap: LinkedHashMap<String, int>.from(
        rawOutput.map((key, value) => MapEntry(key, (value as num).toInt())),
      ),
      components:
          (json['components'] as List<dynamic>).map((e) => e as String).toList(),
      connections: (json['connections'] as List<dynamic>)
          .map((e) => CustomComponentConnection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}