import 'package:flutter/material.dart';
import 'dart:math';
import '../../../home/presentation/pages/simple_rooms_page.dart';
import '../../../presentation/rooms/rooms_page.dart';
import '../../../presentation/rooms/my_rooms_page.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Today', 'This week', 'This month'];
  final List<double> _consumptionValues = [14.2, 87.5, 342.8];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Tab buttons - more compact
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == index ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: _selectedTabIndex == index 
                                ? Border.all(color: const Color(0xFFE0E0E0), width: 1)
                                : null,
                            boxShadow: _selectedTabIndex == index
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedTabIndex == index ? FontWeight.w600 : FontWeight.w400,
                              color: _selectedTabIndex == index ? const Color(0xFF4CAF50) : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Energy Consumption Circle - smaller size
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
                      // Circle progress
                      CustomPaint(
                        size: const Size(180, 180),
                        painter: CircularProgressPainter(
                          progress: 0.7,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      
                      // Center content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Energy icon
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
                          // Energy value
                          Text(
                            '${_consumptionValues[_selectedTabIndex]} kWh',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Monitor section - more compact
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              color: Color(0xFF4CAF50),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Monitor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6E7787),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildMonitorItem('Cost Estimation', 'EGP 52'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),
                      _buildMonitorItem('CO₂ Emissions', '5.4 kg'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),
                      _buildMonitorItem(
                        'Compared to Yesterday',
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withOpacity(0.1),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.arrow_upward,
                                size: 10,
                                color: Colors.red,
                              ),
                            ),
                            const Text(
                              ' +8% or ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.arrow_downward,
                                size: 10,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const Text(
                              ' -3%',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Activities section - more compact with horizontal layout
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            color: Color(0xFF4CAF50),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Activities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6E7787),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Activities cards in a row
                    Expanded(
                      child: Row(
                        children: [
                          // View Rooms button
                          Expanded(
                            child: _buildActivityCard(
                              'View Rooms',
                              Icons.meeting_room,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const MyRoomsPage()),
                                );
                              },
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // View History button
                          Expanded(
                            child: _buildActivityCard(
                              'View History',
                              Icons.history,
                              onTap: () {
                                // TODO: Navigate to History page
                              },
                              gradient: const LinearGradient(
                                colors: [Color(0xFF616161), Color(0xFF9E9E9E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PowerFlickBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildMonitorItem(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF3C3C3C),
          ),
        ),
        if (value is String)
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C3C3C),
            ),
          )
        else
          value,
      ],
    );
  }

  Widget _buildActivityCard(
    String text, 
    IconData icon, 
    {required VoidCallback onTap, required Gradient gradient}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw background circle
    final paintBg = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(
      center,
      radius - 12,
      paintBg,
    );
    
    // Draw progress arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      center: Alignment.center,
      startAngle: -pi/2,
      endAngle: 2*pi - pi/2,
      colors: [
        color.withOpacity(0.7),
        color,
      ],
      stops: const [0.0, 1.0],
      transform: GradientRotation(-pi/2 + progress * 2*pi/2),
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;
    
    final progressAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 12),
      -pi/2, // Start from top
      progressAngle,
      false,
      paint,
    );
    
    // Draw dots around circle
    final dotPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    const numberOfDots = 30; // Fewer dots
    const dotRadius = 1.5; // Smaller dots
    for (int i = 0; i < numberOfDots; i++) {
      final angle = (2 * pi / numberOfDots) * i;
      final dotX = center.dx + (radius - 12) * cos(angle);
      final dotY = center.dy + (radius - 12) * sin(angle);
      
      canvas.drawCircle(
        Offset(dotX, dotY),
        dotRadius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 