import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

class AiNotificationService {
  static final AiNotificationService _instance = AiNotificationService._internal();
  factory AiNotificationService() => _instance;
  AiNotificationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<List<Map<String, dynamic>>>? _alertSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _anomalySubscription;

  /// Initialize the AI notification service
  Future<void> initialize() async {
    try {
      developer.log('Initializing AI Notification Service');
      
      // Start listening for real-time alerts
      await _startAlertListening();
      await _startAnomalyListening();
      
      developer.log('AI Notification Service initialized successfully');
    } catch (e) {
      developer.log('Error initializing AI Notification Service: $e');
    }
  }

  /// Start listening for alert history updates
  Future<void> _startAlertListening() async {
    try {
      _alertSubscription = _supabase
          .from('alert_history')
          .stream(primaryKey: ['id'])
          .listen((data) {
            _handleNewAlerts(data);
          });
    } catch (e) {
      developer.log('Error starting alert listening: $e');
    }
  }

  /// Start listening for anomaly alerts
  Future<void> _startAnomalyListening() async {
    try {
      _anomalySubscription = _supabase
          .from('anomaly_alerts')
          .stream(primaryKey: ['id'])
          .listen((data) {
            _handleNewAnomalies(data);
          });
    } catch (e) {
      developer.log('Error starting anomaly listening: $e');
    }
  }

  /// Handle new alerts from the database
  void _handleNewAlerts(List<Map<String, dynamic>> alerts) {
    for (final alert in alerts) {
      developer.log('New alert received: ${alert['title']} - ${alert['severity']}');
      // TODO: Show local notification
      // TODO: Update UI state
    }
  }

  /// Handle new anomalies from the database
  void _handleNewAnomalies(List<Map<String, dynamic>> anomalies) {
    for (final anomaly in anomalies) {
      developer.log('New anomaly detected: ${anomaly['type']} - ${anomaly['severity']}');
      // TODO: Show local notification
      // TODO: Update UI state
    }
  }

  /// Get recent alerts for the current user
  Future<List<Map<String, dynamic>>> getRecentAlerts({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('alert_history')
          .select('*')
          .eq('user_id', _supabase.auth.currentUser?.id ?? '')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Error fetching recent alerts: $e');
      return [];
    }
  }

  /// Get recent anomalies for the current user's devices
  Future<List<Map<String, dynamic>>> getRecentAnomalies({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('anomaly_alerts')
          .select('''
            *,
            devices!inner(
              user_id
            )
          ''')
          .eq('devices.user_id', _supabase.auth.currentUser?.id ?? '')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Error fetching recent anomalies: $e');
      return [];
    }
  }

  /// Mark an alert as acknowledged
  Future<bool> acknowledgeAlert(String alertId) async {
    try {
      await _supabase
          .from('alert_history')
          .update({
            'acknowledged': true,
            'acknowledged_at': DateTime.now().toIso8601String(),
          })
          .eq('id', alertId);

      developer.log('Alert $alertId acknowledged');
      return true;
    } catch (e) {
      developer.log('Error acknowledging alert: $e');
      return false;
    }
  }

  /// Get notification settings for the current user
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _supabase
          .from('notification_preferences')
          .select('*')
          .eq('user_id', _supabase.auth.currentUser?.id ?? '')
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      developer.log('Error fetching notification settings: $e');
      // Return default settings if none found
      return {
        'notifications_enabled': true,
        'energy_spike_threshold': 2.0,
        'cost_threshold': 50.0,
        'energy_spike_enabled': true,
        'anomaly_detection_enabled': true,
        'cost_threshold_enabled': true,
      };
    }
  }

  /// Update notification settings for the current user
  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _supabase
          .from('notification_preferences')
          .upsert({
            'user_id': _supabase.auth.currentUser?.id ?? '',
            ...settings,
            'updated_at': DateTime.now().toIso8601String(),
          });

      developer.log('Notification settings updated');
      return true;
    } catch (e) {
      developer.log('Error updating notification settings: $e');
      return false;
    }
  }

  /// Dispose of resources
  void dispose() {
    _alertSubscription?.cancel();
    _anomalySubscription?.cancel();
    developer.log('AI Notification Service disposed');
  }
} 