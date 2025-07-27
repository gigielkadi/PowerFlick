import 'package:flutter/material.dart';
import '../../../home/presentation/pages/my_home_page_control.dart';
import '../pages/dashboard_page.dart';
import '../../../automation/presentation/pages/automation_page.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/home_providers.dart';
import 'ai_dashboard_page.dart';

class ControlPanelPage extends ConsumerWidget {
  const ControlPanelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalKwhAsync = ref.watch(totalKwhProvider);
    final userGoalAsync = ref.watch(userGoalProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Control Panel',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // TODO: Implement menu
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Container(
          color: const Color(0xFFF2F4F8),
          child: userGoalAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (maxConsumption) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: totalKwhAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (totalKwh) {
                          final percent = maxConsumption > 0 ? (totalKwh / maxConsumption).clamp(0, 1).toDouble() : 0.0;
                          final minArc = 0.01; // 1% minimum arc
                          final displayPercent = (percent > 0 && percent < minArc) ? minArc : percent;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    height: 180,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CustomPaint(
                                          size: const Size(180, 180),
                                          painter: CircularProgressPainter(
                                            progress: displayPercent,
                                            color: const Color(0xFF4CAF50),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.bolt,
                                                color: Color(0xFF4CAF50),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${(percent * 100).toStringAsFixed(2)}%',
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                letterSpacing: -1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${totalKwh.toStringAsFixed(2)} kWh',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'of $maxConsumption kWh',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Stats below indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('22 kg CO2 Saved', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                        SizedBox(height: 2),
                                        Text("Today's impact", style: TextStyle(fontSize: 13, color: Color(0xFF6E7787))),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${totalKwh.toStringAsFixed(2)} kWh', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                        const SizedBox(height: 2),
                                        const Text('Energy Usage', style: TextStyle(fontSize: 13, color: Color(0xFF6E7787))),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Quick Controls Title
                  const Padding(
                    padding: EdgeInsets.only(left: 24, top: 8, bottom: 8),
                    child: Text(
                      'Quick Controls',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6E7787),
                      ),
                    ),
                  ),
                  // Quick Controls Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.15,
                        padding: EdgeInsets.zero,
                        children: [
                          _buildFeatureCardWithImage(
                            'Dashboard',
                            Icons.dashboard,
                            [
                              _buildFeatureItem(Icons.speed, 'Total consumption'),
                              _buildFeatureItem(Icons.history, 'History'),
                            ],
                            'assets/illustrations/dashboard.png',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const DashboardPage()),
                              );
                            },
                          ),
                          _buildFeatureCardWithImage(
                            'Control',
                            Icons.gamepad,
                            [
                              _buildActionButton('Tap to adjust'),
                            ],
                            'assets/illustrations/control.png',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const MyHomePageControl()),
                              );
                            },
                          ),
                          _buildFeatureCardWithImage(
                            'Automate',
                            Icons.auto_awesome,
                            [
                              _buildFeatureToggle(Icons.nightlight, 'Night Mode'),
                              _buildFeatureToggle(Icons.flight, 'Holiday Mode'),
                              _buildFeatureToggle(Icons.power_settings_new, 'Low Power Mode'),
                            ],
                            'assets/illustrations/automate.png',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const AutomationPage()),
                              );
                            },
                          ),
                          _buildFeatureCardWithImage(
                            'Optimize',
                            Icons.trending_up,
                            [
                              _buildActionButton('Switch up your pattern'),
                            ],
                            'assets/illustrations/optimize.png',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const AiDashboardPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: PowerFlickBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildFeatureCardWithImage(
    String title,
    IconData icon,
    List<Widget> items,
    String imagePath, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8), // Reduced padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 12, // Smaller icon
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureToggle(IconData icon, String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ThreeLayerCircularIndicator extends StatelessWidget {
  final double percent;
  final double currentKwh;
  final double totalKwh;
  final double fontSizePercent;
  final double fontSizeKwh;
  final double fontSizeTotal;
  final String centerLabel;
  const ThreeLayerCircularIndicator({
    super.key,
    required this.percent,
    required this.currentKwh,
    required this.totalKwh,
    this.fontSizePercent = 24,
    this.fontSizeKwh = 13,
    this.fontSizeTotal = 12,
    this.centerLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Soft shadow/glow
        Container(
          width: fontSizePercent * 4.5,
          height: fontSizePercent * 4.5,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CD964).withOpacity(0.07),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
        // Circular arcs
        CustomPaint(
          size: Size(fontSizePercent * 4, fontSizePercent * 4),
          painter: _ThreeArcPainterModern(percent: percent),
        ),
        // Centered text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(percent * 100).round()}%',
              style: TextStyle(
                fontSize: fontSizePercent,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF222222),
                letterSpacing: -2,
              ),
            ),
            if (centerLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  centerLabel,
                  style: TextStyle(
                    fontSize: fontSizeKwh,
                    color: const Color(0xFF6E7787),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (currentKwh > 0 && totalKwh > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${currentKwh.toStringAsFixed(1)} kWh of ${totalKwh.toStringAsFixed(1)} kWh',
                  style: TextStyle(
                    fontSize: fontSizeTotal,
                    color: const Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ThreeArcPainterModern extends CustomPainter {
  final double percent;
  _ThreeArcPainterModern({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radii = [size.width / 2 - 8, size.width / 2 - 24, size.width / 2 - 40];
    final strokeWidths = [14.0, 10.0, 7.0];
    final colors = [
      const Color(0xFF4CD964), // innermost, most filled (primary)
      const Color(0xFFB6F2C8), // middle (light green)
      const Color(0xFFE6F9ED), // outermost, lightest
    ];
    for (int i = 0; i < 3; i++) {
      final paintBg = Paint()
        ..color = colors[i].withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidths[i]
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radii[i]),
        -3.14 / 2,
        2 * 3.14,
        false,
        paintBg,
      );
      if (i == 0) {
        // Gradient for main arc
        final rect = Rect.fromCircle(center: center, radius: radii[i]);
        final gradient = SweepGradient(
          startAngle: -3.14 / 2,
          endAngle: 2 * 3.14 - 3.14 / 2,
          colors: [
            const Color(0xFF4CD964),
            const Color(0xFF6EE7B7),
            const Color(0xFF4CD964),
          ],
          stops: const [0.0, 0.7, 1.0],
        );
        final paint = Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidths[i]
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radii[i]),
          -3.14 / 2,
          2 * 3.14 * percent,
          false,
          paint,
        );
      } else {
        final paint = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidths[i]
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radii[i]),
          -3.14 / 2,
          2 * 3.14 * percent,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 