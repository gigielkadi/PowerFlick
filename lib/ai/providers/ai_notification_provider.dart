import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_notification_service.dart';

// Provider for the AI notification service
final aiNotificationServiceProvider = Provider<AiNotificationService>((ref) {
  final service = AiNotificationService();
  
  // Dispose resources when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// Simplified notification settings model
class NotificationSettings {
  final bool notificationsEnabled;
  final double energySpikeThreshold;
  final double costThreshold;
  final DateTime? lastCheckTime;

  NotificationSettings({
    this.notificationsEnabled = true,
    this.energySpikeThreshold = 2.0,
    this.costThreshold = 50.0,
    this.lastCheckTime,
  });
}

// Provider for notification settings (simplified)
final notificationSettingsProvider = FutureProvider<NotificationSettings>((ref) async {
  // Return default settings since the service is simplified
  return NotificationSettings();
});

// Provider for monitoring status
final monitoringStatusProvider = StateProvider<bool>((ref) => false);

// Provider to start/stop monitoring
final monitoringControllerProvider = Provider<MonitoringController>((ref) {
  final service = ref.watch(aiNotificationServiceProvider);
  final statusNotifier = ref.watch(monitoringStatusProvider.notifier);
  
  return MonitoringController(service, statusNotifier);
});

class MonitoringController {
  final AiNotificationService _service;
  final StateController<bool> _statusNotifier;
  
  MonitoringController(this._service, this._statusNotifier);
  
  Future<void> startMonitoring({List<String>? deviceIds}) async {
    try {
      // TODO: Implement monitoring when full service is restored
      await _service.initialize(); // Just initialize for now
      _statusNotifier.state = true;
    } catch (e) {
      print('Error starting monitoring: $e');
      rethrow;
    }
  }
  
  void stopMonitoring() {
    try {
      // TODO: Implement stop monitoring when full service is restored
      _statusNotifier.state = false;
    } catch (e) {
      print('Error stopping monitoring: $e');
      rethrow;
    }
  }
  
  Future<void> updateSettings({
    double? energySpikeThreshold,
    double? costThreshold,
    bool? notificationsEnabled,
  }) async {
    try {
      // TODO: Implement settings update when full service is restored
      print('Settings update requested (feature simplified)');
    } catch (e) {
      print('Error updating settings: $e');
      rethrow;
    }
  }
} 