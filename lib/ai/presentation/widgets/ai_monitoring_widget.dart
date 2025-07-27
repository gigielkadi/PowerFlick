import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../providers/ai_notification_provider.dart';
import '../pages/alerts_page.dart';
import '../pages/notification_settings_page.dart';

class AiMonitoringWidget extends ConsumerStatefulWidget {
  final String? deviceId;
  
  const AiMonitoringWidget({
    super.key,
    this.deviceId,
  });

  @override
  ConsumerState<AiMonitoringWidget> createState() => _AiMonitoringWidgetState();
}

class _AiMonitoringWidgetState extends ConsumerState<AiMonitoringWidget> {
  @override
  void initState() {
    super.initState();
    // Start monitoring when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMonitoring();
    });
  }

  Future<void> _startMonitoring() async {
    try {
      final controller = ref.read(monitoringControllerProvider);
      await controller.startMonitoring(
        deviceIds: widget.deviceId != null ? [widget.deviceId!] : null,
      );
    } catch (e) {
      print('Error starting monitoring: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMonitoring = ref.watch(monitoringStatusProvider);
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    TablerIcons.robot,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI Monitoring',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusIndicator(isMonitoring),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Monitoring status
            Row(
              children: [
                Icon(
                  isMonitoring ? TablerIcons.eye : TablerIcons.eye_off,
                  size: 16,
                  color: isMonitoring ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  isMonitoring ? 'Actively monitoring' : 'Monitoring paused',
                  style: TextStyle(
                    color: isMonitoring ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Settings summary
            settingsAsync.when(
              data: (settings) => _buildSettingsSummary(settings),
              loading: () => const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, stack) => Text(
                'Error loading settings',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AlertsPage(),
                        ),
                      );
                    },
                    icon: const Icon(TablerIcons.bell, size: 16),
                    label: const Text('View Alerts'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettingsPage(),
                        ),
                      );
                    },
                    icon: const Icon(TablerIcons.settings, size: 16),
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CD964),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Recent alerts preview
            _buildRecentAlertsPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isMonitoring) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMonitoring ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMonitoring ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isMonitoring ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isMonitoring ? 'ACTIVE' : 'PAUSED',
            style: TextStyle(
              color: isMonitoring ? Colors.green : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSummary(NotificationSettings settings) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildSettingRow(
            'Energy Spike Alert',
            '${settings.energySpikeThreshold.toStringAsFixed(1)}x average',
            TablerIcons.bolt,
            Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildSettingRow(
            'Cost Threshold',
            '\$${settings.costThreshold.toStringAsFixed(0)} daily',
            TablerIcons.currency_dollar,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildSettingRow(
            'AI Anomaly Detection',
            'High severity only',
            TablerIcons.brain,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAlertsPreview() {
    // Mock recent alerts - in a real app, this would come from a provider
    final recentAlerts = [
      _AlertPreview(
        type: 'Energy Spike',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        severity: 'High',
        icon: TablerIcons.bolt,
        color: Colors.orange,
      ),
      _AlertPreview(
        type: 'AI Anomaly',
        time: DateTime.now().subtract(const Duration(hours: 6)),
        severity: 'Medium',
        icon: TablerIcons.brain,
        color: Colors.purple,
      ),
    ];

    if (recentAlerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              TablerIcons.check_circle,
              color: Colors.green[600],
              size: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              'No recent alerts - all systems normal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Alerts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AlertsPage(),
                  ),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentAlerts.take(2).map((alert) => _buildAlertPreviewItem(alert)),
      ],
    );
  }

  Widget _buildAlertPreviewItem(_AlertPreview alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: alert.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: alert.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            alert.icon,
            size: 14,
            color: alert.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert.type,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            _formatTime(alert.time),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: alert.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              alert.severity.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: alert.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

class _AlertPreview {
  final String type;
  final DateTime time;
  final String severity;
  final IconData icon;
  final Color color;

  _AlertPreview({
    required this.type,
    required this.time,
    required this.severity,
    required this.icon,
    required this.color,
  });
} 