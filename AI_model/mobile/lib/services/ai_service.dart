import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/power_consumption.dart';
import '../providers/ai_dashboard_provider.dart';

class AIService {
  final String baseUrl;
  final http.Client _client;

  AIService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? 'http://localhost:8000/api',
        _client = client ?? http.Client();

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
      predictions: (json['predictions'] as List)
          .map((p) => PowerConsumptionData.fromJson(p))
          .toList(),
      anomalies: (json['anomalies'] as List)
          .map((a) => PowerConsumptionAnomaly.fromJson(a))
          .toList(),
    );
  }
} 