import 'package:flutter/material.dart';
import 'room_detail_page.dart';
import '../../widgets/powerflick_bottom_nav_bar.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              // Rooms Grid with fixed dimensions
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                childAspectRatio: 1.0,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildRoomCard(context, 'Bedroom', 'assets/illustrations/bedrom.png'),
                  _buildRoomCard(context, 'Kitchen', 'assets/illustrations/kitchen.png'),
                  _buildRoomCard(context, 'Bathroom', 'assets/illustrations/bathroom.png'),
                  _buildRoomCard(context, 'Living Room', 'assets/illustrations/living_room.png'),
                ],
              ),
              
              const SizedBox(height: 40),
              
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
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Text(
                      'All Devices',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    label: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Quick Access Devices
              Row(
                children: [
                  Expanded(
                    child: _buildDeviceCard(
                      'TV',
                      'QLED 4K',
                      'Samsung',
                      Icons.tv,
                      true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDeviceCard(
                      'Fridge',
                      'LG GTF402SVAN',
                      'LG',
                      Icons.kitchen,
                      false,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 120), // Add space at bottom for tab bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: PowerFlickBottomNavBar(currentIndex: 1),
    );
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
  
  Widget _buildRoomCard(BuildContext context, String roomName, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailPage(roomName: roomName),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Add a gradient overlay to ensure text visibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Row(
                children: [
                  Text(
                    roomName,
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
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDeviceCard(String type, String model, String brand, IconData deviceIcon, bool isSmartDevice) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  deviceIcon,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              // Custom Switch that looks exactly like the screenshot
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSmartDevice ? null : const Color(0xFF444444),
                    ),
                    child: isSmartDevice 
                      ? Stack(
                          children: [
                            // Green track instead of gold
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(0xFF4CAF50).withOpacity(0.4),
                              ),
                            ),
                            // Green thumb instead of gold
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            // Grey track (already set in parent)
                            // White thumb
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSmartDevice ? 'Smart $type' : 'Non Smart $type',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  model,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 