import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../ai/services/ai_service.dart';
import '../../../../ai/services/dashboard_service.dart';
import '../../../../ai/models/power_consumption.dart';

class AiDashboardPage extends StatefulWidget {
  const AiDashboardPage({super.key});

  @override
  State<AiDashboardPage> createState() => _AiDashboardPageState();
}

class _AiDashboardPageState extends State<AiDashboardPage> {
  final AIService _aiService = AIService();
  final DashboardService _dashboardService = DashboardService();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  String deviceId = 'e13de1eb-7ef8-4746-aa50-b6809041a676'; // Use real device with live data
  Color get accentGreen => const Color(0xFF4CAF50);
  
  // State variables
  bool _isLoading = false;
  List<PowerConsumptionData> _predictions = [];
  List<PowerConsumptionData> _consumptionData = [];
  DashboardMetrics? _dashboardMetrics;
  String? _errorMessage;
  Timer? _refreshTimer;
  StreamSubscription<List<Map<String, dynamic>>>? _powerReadingsSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh every 10 seconds for real-time data
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load real-time dashboard metrics from Supabase
      final dashboardMetrics = await _dashboardService.getDashboardMetrics(deviceId);
      
      // Load consumption data for the last 7 days from AI API
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final consumptionData = await _aiService.getConsumptionData(
        deviceId,
        startDate: startDate,
        endDate: endDate,
      );
      
      // Get predictions
      final predictionResponse = await _aiService.getPredictions(deviceId);
      
      if (mounted) {
        setState(() {
          _dashboardMetrics = dashboardMetrics;
          _consumptionData = consumptionData;
          _predictions = predictionResponse.predictions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Row(
            children: [
              const Text('Optimization Dashboard', style: TextStyle(color: Colors.black)),
              const SizedBox(width: 8),
              if (_isLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black54),
                onPressed: _loadData,
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: Color(0xFF4CAF50),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Color(0xFF4CAF50),
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Overview'),
              Tab(icon: Icon(Icons.show_chart), text: 'Predictions'),
              Tab(icon: Icon(Icons.tips_and_updates), text: 'Recommendations'),
            ],
          ),
        ),
        body: _errorMessage != null
            ? _buildErrorWidget()
            : TabBarView(
                children: [
                  _buildOverviewTab(),
                  _buildPredictionsTab(),
                  _buildRecommendationsTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
                      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to connect to AI backend'),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    // Use real-time data from Supabase
    final currentPower = _dashboardMetrics?.currentPower ?? 0.0;
    final todayTotal = _dashboardMetrics?.todayTotal ?? 0.0;
    final avgPower = _dashboardMetrics?.averagePower ?? 0.0;

    return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
          // Real-time status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Data',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                        ),
                      ],
                    ),
                  ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryCard(
                Icons.bolt, 
                'Current Power', 
                '${currentPower.toStringAsFixed(1)} W', 
                accentGreen,
                subtitle: 'Real-time reading',
              ),
              const SizedBox(width: 12),
              _summaryCard(
                Icons.today, 
                'Today Total', 
                '${todayTotal.toStringAsFixed(2)} kWh', 
                Colors.blue,
                subtitle: 'All devices',
              ),
              const SizedBox(width: 12),
              _summaryCard(
                Icons.trending_up, 
                'Avg Power', 
                '${avgPower.toStringAsFixed(1)} W', 
                Colors.orange,
                subtitle: 'Last 24h',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: 'Recent Consumption Trends',
            icon: Icons.show_chart,
            child: Container(
              height: 200,
              child: _consumptionData.isNotEmpty 
                  ? _buildConsumptionChart()
                  : const Center(child: Text('No data available')),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPredictionsTab() {
    return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionCard(
            title: 'Next 24 Hours Predictions',
            icon: Icons.show_chart,
                    child: Column(
                      children: [
                if (_predictions.isNotEmpty) ...[
                        Container(
                    height: 250,
                    child: _buildPredictionChart(),
                  ),
                  const SizedBox(height: 16),
                  _buildPredictionSummary(),
                ] else ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No predictions available'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    final recommendations = _generateRecommendations();
    
    return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionCard(
            title: 'AI Recommendations',
                    icon: Icons.tips_and_updates,
                    child: Column(
              children: recommendations.map((rec) => _buildRecommendationCard(rec)).toList(),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildConsumptionChart() {
    final spots = _consumptionData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.consumption))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < _consumptionData.length) {
                  final date = _consumptionData[value.toInt()].timestamp;
                  return Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}W', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: accentGreen,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: accentGreen.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildPredictionChart() {
    final predictionSpots = _predictions
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.consumption))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < _predictions.length) {
                  final hour = _predictions[value.toInt()].timestamp.hour;
                  return Text('${hour}h', style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}W', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: predictionSpots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildPredictionSummary() {
    final avgPrediction = _predictions.isNotEmpty
        ? _predictions.map((e) => e.consumption).reduce((a, b) => a + b) / _predictions.length
        : 0.0;
    
    final maxPrediction = _predictions.isNotEmpty
        ? _predictions.map((e) => e.consumption).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _metricTile('Average', '${avgPrediction.toStringAsFixed(1)} W'),
            _metricTile('Peak', '${maxPrediction.toStringAsFixed(1)} W'),
            _metricTile('Total (24h)', '${(avgPrediction * 24 / 1000).toStringAsFixed(1)} kWh'),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Predicted consumption for the next 24 hours based on your usage patterns.',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    
    if (_consumptionData.isNotEmpty) {
      final avgConsumption = _consumptionData.map((e) => e.consumption).reduce((a, b) => a + b) / _consumptionData.length;
      
      if (avgConsumption > 15) {
        recommendations.add('Your average consumption is above 15W. Consider optimizing device usage.');
      }
      
      final peakHours = _consumptionData.where((data) => data.consumption > avgConsumption * 1.5).toList();
      if (peakHours.isNotEmpty) {
        recommendations.add('Peak usage detected. Try to spread high-power activities throughout the day.');
      }
    }
    

    
    if (recommendations.isEmpty) {
      recommendations.addAll([
        'Your power consumption patterns look optimal!',
        'Keep monitoring your usage to maintain efficiency.',
        'Consider setting up automation for further optimization.',
      ]);
    }
    
    return recommendations;
  }

  Widget _buildRecommendationCard(String recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: accentGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _summaryCard(IconData icon, String title, String value, Color color, {String? subtitle}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentGreen),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _metricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
} 