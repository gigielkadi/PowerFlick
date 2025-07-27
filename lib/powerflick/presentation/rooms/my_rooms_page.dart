import 'package:flutter/material.dart';
import 'dart:math';
import '../../widgets/powerflick_bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../../home/domain/models/room.dart';
import '../../home/domain/models/device.dart';

class MyRoomsPage extends ConsumerStatefulWidget {
  const MyRoomsPage({super.key});

  @override
  ConsumerState<MyRoomsPage> createState() => _MyRoomsPageState();
}

class _MyRoomsPageState extends ConsumerState<MyRoomsPage> {
  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final selectedRoomIndex = ref.watch(selectedRoomIndexProvider);

    print('Rooms Async Type: ${roomsAsync.runtimeType}');
    print('Rooms Async State: ${roomsAsync.isLoading}, ${roomsAsync.hasError}, ${roomsAsync.hasValue}');

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
          child: roomsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) {
              print('Rooms Async Error: $e');
              return Center(child: Text('Error: $e'));
            },
            data: (rooms) {
              print('Rooms Data Type: ${rooms.runtimeType}');
              print('Number of rooms: ${rooms.length}');
              if (rooms.isEmpty) {
                return const Center(child: Text('No rooms found'));
              }
              // Ensure selected index is valid for current rooms list
              if (selectedRoomIndex >= rooms.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(selectedRoomIndexProvider.notifier).setSelectedRoomIndex(0);
                });
              }
              final validIndex = selectedRoomIndex >= rooms.length ? 0 : selectedRoomIndex;
              final selectedRoom = rooms[validIndex];

              // Watch the combined devices and power readings provider
              final devicesAndReadingsAsync = ref.watch(combinedDevicesAndPowerReadingsProvider(selectedRoom.id));
              final allDevicesAsync = ref.watch(allDevicesProvider);

              return RefreshIndicator(
                onRefresh: () async {
                  // Refresh all relevant providers
                  ref.invalidate(roomsProvider);
                  ref.invalidate(allDevicesProvider);
                  ref.invalidate(combinedDevicesAndPowerReadingsProvider(selectedRoom.id));
                  
                  // Wait a moment for the refresh to complete
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200, // Ensure scrollable area
                    child: _buildRoomContent(rooms, validIndex, devicesAndReadingsAsync, allDevicesAsync),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const PowerFlickBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildRoomContent(
    List<Room> rooms, 
    int validIndex, 
    AsyncValue<(List<Device>, List<Map<String, dynamic>>)> devicesAndReadingsAsync,
    AsyncValue<List<Device>> allDevicesAsync,
  ) {
    // Room tabs (always visible)
    final roomTabs = Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(rooms.length, (index) {
            final isSelected = validIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedRoomIndexProvider.notifier).setSelectedRoomIndex(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rooms[index].name,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.black54,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );

    // Main content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        roomTabs,
        const SizedBox(height: 30),
        // Devices and readings
        Expanded(
          child: devicesAndReadingsAsync.when(
            loading: () => _RoomStatsPlaceholder(),
            error: (e, _) => Center(child: Text('Error loading data: $e')),
            data: (data) {
              final devices = data.$1;
              final powerReadings = data.$2;
              final latestPowerReadings = { for (var reading in powerReadings) reading['device_id'] as String : reading['power_watts'] as double };
              
              // Calculate room total energy using device.totalPower
              final roomTotalFromDevices = devices.fold<double>(0, (sum, d) => sum + d.totalPower);
              
              // Use allDevicesAsync to calculate all rooms' total energy
              return allDevicesAsync.when(
                loading: () => _RoomStatsPlaceholder(),
                error: (e, _) => Center(child: Text('Error loading all devices: $e')),
                data: (allDevices) {
                  // Calculate total home energy from all devices' totalPower
                  final allRoomsTotalFromDevices = allDevices.fold<double>(0, (sum, d) => sum + d.totalPower);
                  
                  // Use the devices' totalPower as the primary source of truth
                  final roomTotalEnergy = roomTotalFromDevices;
                  final allRoomsTotalEnergy = allRoomsTotalFromDevices;
                  
                  // Calculate percentage based on total_power from devices
                  final percentage = allRoomsTotalEnergy > 0 ? (roomTotalEnergy / allRoomsTotalEnergy).clamp(0, 1).toDouble() : 0.0;
                  final minArc = 0.01;
                  final displayPercent = (percentage > 0 && percentage < minArc) ? minArc : percentage;
                  
                  // Calculate cost based on Egyptian electricity tariff brackets
                  // Use progressive pricing based on total home usage
                  double getPriceForUsage(double usageKwh) {
                    if (usageKwh <= 50) return 0.68;
                    if (usageKwh <= 100) return 0.78;
                    if (usageKwh <= 200) return 0.95;
                    if (usageKwh <= 350) return 1.55;
                    if (usageKwh <= 650) return 1.95;
                    if (usageKwh <= 1000) return 2.10;
                    return 2.30;
                  }
                  
                  final pricePerKwh = getPriceForUsage(allRoomsTotalEnergy);
                  final totalCost = roomTotalEnergy * pricePerKwh;
                  
                  // Enhanced debug information with data validation
                  print('=== ROOM POWER CALCULATION DEBUG ===');
                  print('Room: ${rooms[validIndex].name}');
                  print('Room devices count: ${devices.length}');
                  print('Room devices total_power: ${devices.map((d) => '${d.name}: ${d.totalPower.toStringAsFixed(3)} kWh').join(', ')}');
                  print('Room total energy: ${roomTotalEnergy.toStringAsFixed(3)} kWh');
                  print('All devices count: ${allDevices.length}');
                  print('All devices total_power sum: ${allRoomsTotalEnergy.toStringAsFixed(3)} kWh');
                  print('Room percentage: ${(percentage * 100).toStringAsFixed(2)}%');
                  print('Price per kWh: EGP ${pricePerKwh.toStringAsFixed(2)}');
                  print('Room cost: EGP ${totalCost.toStringAsFixed(2)}');
                  
                  // Data validation warnings
                  if (allRoomsTotalEnergy == 0 && allDevices.isNotEmpty) {
                    print('⚠️  WARNING: All devices have 0 total_power - database trigger may not be working correctly');
                    print('   This means room percentages will show 0%. Check if power readings are updating total_power.');
                  }
                  
                  if (roomTotalEnergy == 0 && devices.isNotEmpty) {
                    print('⚠️  WARNING: Room devices have 0 total_power - no energy data available for this room');
                  }
                  
                  final devicesWithZeroPower = devices.where((d) => d.totalPower == 0).length;
                  if (devicesWithZeroPower > 0) {
                    print('ℹ️  INFO: ${devicesWithZeroPower}/${devices.length} devices in this room have 0 total_power');
                  }
                  
                  print('=====================================');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular indicator and stats
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
                                  Text(
                                    '${(percentage * 100).toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${roomTotalEnergy.toStringAsFixed(2)} kWh',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'of total home usage',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  if (allRoomsTotalEnergy == 0 && allDevices.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'No energy data',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Cost estimation row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cost Estimation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              totalCost >= 1.0 
                                ? 'EGP ${totalCost.toStringAsFixed(2)}'
                                : totalCost >= 0.01
                                  ? 'EGP ${totalCost.toStringAsFixed(3)}'
                                  : 'EGP ${totalCost.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Devices section
                      if (devices.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              'No devices in this room',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              final currentPower = latestPowerReadings[device.id] ?? 0.0;
                              return _buildDeviceCard(device, currentPower);
                            },
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(Device device, double currentPower) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getDeviceIcon(device.type),
              color: const Color(0xFF4CAF50),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            device.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${currentPower.toStringAsFixed(1)} W',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${device.totalPower.toStringAsFixed(2)} kWh',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                ),
              ),
              if (device.totalPower == 0)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 12,
                    color: Colors.orange.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'tv':
        return Icons.tv;
      case 'ac':
        return Icons.ac_unit;
      case 'light':
      case 'lights':
      case 'lamp':
        return Icons.lightbulb_outline;
      case 'fridge':
        return Icons.kitchen;
      case 'fan':
        return Icons.mode_fan_off;
      case 'computer':
        return Icons.computer;
      case 'microwave':
        return Icons.microwave;
      case 'oven':
        return Icons.kitchen;
      case 'charger':
        return Icons.battery_charging_full;
      case 'speaker':
        return Icons.speaker;
      case 'console':
        return Icons.games;
      case 'coffee maker':
        return Icons.coffee;
      case 'water heater':
        return Icons.water_drop;
      default:
        return Icons.electrical_services;
    }
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
      startAngle: -pi / 2,
      endAngle: 2 * pi - pi / 2,
      colors: [
        color.withOpacity(0.7),
        color,
      ],
      stops: const [0.0, 1.0],
      transform: GradientRotation(-pi / 2 + progress * 2 * pi / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final progressAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 12),
      -pi / 2, // Start from top
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

// Placeholder widget for loading/empty state
class _RoomStatsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    progress: 0.0,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '0.00%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -1.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '0.00 kWh',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'of total home usage',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Cost Estimation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            Text(
              'EGP 0.0',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(child: Text('No devices in this room')),
        ),
      ],
    );
  }
} 