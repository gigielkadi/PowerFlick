import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_colors.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/domain/models/room.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetupAddDevicesPage extends ConsumerStatefulWidget {
  final String? userName;
  const SetupAddDevicesPage({super.key, this.userName});

  @override
  ConsumerState<SetupAddDevicesPage> createState() => _SetupAddDevicesPageState();
}

class _SetupAddDevicesPageState extends ConsumerState<SetupAddDevicesPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Room> _rooms = [];
  Map<String, List<Map<String, dynamic>>> _roomDevices = {};
  final Map<String, List<Map<String, dynamic>>> _presetDevices = {
    'Bedroom': [
      {'name': 'AC', 'selected': false, 'count': 1},
      {'name': 'Lamp', 'selected': false, 'count': 1},
      {'name': 'Fan', 'selected': false, 'count': 1},
      {'name': 'Charger', 'selected': false, 'count': 1},
      {'name': 'Computer', 'selected': false, 'count': 1},
      {'name': 'Lights', 'selected': false, 'count': 1},
    ],
    'Living room': [
      {'name': 'TV', 'selected': false, 'count': 1},
      {'name': 'Speaker', 'selected': false, 'count': 1},
      {'name': 'Lamp', 'selected': false, 'count': 1},
      {'name': 'Console', 'selected': false, 'count': 1},
      {'name': 'Lights', 'selected': false, 'count': 1},
      {'name': 'AC', 'selected': false, 'count': 1},
    ],
    'Kitchen': [
      {'name': 'Microwave', 'selected': false, 'count': 1},
      {'name': 'Oven', 'selected': false, 'count': 1},
      {'name': 'Fridge', 'selected': false, 'count': 1},
      {'name': 'Coffee Maker', 'selected': false, 'count': 1},
      {'name': 'Lights', 'selected': false, 'count': 1},
    ],
    'Bathroom': [
      {'name': 'Water Heater', 'selected': false, 'count': 1},
      {'name': 'Lamp', 'selected': false, 'count': 1},
      {'name': 'Lights', 'selected': false, 'count': 1},
    ],
    'Custom': [
      {'name': 'Lamp', 'selected': false, 'count': 1},
      {'name': 'Fan', 'selected': false, 'count': 1},
      {'name': 'AC', 'selected': false, 'count': 1},
      {'name': 'TV', 'selected': false, 'count': 1},
      {'name': 'Fridge', 'selected': false, 'count': 1},
      {'name': 'Microwave', 'selected': false, 'count': 1},
      {'name': 'Oven', 'selected': false, 'count': 1},
      {'name': 'Speaker', 'selected': false, 'count': 1},
      {'name': 'Computer', 'selected': false, 'count': 1},
      {'name': 'Charger', 'selected': false, 'count': 1},
      {'name': 'Coffee Maker', 'selected': false, 'count': 1},
      {'name': 'Water Heater', 'selected': false, 'count': 1},
      {'name': 'Console', 'selected': false, 'count': 1},
    ],
  };

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  int _countDevicesOfType(String roomId, String deviceType) {
    return _roomDevices[roomId]?.where((device) => device['type'] == deviceType).length ?? 0;
  }

  void _initTabs(List<Room> rooms) {
    if (_tabController == null || _tabController!.length != rooms.length) {
      _tabController?.dispose();
      _tabController = TabController(length: rooms.length, vsync: this);
      _rooms = rooms;
      // Initialize roomDevices for each room
      _roomDevices = {
        for (final room in rooms)
          room.id: []
      };
      setState(() {});
    }
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
      case 'smart plug':
        return Icons.power;
      default:
        return Icons.devices_other;
    }
  }

  void _showAddDeviceDialog(String roomId) {
    String? selectedDeviceType;
    int deviceCount = 1;
    final List<String> deviceTypes = [
      'Air Conditioner', 'Lamp', 'Fan', 'Charger', 'Computer', 'Lights', 'TV', 'Speaker',
      'Game Console', 'Microwave', 'Oven', 'Refrigerator', 'Coffee Maker',
      'Water Heater', 'Smart Plug', 'Heater', 'Security Camera', 'Smart Lock',
      'Thermostat', 'Vacuum Cleaner', 'Air Purifier', 'Humidifier', 'Dehumidifier',
      'Smart Garden', 'Robot Vacuum'
    ]; // Example list of device types

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9), // Semi-transparent dark background
          title: const Text('Add Device'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure elements stretch to fill width
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Device Type',
                      labelStyle: TextStyle(color: Colors.white), // Label text color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                        borderSide: BorderSide(color: KColors.primary.withOpacity(0.8)), // Primary color border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: KColors.primary.withOpacity(0.6)), // Slightly transparent border when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: KColors.primary), // Primary color border when focused
                      ),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.6), // Add a dark background to the input field
                    ),
                    value: selectedDeviceType,
                    items: deviceTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type, style: TextStyle(color: Colors.white)), // Make item text readable in dropdown list
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDeviceType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (deviceCount > 1) deviceCount--;
                          });
                        },
                      ),
                      Text(
                        '$deviceCount',
                        style: const TextStyle(fontSize: 18, color: Colors.white), // Count text color
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            deviceCount++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white), // Cancel button text color
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (selectedDeviceType != null) {
                  setState(() {
                    // Add individual device entries for the specified count and generate names
                    for (int i = 0; i < deviceCount; i++) {
                      String deviceName = deviceCount > 1 ? '${selectedDeviceType!}${i + 1}' : selectedDeviceType!;
                      _roomDevices[roomId]!.add({
                        'name': deviceName,
                        'type': selectedDeviceType!,
                        'count': 1, // Each entry represents one device
                        'selected': true,
                      });
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(foregroundColor: KColors.primary), // Add button text color
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDevicesToDb() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final supabase = Supabase.instance.client;
    List<Map<String, dynamic>> devicesToInsert = [];
    for (final room in _rooms) {
      final devices = _roomDevices[room.id] ?? [];
      for (final device in devices) {
        if (device['selected'] == true) {
          devicesToInsert.add({
            'name': device['name'],
            'type': device['type'],
            'room_id': room.id,
            'user_id': user.id,
            'metadata': {},
          });
        }
      }
    }
    if (devicesToInsert.isNotEmpty) {
      await supabase.from('devices').insert(devicesToInsert);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    return Scaffold(
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(child: Text('No rooms found', style: TextStyle(color: Colors.white)));
          }
          _initTabs(rooms);
          final currentRoomIdx = _tabController?.index ?? 0;
          final currentRoom = rooms[currentRoomIdx];
          final devices = _roomDevices[currentRoom.id] ?? [];
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(currentRoom.imageAsset),
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Welcome, ${widget.userName ?? "User"}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Add your devices',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      tabs: rooms.map((room) => Tab(text: room.name)).toList(),
                      onTap: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentRoom.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.white.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    // Device List
                    Expanded(
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  // Device Icon
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: KColors.primary.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getDeviceIcon(device['type']),
                                      color: KColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Device name
                                  Expanded(
                                    child: Text(
                                      '${device['name']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  // Remove button
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() {
                                        _roomDevices[currentRoom.id]!.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add Device Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAddDeviceDialog(currentRoom.id);
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                        label: const Text(
                          'Add Device',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: KColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add a Smart Plug button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final connectedPlugs = await Navigator.pushNamed(
                            context, 
                            '/connect-smart-plugs',
                            arguments: currentRoom.id,
                          ) as List<Map<String, dynamic>>?;
                          if (connectedPlugs != null) {
                            setState(() {
                              // Add connected smart plugs to the current room's devices
                              _roomDevices[currentRoom.id]!.addAll(connectedPlugs);
                            });
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                        label: const Text(
                          'Add a Smart Plug',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: KColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final currentRoomIdx = _tabController?.index ?? 0;
                          if (currentRoomIdx < _rooms.length - 1) {
                            // Move to the next room tab
                            _tabController?.animateTo(currentRoomIdx + 1);
                            setState(() {}); // Trigger a rebuild to show the next room's devices
                          } else {
                            // Last room, save devices and navigate to subscription plan
                            await _saveDevicesToDb();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Devices saved successfully!')),
                              );
                              Navigator.pushReplacementNamed(context, '/subscription-plan');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 