import 'package:flutter/material.dart';
import '../../../presentation/rooms/room_detail_page.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_providers.dart';
import '../../domain/models/room.dart';

class MyHomePageControl extends ConsumerWidget {
  const MyHomePageControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Home',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (rooms) {
              if (rooms.isEmpty) {
                return const Center(child: Text('No rooms found'));
              }
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: rooms.map((room) => _buildRoomCardWithImage(context, room)).toList(),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: PowerFlickBottomNavBar(currentIndex: 0),
    );
  }
  
  Widget _buildRoomCardWithImage(BuildContext context, Room room) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailPage(roomName: room.name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(room.imageAsset),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
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
                      fontSize: 20,
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
    );
  }
  
  Widget _buildDeviceCard(
    BuildContext context,
    String deviceName,
    String deviceModel,
    IconData deviceIcon,
    bool isOn,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32, // Reduced size slightly
                height: 32, // Reduced size slightly
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  deviceIcon,
                  color: Colors.white,
                  size: 16, // Smaller icon
                ),
              ),
              Transform.scale(
                scale: 0.8, // Make switch slightly smaller
                child: Switch(
                  value: isOn,
                  onChanged: (value) {
                    // Toggle device
                  },
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.grey[700],
                  inactiveThumbColor: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            deviceName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14, // Slightly smaller
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            deviceModel,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12, // Slightly smaller
            ),
          ),
        ],
      ),
    );
  }
} 