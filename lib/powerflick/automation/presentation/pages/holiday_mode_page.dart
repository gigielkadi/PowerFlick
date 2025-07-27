import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/domain/models/room.dart';
import '../../../home/domain/models/device.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';

// Provider for Holiday Mode automation state
final holidayModeStateProvider = StateProvider<bool>((ref) => false);

class HolidayModePage extends ConsumerStatefulWidget {
  const HolidayModePage({super.key});

  @override
  ConsumerState<HolidayModePage> createState() => _HolidayModePageState();
}

class _HolidayModePageState extends ConsumerState<HolidayModePage> {
  int _selectedRoomIndex = 0;
  Set<String> _selectedDeviceIds = {};

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final isHolidayModeOn = ref.watch(holidayModeStateProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Devices to Turn On', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(child: Text('No rooms found'));
          }
          final selectedRoom = rooms[_selectedRoomIndex];
          final devicesAsync = ref.watch(roomDevicesProvider(selectedRoom.id));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room selector
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedRoomIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRoomIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            rooms[index].name,
                            style: TextStyle(
                              color: isSelected ? Colors.green : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Devices grid
              Expanded(
                child: devicesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (devices) {
                    if (devices.isEmpty) {
                      return const Center(child: Text('No devices found'));
                    }
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16),
                      childAspectRatio: 0.95,
                      children: devices.map((device) {
                        final isSelected = _selectedDeviceIds.contains(device.id);
                        return GestureDetector(
                          onTap: isHolidayModeOn
                              ? () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedDeviceIds.remove(device.id);
                                    } else {
                                      _selectedDeviceIds.add(device.id);
                                    }
                                  });
                                }
                              : null,
                          child: Opacity(
                            opacity: isHolidayModeOn ? 1.0 : 0.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green[100] : Colors.white,
                                border: Border.all(
                                  color: isSelected ? Colors.green : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.devices, size: 36, color: isSelected ? Colors.green : Colors.grey[600]),
                                    const SizedBox(height: 12),
                                    Text(
                                      device.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isSelected ? Colors.green[900] : Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              // Done button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isHolidayModeOn
                        ? () async {
                            final devices = await ref.read(roomDevicesProvider(selectedRoom.id).future);
                            for (final device in devices) {
                              final shouldBeOnline = _selectedDeviceIds.contains(device.id);
                              await ref.read(updateDeviceStatusProvider({
                                'deviceId': device.id,
                                'status': shouldBeOnline ? 'online' : 'offline',
                                'roomId': selectedRoom.id,
                              }).future);
                            }
                            // Optionally show a success message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Device statuses updated!')),
                              );
                              // Navigate back to Automation page
                              Navigator.pop(context);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHolidayModeOn ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const PowerFlickBottomNavBar(currentIndex: 0),
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'lamp':
        return Icons.lightbulb_outline;
      case 'ac':
        return Icons.ac_unit;
      case 'charger':
        return Icons.electrical_services;
      case 'computer':
        return Icons.computer;
      case 'fridge':
        return Icons.kitchen;
      case 'microwave':
        return Icons.microwave;
      case 'coffee maker':
        return Icons.coffee;
      case 'tv':
        return Icons.tv;
      case 'fan':
        return Icons.toys;
      case 'lights':
        return Icons.light;
      case 'washer':
        return Icons.local_laundry_service;
      case 'kitchen':
        return Icons.kitchen;
      default:
        return Icons.devices_other;
    }
  }
} 