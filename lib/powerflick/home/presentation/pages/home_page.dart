import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rooms Grid
              roomsAsyncValue.when(
                data: (rooms) => _buildRoomsGrid(context, rooms),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading rooms: $error'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quick Access Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6E7787),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all devices page
                    },
                    child: Row(
                      children: const [
                        Text(
                          'All Devices',
                          style: TextStyle(
                            color: Color(0xFFFF9500),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Color(0xFFFF9500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Quick Access Devices
              quickAccessDevicesAsyncValue.when(
                data: (devices) => _buildQuickAccessDevices(context, ref, devices),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading devices: $error'),
                ),
              ),
            ],
          ),
        ),
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
  
  Widget _buildRoomsGrid(BuildContext context, List<Room> rooms) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: rooms.map((room) => _buildRoomCard(context, room)).toList(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/rooms');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade100,
            foregroundColor: Colors.indigo.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('View all rooms'),
        ),
      ],
    );
  }
  
  Widget _buildRoomCard(BuildContext context, Room room) {
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
              image: AssetImage(room.imageUrl),
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
                child: Row(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickAccessDevices(BuildContext context, WidgetRef ref, List<Device> devices) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: devices.map((device) => _buildDeviceCard(context, ref, device)).toList(),
    );
  }
  
  Widget _buildDeviceCard(BuildContext context, WidgetRef ref, Device device) {
    // Determine icon based on device type
    IconData deviceIcon = Icons.device_unknown;
    switch (device.type) {
      case 'tv':
        deviceIcon = Icons.tv;
        break;
      case 'fridge':
        deviceIcon = Icons.kitchen;
        break;
      case 'light':
        deviceIcon = Icons.lightbulb_outline;
        break;
      case 'ac':
        deviceIcon = Icons.ac_unit;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                deviceIcon,
                color: Colors.white70,
                size: 28,
              ),
              Switch(
                value: device.isOn,
                onChanged: (value) {
                  // Toggle device power
                  ref.read(toggleDevicePowerProvider(
                    ToggleDeviceParams(
                      deviceId: device.id,
                      isOn: value,
                    )
                  ));
                },
                activeColor: device.isSmart ? Colors.amber : Colors.white,
              ),
            ],
          ),
          const Spacer(),
          Text(
            device.isSmart ? 'Smart ${device.type.toUpperCase()}' : 'Non Smart ${device.type.toUpperCase()}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${device.brand} ${device.model}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 