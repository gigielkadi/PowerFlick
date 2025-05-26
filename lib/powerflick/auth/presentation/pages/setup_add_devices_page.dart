import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/k_colors.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/domain/models/room.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetupAddDevicesPage extends ConsumerStatefulWidget {
  const SetupAddDevicesPage({super.key});

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
      {'name': 'Fridge', 'selected': false, 'count': 1},
      {'name': 'Lamp', 'selected': false, 'count': 1},
      {'name': 'Fan', 'selected': false, 'count': 1},
    ],
    'Living Room': [
      {'name': 'TV', 'selected': false, 'count': 1},
      {'name': 'Speaker', 'selected': false, 'count': 1},
      {'name': 'Lamp', 'selected': false, 'count': 1},
    ],
    'Kitchen': [
      {'name': 'Microwave', 'selected': false, 'count': 1},
      {'name': 'Oven', 'selected': false, 'count': 1},
      {'name': 'Fridge', 'selected': false, 'count': 1},
    ],
    'Bathroom': [
      {'name': 'Water Heater', 'selected': false, 'count': 1},
      {'name': 'Lamp', 'selected': false, 'count': 1},
    ],
  };

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initTabs(List<Room> rooms) {
    if (_tabController == null || _tabController!.length != rooms.length) {
      _tabController?.dispose();
      _tabController = TabController(length: rooms.length, vsync: this);
      _rooms = rooms;
      // Initialize roomDevices for each room
      _roomDevices = {
        for (final room in rooms)
          room.id: _presetDevices[room.name] != null
              ? _presetDevices[room.name]!.map((d) => Map<String, dynamic>.from(d)).toList()
              : []
      };
      setState(() {});
    }
  }

  Future<void> _saveDevicesToDb() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final supabase = Supabase.instance.client;
    for (final room in _rooms) {
      final devices = _roomDevices[room.id] ?? [];
      for (final device in devices) {
        if (device['selected'] == true) {
          await supabase.from('devices').upsert({
            'name': device['name'],
            'type': device['name'],
            'room_id': room.id,
            'user_id': user.id,
            'metadata': {'count': device['count']},
          });
        }
      }
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/illustrations/home_setup.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Welcome, Gigi',
                      style: TextStyle(
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
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                // Device name
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: device['selected'],
                                        onChanged: (val) {
                                          setState(() {
                                            device['selected'] = val;
                                          });
                                        },
                                        checkColor: Colors.white,
                                        activeColor: KColors.primary,
                                      ),
                                      Text(
                                        device['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Counter
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          if (device['count'] > 1) device['count']--;
                                        });
                                      },
                                    ),
                                    Text(
                                      '${device['count']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          device['count']++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _saveDevicesToDb();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Devices saved successfully!')),
                            );
                            Navigator.pop(context);
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
                    const SizedBox(height: 8),
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