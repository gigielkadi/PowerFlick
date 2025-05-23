import 'package:flutter/material.dart';
import '../../../presentation/rooms/room_detail_page.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';

class MyHomePageControl extends StatelessWidget {
  const MyHomePageControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Rooms Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildRoomCardWithImage(
                    context,
                    'Bedroom',
                    'assets/illustrations/bedrom.png',
                  ),
                  _buildRoomCardWithImage(
                    context,
                    'Kitchen',
                    'assets/illustrations/kitchen.png',
                  ),
                  _buildRoomCardWithImage(
                    context,
                    'Bathroom',
                    'assets/illustrations/bathroom.png',
                  ),
                  _buildRoomCardWithImage(
                    context,
                    'Living Room',
                    'assets/illustrations/living_room.png',
                  ),
                ],
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
                      // Navigate to all devices
                    },
                    child: Row(
                      children: const [
                        Text(
                          'All Devices',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Quick Access Devices - Fixed height container to avoid overflow
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 120, // Increased height to avoid overflow
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDeviceCard(
                          context,
                          'Smart TV',
                          'QLED 4K',
                          Icons.tv,
                          true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDeviceCard(
                          context,
                          'Non Smart Fridge',
                          'LG GTF402SVAN',
                          Icons.kitchen,
                          false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Add extra padding at the bottom to ensure we don't have overflow with bottom navigation
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PowerFlickBottomNavBar(currentIndex: 0),
    );
  }
  
  Widget _buildRoomCardWithImage(BuildContext context, String name, String imagePath) {
    return GestureDetector(
      onTap: () {
        // Navigate to room details with the correct room selected
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailPage(roomName: name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
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
                    name,
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