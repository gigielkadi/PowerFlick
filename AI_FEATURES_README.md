# AI-Powered Notification Features

This document describes the new AI-powered notification features implemented in PowerFlick, including energy spike alerts, anomaly detection, and cost threshold warnings.

## 🚀 Features Overview

### 1. Energy Spike Alerts ⚡
- **Real-time monitoring** of power consumption spikes
- **Configurable thresholds** (default: 2x average consumption)
- **Instant notifications** when consumption exceeds normal patterns
- **Historical logging** of all energy spikes

### 2. AI Anomaly Detection 🤖
- **Machine Learning powered** anomaly detection using LSTM models
- **Pattern recognition** for unusual energy consumption behaviors
- **Severity-based alerts** (High, Medium, Low)
- **Integration with existing AI backend** at `AI_model/backend/`

### 3. Cost Threshold Warnings 💰
- **Daily budget monitoring** with configurable thresholds
- **Projected cost calculations** based on current usage
- **Early warnings** before exceeding budget limits
- **Cost tracking and logging**

## 📱 User Interface Components

### AI Monitoring Widget
- **Real-time status indicator** showing monitoring state
- **Settings summary** with current thresholds
- **Recent alerts preview** with quick access
- **Direct navigation** to alerts and settings

### Alerts Page
- **Tabbed interface** for different alert types
- **Detailed alert history** with filtering by device
- **Interactive alert details** with full context
- **Refresh functionality** for real-time updates

### Notification Settings Page
- **Master toggle** for all AI notifications
- **Individual threshold controls** with sliders
- **Test notification** functionality
- **Visual settings summary** with icons

## 🔧 Technical Implementation

### Core Services

#### AiNotificationService
```dart
// Main service handling all AI-powered notifications
class AiNotificationService {
  // Real-time monitoring
  Future<void> startMonitoring({List<String>? deviceIds});
  
  // Individual check methods
  Future<void> checkForEnergySpikes(String deviceId);
  Future<void> checkForAnomalies(String deviceId);
  Future<void> checkForCostThresholds(String deviceId);
  
  // Settings management
  Future<void> updateSettings({...});
  Future<NotificationSettings> getSettings();
}
```

#### AI Integration
- **Direct integration** with existing LSTM models
- **API endpoints** for predictions and anomalies
- **Real-time data processing** from Supabase
- **Background monitoring** using WorkManager

### Notification Channels
1. **Energy Spike Alerts** - High priority, vibration enabled
2. **Anomaly Detection** - High priority, AI-powered insights
3. **Cost Threshold** - High priority, budget warnings

### Database Schema

#### New Tables Created
```sql
-- User FCM tokens for push notifications
user_fcm_tokens (id, user_id, fcm_token, created_at, updated_at)

-- Energy spike event logging
energy_spike_logs (id, device_id, timestamp, current_power, average_power, spike_percentage)

-- Cost warning event logging
cost_warning_logs (id, device_id, timestamp, current_cost, projected_cost, threshold)

-- User notification preferences
notification_preferences (id, user_id, energy_spike_threshold, cost_threshold, notifications_enabled, ...)

-- Alert history for UI display
alert_history (id, user_id, device_id, alert_type, title, description, severity, data, acknowledged)
```

## 🔐 Security & Privacy

### Row Level Security (RLS)
- **User isolation** - Users can only access their own data
- **Service role access** - System can insert notifications
- **Authenticated access** - All tables require authentication

### Data Protection
- **Encrypted FCM tokens** stored securely
- **Personal preferences** protected by RLS
- **Alert history** accessible only to owner

## 📊 AI Backend Integration

### Existing AI Infrastructure
The notifications integrate seamlessly with your existing AI backend:

```python
# AI_model/backend/src/services/prediction_service.py
class PredictionService:
    async def predict_next_24h(device_id: str) -> Dict[str, List]:
        # Returns predictions and anomalies
        return {
            'predictions': [...],
            'anomalies': [...]  # Used by notification service
        }
```

### API Endpoints Used
- `GET /api/predictions/{device_id}` - Get AI predictions and anomalies
- `GET /api/model-metrics/{device_id}` - Get model performance
- `POST /api/train-model/{device_id}` - Retrain model

## 🔄 Background Processing

