import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/power_consumption.dart';

class AIService {
  final String baseUrl;
  final http.Client _client;

  AIService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? 'http://localhost:8006/api',
        _client = client ?? http.Client();

  /// Get predictions for the next 24 hours
  Future<PredictionResponse> getPredictions(String deviceId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/predictions/$deviceId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get predictions: ${response.body}');
      }

      final data = json.decode(response.body);
      return PredictionResponse.fromJson(data);
    } catch (e) {
      throw Exception('Error getting predictions: $e');
    }
  }

  /// Get consumption data for a device within a date range
  Future<List<PowerConsumptionData>> getConsumptionData(
    String deviceId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/consumption/$deviceId').replace(
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to get consumption data: ${response.body}');
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => PowerConsumptionData.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error getting consumption data: $e');
    }
  }

  /// Get model metrics
  Future<ModelMetrics> getModelMetrics(String deviceId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/model-metrics/$deviceId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get model metrics: ${response.body}');
      }

      final data = json.decode(response.body);
      return ModelMetrics.fromJson(data);
    } catch (e) {
      throw Exception('Error getting model metrics: $e');
    }
  }

  /// Train the model with recent data
  Future<void> trainModel(String deviceId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/train-model/$deviceId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to train model: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error training model: $e');
    }
  }

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse(baseUrl.replaceAll('/api', '')),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class PredictionResponse {
  final List<PowerConsumptionData> predictions;
  final List<PowerConsumptionAnomaly> anomalies;

  PredictionResponse({
    required this.predictions,
    required this.anomalies,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      predictions: (json['predictions'] as List? ?? [])
          .map((p) => PowerConsumptionData.fromJson(p))
          .toList(),
      anomalies: (json['anomalies'] as List? ?? [])
          .map((a) => PowerConsumptionAnomaly.fromJson(a))
          .toList(),
    );
  }
}

class ModelMetrics {
  final double mse;
  final double rmse;
  final double mae;
  final double accuracy;

  ModelMetrics({
    required this.mse,
    required this.rmse,
    required this.mae,
    required this.accuracy,
  });

  factory ModelMetrics.fromJson(Map<String, dynamic> json) {
    return ModelMetrics(
      mse: json['mse']?.toDouble() ?? 0.0,
      rmse: json['rmse']?.toDouble() ?? 0.0,
      mae: json['mae']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
    );
  }
} 