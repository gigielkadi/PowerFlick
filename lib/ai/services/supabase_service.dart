import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/power_consumption.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<PowerConsumptionData>> fetchConsumptionData(
    String deviceId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _client
          .from('power_readings')
          .select()
          .eq('device_id', deviceId)
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String())
          .order('timestamp', ascending: true);

      if (result == null) {
        throw Exception('No data returned from Supabase');
      }

      return (result as List)
          .map((data) => PowerConsumptionData(
                timestamp: DateTime.parse(data['timestamp']),
                consumption: (data['power_watts'] as num?)?.toDouble() ?? 0.0,
                predictedConsumption: (data['power_kwh'] as num?)?.toDouble(),
              ))
          .toList();
    } catch (e) {
      throw Exception('Error fetching consumption data: $e');
    }
  }

  Future<void> saveConsumptionData(
    String deviceId,
    PowerConsumptionData data,
  ) async {
    try {
      final response = await _client.from('power_consumption').upsert({
        'device_id': deviceId,
        ...data.toJson(),
      });

      if (response.error != null) {
        throw response.error!;
      }
    } catch (e) {
      throw Exception('Error saving consumption data: $e');
    }
  }

  Future<void> saveAnomalyAlert(
    String deviceId,
    PowerConsumptionAnomaly anomaly,
  ) async {
    try {
      final response = await _client.from('anomaly_alerts').upsert({
        'device_id': deviceId,
        ...anomaly.toJson(),
      });

      if (response.error != null) {
        throw response.error!;
      }
    } catch (e) {
      throw Exception('Error saving anomaly alert: $e');
    }
  }

  Future<List<PowerConsumptionAnomaly>> fetchAnomalies(
    String deviceId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _client
          .from('anomaly_alerts')
          .select()
          .eq('device_id', deviceId)
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String())
          .order('timestamp', ascending: false);

      if (result == null) {
        throw Exception('No data returned from Supabase');
      }

      return (result as List)
          .map((data) => PowerConsumptionAnomaly.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Error fetching anomalies: $e');
    }
  }

  Future<void> saveModelMetrics(
    String deviceId,
    Map<String, dynamic> metrics,
  ) async {
    try {
      final response = await _client.from('model_metrics').upsert({
        'device_id': deviceId,
        'timestamp': DateTime.now().toIso8601String(),
        ...metrics,
      });

      if (response.error != null) {
        throw response.error!;
      }
    } catch (e) {
      throw Exception('Error saving model metrics: $e');
    }
  }
} 