### WorkManager Integration
- **Periodic tasks** every 15 minutes
- **Battery optimization** with smart constraints
- **Network-aware** processing
- **Background execution** even when app is closed

### Monitoring Schedule
```dart
// Check every 5 minutes when app is active
Timer.periodic(Duration(minutes: 5), (timer) async {
  for (final deviceId in activeDevices) {
    await checkForEnergySpikes(deviceId);
    await checkForAnomalies(deviceId);
    await checkForCostThresholds(deviceId);
  }
});
```

## 🎯 Configuration Options

### Energy Spike Thresholds
- **Range**: 1.5x to 5.0x average consumption
- **Default**: 2.0x average
- **Granularity**: 0.5x increments

### Cost Thresholds
- **Range**: $10 to $200 daily budget
- **Default**: $50 daily
- **Granularity**: $10 increments

### AI Anomaly Settings
- **Severity filtering**: High severity only (configurable)
- **Time window**: 1-hour recent anomalies
- **Model integration**: Direct LSTM model output

## 🚀 Getting Started

### 1. Initialize the Service
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(url: url, anonKey: key);
  
  // Initialize AI Notification Service
  final aiNotificationService = AiNotificationService();
  await aiNotificationService.initialize();
  
  runApp(MyApp());
}
```

### 2. Add to Your Dashboard
```dart
// Add the AI monitoring widget to any page
AiMonitoringWidget(deviceId: 'your_device_id')
```

### 3. Navigation Setup
```dart
// Routes are already configured in main.dart
'/alerts': (context) => const AlertsPage(),
'/notification-settings': (context) => const NotificationSettingsPage(),
```

## 📱 Platform Support

### iOS
- **Local notifications** with UNUserNotificationCenter
- **Background app refresh** for monitoring
- **Push notifications** via APNs

### Android
- **Notification channels** for categorization
- **Background services** with WorkManager
- **Push notifications** via FCM
- **Battery optimization** handling

## 🔍 Monitoring & Analytics

### Built-in Logging
- **Energy spike events** with detailed metrics
- **Cost warning events** with projections
- **Anomaly detection results** with AI confidence
- **User interaction tracking** for alerts

### Performance Metrics
- **Notification delivery rates**
- **False positive tracking**
- **User engagement analytics**
- **Battery usage optimization**

## 🛠️ Troubleshooting

### Common Issues

#### Notifications Not Appearing
1. Check notification permissions
2. Verify Firebase configuration
3. Test with the built-in test function

#### AI Anomalies Not Detected
1. Ensure AI backend is running
2. Check device data availability
3. Verify model training status

#### High Battery Usage
1. Adjust monitoring frequency
2. Enable battery optimization
3. Check background app settings

### Debug Commands
```dart
// Test notification system
await AiNotificationService()._showLocalNotification(
  title: 'Test',
  body: 'Testing notifications',
  channelId: 'test_channel',
);

// Check monitoring status
final isMonitoring = ref.watch(monitoringStatusProvider);

// View current settings
final settings = await AiNotificationService().getSettings();
```

## 🔮 Future Enhancements

### Planned Features
- **Smart scheduling** based on usage patterns
- **Predictive cost alerts** with ML forecasting
- **Device-specific thresholds** with learning
- **Integration with smart home** automation
- **Voice notifications** with TTS
- **Wearable device support** for Apple Watch/Wear OS

### AI Improvements
- **Enhanced anomaly detection** with transformer models
- **Seasonal pattern recognition** for better baselines
- **Multi-device correlation** for household insights
- **Predictive maintenance** alerts for appliances

## 📚 Dependencies Added

```yaml
dependencies:
  # Push Notifications & Local Notifications
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^17.0.0
  
  # Background processing
  workmanager: ^0.5.2
  
  # Permissions
  permission_handler: ^11.2.0
```

## 🤝 Contributing

When contributing to the AI notification features:

1. **Test thoroughly** on both iOS and Android
2. **Follow the existing patterns** for service architecture
3. **Update documentation** for any new features
4. **Consider battery impact** for background operations
5. **Ensure privacy compliance** with data handling

## 📄 License

This AI notification system is part of the PowerFlick project and follows the same licensing terms.

---

**Need help?** Check the troubleshooting section or review the existing AI backend documentation in `AI_model/backend/README.md`. 