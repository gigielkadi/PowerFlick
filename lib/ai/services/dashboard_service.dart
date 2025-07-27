import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get the latest power reading (current power) for a specific device
  Future<double> getCurrentPower(String deviceId) async {
    try {
      final response = await _client
          .from('power_readings')
          .select('power_watts')
          .eq('device_id', deviceId)
          .order('timestamp', ascending: false)
          .limit(1)
          .single();
      
      return (response['power_watts'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('Error fetching current power: $e');
      return 0.0;
    }
  }

  /// Get total power consumption from devices table (sum of all devices' total_power)
  Future<double> getTodayTotal() async {
    try {
      final response = await _client
          .from('devices')
          .select('total_power');
      
      if (response == null || response.isEmpty) {
        return 0.0;
      }
      
      double total = 0.0;
      for (final device in response) {
        total += (device['total_power'] as num?)?.toDouble() ?? 0.0;
      }
      
      return total;
    } catch (e) {
      print('Error fetching today total: $e');
      return 0.0;
    }
  }

  /// Get average power consumption from recent readings (last 24 hours)
  Future<double> getAveragePower(String deviceId) async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));
      
      final response = await _client
          .from('power_readings')
          .select('power_watts')
          .eq('device_id', deviceId)
          .gte('timestamp', yesterday.toIso8601String())
          .lte('timestamp', now.toIso8601String());
      
      if (response == null || response.isEmpty) {
        return 0.0;
      }
      
      double total = 0.0;
      int count = 0;
      
      for (final reading in response) {
        final power = (reading['power_watts'] as num?)?.toDouble();
        if (power != null) {
          total += power;
          count++;
        }
      }
      
      return count > 0 ? total / count : 0.0;
    } catch (e) {
      print('Error fetching average power: $e');
      return 0.0;
    }
  }

  /// Get real-time dashboard metrics for a device
  Future<DashboardMetrics> getDashboardMetrics(String deviceId) async {
    try {
      final futures = await Future.wait([
        getCurrentPower(deviceId),
        getTodayTotal(),
        getAveragePower(deviceId),
      ]);
      
      return DashboardMetrics(
        currentPower: futures[0],
        todayTotal: futures[1],
        averagePower: futures[2],
      );
    } catch (e) {
      print('Error fetching dashboard metrics: $e');
      return DashboardMetrics(
        currentPower: 0.0,
        todayTotal: 0.0,
        averagePower: 0.0,
      );
    }
  }
}

class DashboardMetrics {
  final double currentPower;
  final double todayTotal;
  final double averagePower;

  DashboardMetrics({
    required this.currentPower,
    required this.todayTotal,
    required this.averagePower,
  });
} 