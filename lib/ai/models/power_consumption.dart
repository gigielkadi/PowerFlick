class PowerConsumptionData {
  final DateTime timestamp;
  final double consumption;
  final double? predictedConsumption;
  final String? deviceId;

  PowerConsumptionData({
    required this.timestamp,
    required this.consumption,
    this.predictedConsumption,
    this.deviceId,
  });

  factory PowerConsumptionData.fromJson(Map<String, dynamic> json) {
    return PowerConsumptionData(
      timestamp: DateTime.parse(json['timestamp']),
      consumption: (json['consumption'] ?? json['power_watts'] ?? 0.0).toDouble(),
      predictedConsumption: json['predicted_consumption']?.toDouble(),
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'consumption': consumption,
      'predicted_consumption': predictedConsumption,
      'device_id': deviceId,
    };
  }
}

class PowerConsumptionAnomaly {
  final DateTime timestamp;
  final double value;
  final double deviationPercentage;
  final String type;
  final String severity;

  PowerConsumptionAnomaly({
    required this.timestamp,
    required this.value,
    required this.deviationPercentage,
    required this.type,
    required this.severity,
  });

  factory PowerConsumptionAnomaly.fromJson(Map<String, dynamic> json) {
    return PowerConsumptionAnomaly(
      timestamp: DateTime.parse(json['timestamp']),
      value: json['value']?.toDouble() ?? 0.0,
      deviationPercentage: json['deviation_percentage']?.toDouble() ?? 0.0,
      type: json['type'] ?? 'unknown',
      severity: json['severity'] ?? 'low',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'deviation_percentage': deviationPercentage,
      'type': type,
      'severity': severity,
    };
  }
} 