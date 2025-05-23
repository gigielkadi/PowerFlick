import 'package:flutter/material.dart';
import 'dart:math';
import 'room_detail_page.dart';
import '../../widgets/powerflick_bottom_nav_bar.dart';

class MyRoomsPage extends StatefulWidget {
  const MyRoomsPage({super.key});

  @override
  State<MyRoomsPage> createState() => _MyRoomsPageState();
}

class _MyRoomsPageState extends State<MyRoomsPage> {
  int _selectedRoomIndex = 0;
  final List<String> _rooms = ['Bedroom', 'Living Room', 'Kitchen'];
  final List<double> _roomConsumption = [2.1, 4.8, 3.2]; // in kWh
  final List<double> _roomPercentage = [15, 34, 22]; // in %
  final double _totalConsumption = 14.2; // in kWh
  
  final Map<String, Map<String, dynamic>> _deviceStats = {
    'Bedroom': {
      'Lamp': {'consumption': 0.5, 'percentage': 25},
      'AC': {'consumption': 1.2, 'percentage': 60},
      'Charger': {'consumption': 0.4, 'percentage': 15},
    },
    'Living Room': {
      'TV': {'consumption': 2.2, 'percentage': 46},
      'Console': {'consumption': 1.6, 'percentage': 33},
      'Lights': {'consumption': 1.0, 'percentage': 21},
    },
    'Kitchen': {
      'Fridge': {'consumption': 1.5, 'percentage': 47},
      'Microwave': {'consumption': 1.0, 'percentage': 31},
      'Coffee Maker': {'consumption': 0.7, 'percentage': 22},
    },
  };
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Rooms',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
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
              
              // Room tabs
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: List.generate(_rooms.length, (index) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRoomIndex = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedRoomIndex == index 
                                ? Colors.transparent 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _rooms[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedRoomIndex == index 
                                      ? const Color(0xFF4CAF50) 
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 3,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: _selectedRoomIndex == index 
                                      ? const Color(0xFF4CAF50)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Room energy consumption circle
              Center(
                child: SizedBox(
                  height: 220,
                  width: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress circles
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: MultiLayerCircularProgressPainter(
                          progress: _roomPercentage[_selectedRoomIndex] / 100,
                        ),
                      ),
                      
                      // Center content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_roomPercentage[_selectedRoomIndex].toInt()}%',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${_roomConsumption[_selectedRoomIndex]} kWh',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'of ${_totalConsumption} kWh',
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
              
              const SizedBox(height: 30),
              
              // Devices list
              Expanded(
                child: ListView.builder(
                  itemCount: _deviceStats[_rooms[_selectedRoomIndex]]!.length,
                  itemBuilder: (context, index) {
                    final deviceName = _deviceStats[_rooms[_selectedRoomIndex]]!.keys.elementAt(index);
                    final deviceData = _deviceStats[_rooms[_selectedRoomIndex]]![deviceName]!;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getDeviceIcon(deviceName),
                              color: const Color(0xFF4CAF50),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            deviceName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${deviceData['consumption']} kWh',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${deviceData['percentage']}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Cost estimation
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cost Estimation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'EGP ${(_roomConsumption[_selectedRoomIndex] * 5).toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
      bottomNavigationBar: PowerFlickBottomNavBar(currentIndex: 1),
    );
  }
  
  IconData _getDeviceIcon(String deviceName) {
    switch (deviceName.toLowerCase()) {
      case 'lamp':
      case 'lights':
        return Icons.lightbulb_outline;
      case 'ac':
        return Icons.ac_unit;
      case 'charger':
        return Icons.battery_charging_full;
      case 'tv':
        return Icons.tv;
      case 'console':
        return Icons.gamepad;
      case 'fridge':
        return Icons.kitchen;
      case 'microwave':
        return Icons.microwave;
      case 'coffee maker':
        return Icons.coffee;
      default:
        return Icons.electrical_services;
    }
  }
}

class MultiLayerCircularProgressPainter extends CustomPainter {
  final double progress;

  MultiLayerCircularProgressPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Colors for the three layers - consistent green palette
    final List<Color> colors = [
      const Color(0xFF8BC34A).withOpacity(0.3),  // Lightest - outer circle
      const Color(0xFF8BC34A).withOpacity(0.7),  // Medium - middle circle
      const Color(0xFF4CAF50),                   // Darkest - inner circle
    ];
    
    // Draw background circles
    for (int i = 0; i < 3; i++) {
      final bgPaint = Paint()
        ..color = Colors.grey.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15.0             // Slightly thicker circles
        ..strokeCap = StrokeCap.round;
      
      final layerRadius = radius - (i * 20);  // More spacing between circles
      
      canvas.drawCircle(
        center,
        layerRadius,
        bgPaint,
      );
    }
    
    // Draw progress arcs - for a cleaner look
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15.0             // Matching thickness
        ..strokeCap = StrokeCap.round;
      
      final layerRadius = radius - (i * 20);  // Matching spacing
      
      // Calculate progress for each layer (simple linear progress)
      final layerProgress = progress;
      
      final progressAngle = 2 * pi * layerProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: layerRadius),
        -pi/2, // Start from top
        progressAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 