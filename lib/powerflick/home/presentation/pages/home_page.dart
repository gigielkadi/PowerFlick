import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/home_providers.dart';
import '../../domain/models/room.dart';
import '../../domain/models/device.dart';
import 'room_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsyncValue = ref.watch(roomsProvider);
    final quickAccessDevicesAsyncValue = ref.watch(quickAccessDevicesProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Home', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: roomsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading rooms: $error')),
        data: (rooms) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRoomCardWithDevices(context, ref, rooms[index]),
                    childCount: rooms.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.grey[700],
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_outlined),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoomCardWithDevices(BuildContext context, WidgetRef ref, Room room) {
    final devicesAsyncValue = ref.watch(roomDevicesProvider(room.id));
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomPage(roomId: room.id),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(room.imageAsset),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    devicesAsyncValue.when(
                      loading: () => const SizedBox(
                        height: 32,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      ),
                      error: (error, stack) => Text('Error loading devices: $error', style: TextStyle(color: Colors.red)),
                      data: (devices) {
                        if (devices.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: devices.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, idx) {
                              final device = devices[idx];
                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(_getDeviceIcon(device.type), color: Colors.white, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          device.name,
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'ac':
        return Icons.ac_unit;
      case 'lamp':
        return Icons.lightbulb_outline;
      case 'fan':
        return Icons.toys;
      case 'charger':
        return Icons.power;
      case 'computer':
        return Icons.computer;
      case 'lights':
        return Icons.light_mode;
      case 'tv':
        return Icons.tv;
      case 'speaker':
        return Icons.speaker;
      case 'console':
        return Icons.sports_esports;
      case 'microwave':
        return Icons.microwave;
      case 'oven':
        return Icons.kitchen;
      case 'fridge':
        return Icons.kitchen_outlined;
      case 'coffee maker':
        return Icons.coffee;
      case 'water heater':
        return Icons.hot_tub;
      case 'stove':
        return Icons.local_fire_department;
      case 'water dispenser':
        return Icons.water;
      case 'speakers':
        return Icons.speaker_group;
      default:
        return Icons.devices_other;
    }
  }
} 