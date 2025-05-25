import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_providers.dart';
import '../../domain/models/room.dart';
import 'room_page.dart';

class RoomsListPage extends ConsumerWidget {
  const RoomsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("RoomsListPage is being built");
    final roomsAsyncValue = ref.watch(roomsProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rooms', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: roomsAsyncValue.when(
            data: (rooms) => _buildRoomsList(context, rooms),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading rooms: $error'),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoomsList(BuildContext context, List<Room> rooms) {
    // Define device counts (in a real app, this would come from your data)
    final Map<String, int> deviceCounts = {
      'Living Room': 3,
      'Kitchen': 4,
      'Bedroom': 2,
      'Bathroom': 1,
    };
    
    // Define icons for each room type
    final Map<String, IconData> roomIcons = {
      'Living Room': Icons.weekend,
      'Kitchen': Icons.kitchen,
      'Bedroom': Icons.bed,
      'Bathroom': Icons.bathtub,
    };
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.home,
                    color: Colors.indigo.shade400,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Rooms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...rooms.map((room) {
              // Get device count or default to 0
              final deviceCount = deviceCounts[room.name] ?? 0;
              // Get icon or default to a generic icon
              final icon = roomIcons[room.name] ?? Icons.home;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomPage(roomId: room.id),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: Colors.indigo.shade400,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${room.name} ($deviceCount)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
} 