import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../models/power_consumption.dart';
import '../../services/ai_notification_service.dart';
import '../../services/supabase_service.dart';
import 'notification_settings_page.dart';

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({super.key});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage> with SingleTickerProviderStateMixin {
  final AiNotificationService _notificationService = AiNotificationService();
  final SupabaseService _supabaseService = SupabaseService();
  
  late TabController _tabController;
  List<AlertItem> _allAlerts = [];
  List<AlertItem> _energySpikeAlerts = [];
  List<AlertItem> _anomalyAlerts = [];
  List<AlertItem> _costAlerts = [];
  
  bool _isLoading = true;
  String _selectedDevice = 'all';
  List<String> _availableDevices = ['all'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAlerts();
    _loadDevices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    try {
      // This would load from your devices table
      final devices = await _getAvailableDevices();
      setState(() {
        _availableDevices = ['all', ...devices];
      });
    } catch (e) {
      print('Error loading devices: $e');
    }
  }

  Future<List<String>> _getAvailableDevices() async {
    try {
      // Mock implementation - replace with actual device fetching
      return ['device_001', 'device_002', 'device_003'];
    } catch (e) {
      return [];
    }
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30)); // Last 30 days
      
      // Load different types of alerts
      await Future.wait([
        _loadEnergySpikes(startDate, endDate),
        _loadAnomalies(startDate, endDate),
        _loadCostWarnings(startDate, endDate),
      ]);

      // Combine and sort all alerts
      _allAlerts = [
        ..._energySpikeAlerts,
        ..._anomalyAlerts,
        ..._costAlerts,
      ];
      _allAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    } catch (e) {
      print('Error loading alerts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading alerts: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEnergySpikes(DateTime startDate, DateTime endDate) async {
    try {
      // Mock data - replace with actual Supabase query
      _energySpikeAlerts = [
        AlertItem(
          id: '1',
          type: AlertType.energySpike,
          title: 'Energy Spike Detected',
          description: 'Power consumption increased by 150% above average',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          deviceId: 'device_001',
          severity: AlertSeverity.high,
          data: {
            'current_power': 2500.0,
            'average_power': 1000.0,
            'spike_percentage': 150,
          },
        ),
        AlertItem(
          id: '2',
          type: AlertType.energySpike,
          title: 'Energy Spike Detected',
          description: 'Power consumption increased by 120% above average',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          deviceId: 'device_002',
          severity: AlertSeverity.medium,
          data: {
            'current_power': 1800.0,
            'average_power': 800.0,
            'spike_percentage': 120,
          },
        ),
      ];
    } catch (e) {
      print('Error loading energy spikes: $e');
    }
  }

  Future<void> _loadAnomalies(DateTime startDate, DateTime endDate) async {
    try {
      // Load anomalies from AI service
      final deviceIds = _selectedDevice == 'all' 
          ? _availableDevices.where((d) => d != 'all').toList()
          : [_selectedDevice];

      List<AlertItem> anomalies = [];
      
      for (final deviceId in deviceIds) {
        try {
          final deviceAnomalies = await _supabaseService.fetchAnomalies(
            deviceId,
            startDate: startDate,
            endDate: endDate,
          );

          for (final anomaly in deviceAnomalies) {
            anomalies.add(AlertItem(
              id: 'anomaly_${anomaly.timestamp.millisecondsSinceEpoch}',
              type: AlertType.anomaly,
              title: 'AI Anomaly Detected',
              description: _getAnomalyDescription(anomaly),
              timestamp: anomaly.timestamp,
              deviceId: deviceId,
              severity: _getSeverityFromString(anomaly.severity),
              data: {
                'value': anomaly.value,
                'deviation_percentage': anomaly.deviationPercentage,
                'type': anomaly.type,
              },
            ));
          }
        } catch (e) {
          print('Error loading anomalies for device $deviceId: $e');
        }
      }

      _anomalyAlerts = anomalies;
    } catch (e) {
      print('Error loading anomalies: $e');
    }
  }

  Future<void> _loadCostWarnings(DateTime startDate, DateTime endDate) async {
    try {
      // Mock data - replace with actual Supabase query
      _costAlerts = [
        AlertItem(
          id: '3',
          type: AlertType.costThreshold,
          title: 'Cost Threshold Exceeded',
          description: 'Daily energy cost projected to reach \$65.50',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          deviceId: 'device_001',
          severity: AlertSeverity.high,
          data: {
            'projected_cost': 65.50,
            'threshold': 50.0,
            'current_cost': 32.75,
          },
        ),
      ];
    } catch (e) {
      print('Error loading cost warnings: $e');
    }
  }

  String _getAnomalyDescription(PowerConsumptionAnomaly anomaly) {
    switch (anomaly.type) {
      case 'high_deviation':
        return 'Unusually high power consumption (${anomaly.deviationPercentage.toStringAsFixed(1)}% above normal)';
      case 'low_deviation':
        return 'Unusually low power consumption (${anomaly.deviationPercentage.toStringAsFixed(1)}% below normal)';
      default:
        return 'Unusual power consumption pattern detected';
    }
  }

  AlertSeverity _getSeverityFromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AlertSeverity.high;
      case 'medium':
        return AlertSeverity.medium;
      case 'low':
        return AlertSeverity.low;
      default:
        return AlertSeverity.medium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Alerts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(TablerIcons.device_desktop),
            onSelected: (value) {
              setState(() {
                _selectedDevice = value;
              });
              _loadAlerts();
            },
            itemBuilder: (context) => _availableDevices.map((device) {
              return PopupMenuItem<String>(
                value: device,
                child: Text(device == 'all' ? 'All Devices' : device),
              );
            }).toList(),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
            icon: const Icon(TablerIcons.settings),
            tooltip: 'Notification Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(TablerIcons.list),
              text: 'All (${_allAlerts.length})',
            ),
            Tab(
              icon: const Icon(TablerIcons.bolt),
              text: 'Spikes (${_energySpikeAlerts.length})',
            ),
            Tab(
              icon: const Icon(TablerIcons.brain),
              text: 'Anomalies (${_anomalyAlerts.length})',
            ),
            Tab(
              icon: const Icon(TablerIcons.currency_dollar),
              text: 'Costs (${_costAlerts.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAlertsList(_allAlerts),
                _buildAlertsList(_energySpikeAlerts),
                _buildAlertsList(_anomalyAlerts),
                _buildAlertsList(_costAlerts),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAlerts,
        backgroundColor: const Color(0xFF4CD964),
        child: const Icon(TablerIcons.refresh),
      ),
    );
  }

  Widget _buildAlertsList(List<AlertItem> alerts) {
    if (alerts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return _buildAlertCard(alert);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            TablerIcons.bell_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No alerts found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your AI monitoring system will notify you of any unusual activity',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AlertItem alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAlertDetails(alert),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAlertIcon(alert.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSeverityBadge(alert.severity),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    TablerIcons.device_desktop,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    alert.deviceId,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    TablerIcons.clock,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimestamp(alert.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertIcon(AlertType type) {
    IconData icon;
    Color color;

    switch (type) {
      case AlertType.energySpike:
        icon = TablerIcons.bolt;
        color = Colors.orange;
        break;
      case AlertType.anomaly:
        icon = TablerIcons.brain;
        color = Colors.purple;
        break;
      case AlertType.costThreshold:
        icon = TablerIcons.currency_dollar;
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildSeverityBadge(AlertSeverity severity) {
    Color color;
    String text;

    switch (severity) {
      case AlertSeverity.high:
        color = Colors.red;
        text = 'HIGH';
        break;
      case AlertSeverity.medium:
        color = Colors.orange;
        text = 'MEDIUM';
        break;
      case AlertSeverity.low:
        color = Colors.blue;
        text = 'LOW';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  void _showAlertDetails(AlertItem alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAlertDetailsSheet(alert),
    );
  }

  Widget _buildAlertDetailsSheet(AlertItem alert) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header
          Row(
            children: [
              _buildAlertIcon(alert.type),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(alert.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildSeverityBadge(alert.severity),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            'Description',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            alert.description,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Details
          Text(
            'Details',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow('Device', alert.deviceId),
          _buildDetailRow('Alert Type', _getAlertTypeString(alert.type)),
          _buildDetailRow('Severity', _getSeverityString(alert.severity)),
          
          // Type-specific details
          if (alert.type == AlertType.energySpike) ...[
            _buildDetailRow(
              'Current Power',
              '${alert.data['current_power']?.toStringAsFixed(1)} W',
            ),
            _buildDetailRow(
              'Average Power',
              '${alert.data['average_power']?.toStringAsFixed(1)} W',
            ),
            _buildDetailRow(
              'Spike Percentage',
              '${alert.data['spike_percentage']}%',
            ),
          ],
          
          if (alert.type == AlertType.anomaly) ...[
            _buildDetailRow(
              'Power Value',
              '${alert.data['value']?.toStringAsFixed(1)} W',
            ),
            _buildDetailRow(
              'Deviation',
              '${alert.data['deviation_percentage']?.toStringAsFixed(1)}%',
            ),
            _buildDetailRow(
              'Anomaly Type',
              alert.data['type'] ?? 'Unknown',
            ),
          ],
          
          if (alert.type == AlertType.costThreshold) ...[
            _buildDetailRow(
              'Current Cost',
              '\$${alert.data['current_cost']?.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Projected Cost',
              '\$${alert.data['projected_cost']?.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Threshold',
              '\$${alert.data['threshold']?.toStringAsFixed(2)}',
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CD964),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAlertTypeString(AlertType type) {
    switch (type) {
      case AlertType.energySpike:
        return 'Energy Spike';
      case AlertType.anomaly:
        return 'AI Anomaly';
      case AlertType.costThreshold:
        return 'Cost Threshold';
    }
  }

  String _getSeverityString(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.low:
        return 'Low';
    }
  }
}

// Models
class AlertItem {
  final String id;
  final AlertType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String deviceId;
  final AlertSeverity severity;
  final Map<String, dynamic> data;

  AlertItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.deviceId,
    required this.severity,
    required this.data,
  });
}

enum AlertType {
  energySpike,
  anomaly,
  costThreshold,
}

enum AlertSeverity {
  high,
  medium,
  low,
} 