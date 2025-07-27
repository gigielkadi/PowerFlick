import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../../home/domain/models/room.dart';
import '../../home/domain/models/device.dart';

class RoomDetailPage extends ConsumerStatefulWidget {
  final String roomName;
  
  const RoomDetailPage({super.key, required this.roomName});

  @override
  ConsumerState<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends ConsumerState<RoomDetailPage> with SingleTickerProviderStateMixin {
  int _selectedRoomIndex = 0;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: roomsAsync.when(
          data: (rooms) => Text(
            rooms.isNotEmpty ? rooms[_selectedRoomIndex].name : '',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          loading: () => const Text('', style: TextStyle(color: Colors.black)),
          error: (e, _) => const Text('', style: TextStyle(color: Colors.black)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
          Widget roomSelector = Container(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 0),
            child: SizedBox(
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
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rooms[index].name,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              height: 3,
                              width: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                roomSelector,
                const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
                const SizedBox(height: 12),
                // All Devices row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Devices',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Text(
                          'New Device',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        label: const Icon(
                          Icons.add,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Device grid
                devicesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (devices) {
                    if (devices.isEmpty) {
                      return const Center(child: Text('No devices in this room'));
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return _buildDeviceItem(device);
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', true),
              _buildNavItem(Icons.devices_outlined, 'Devices', false),
              _buildNavItem(Icons.notifications_outlined, 'Alerts', false),
              _buildNavItem(Icons.settings_outlined, 'Settings', false),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDeviceItem(Device device) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                _getDeviceIcon(device.type),
                size: 40,
                color: Colors.black87,
              ),
              const SizedBox(height: 12),
              Text(
                device.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Switch(
                value: (device.status ?? 'offline') == 'online',
                onChanged: (value) {
                  final rooms = ref.read(roomsProvider).asData?.value ?? [];
                  final selectedRoomId = rooms.isNotEmpty ? rooms[_selectedRoomIndex].id : null;
                  if (selectedRoomId != null) {
                    ref.read(updateDeviceStatusProvider({
                      'deviceId': device.id,
                      'status': value ? 'online' : 'offline',
                      'roomId': selectedRoomId,
                    }));
                  }
                },
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF4CAF50),
                inactiveTrackColor: Colors.grey.shade300,
                inactiveThumbColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
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
      default:
        return Icons.devices_other;
    }
  }
  
  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.black : Colors.grey,
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 