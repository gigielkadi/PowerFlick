import 'package:flutter/material.dart';
import '../../../../core/constants/k_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'scan_devices_page.dart';
import 'connect_smart_plugs_page.dart';

class HomeSetupPage extends StatefulWidget {
  final String? userName;

  const HomeSetupPage({super.key, this.userName});

  @override
  State<HomeSetupPage> createState() => _HomeSetupPageState();
}

class _HomeSetupPageState extends State<HomeSetupPage> {
  final List<Map<String, dynamic>> _roomTypes = [
    {'name': 'Bedroom', 'icon': Icons.bed, 'selected': true, 'count': 2},
    {'name': 'Living room', 'icon': Icons.weekend, 'selected': true, 'count': 1},
    {'name': 'Kitchen', 'icon': Icons.kitchen, 'selected': false, 'count': 1},
    {'name': 'Bathroom', 'icon': Icons.bathtub, 'selected': false, 'count': 1},
    {'name': 'Custom', 'icon': Icons.add, 'selected': false, 'count': 1},
  ];

  List<Map<String, dynamic>> _selectedRooms = [];

  @override
  void initState() {
    super.initState();
    // Initialize selected rooms based on default values
    _updateSelectedRooms();
    
    // In a real app, you would fetch user data here
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      // Attempt to fetch user data from Supabase
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          final response = await Supabase.instance.client
            .from('profiles')
            .select('name, rooms')
            .eq('id', user.id)
            .single();
          
          if (mounted) {
            print('Fetched user data: $response');
            
            // If there's existing room data, update the UI
            if (response['rooms'] != null) {
              final List<dynamic> savedRooms = response['rooms'];
              if (savedRooms.isNotEmpty) {
                setState(() {
                  // Reset all rooms to unselected
                  for (var room in _roomTypes) {
                    room['selected'] = false;
                    room['count'] = 1;
                  }
                  
                  // Update with saved room data
                  for (var savedRoom in savedRooms) {
                    final index = _roomTypes.indexWhere(
                      (room) => room['name'] == savedRoom['type']
                    );
                    
                    if (index != -1) {
                      _roomTypes[index]['selected'] = true;
                      _roomTypes[index]['count'] = savedRoom['count'];
                    }
                  }
                  
                  _updateSelectedRooms();
                });
              }
            }
          }
        } catch (e) {
          print('Error fetching profile data: $e');
        }
      }
      
      // For testing, we'll just use the provided userName or default
      print('Fetched user data for: ${widget.userName ?? "Gigi"}');
    } catch (e) {
      print('Error in _fetchUserData: $e');
    }
  }

  void _updateSelectedRooms() {
    _selectedRooms = _roomTypes
        .where((room) => room['selected'])
        .map((room) => {...room})
        .toList();
  }

  void _toggleRoomSelection(int index) {
    setState(() {
      _roomTypes[index]['selected'] = !_roomTypes[index]['selected'];
      _updateSelectedRooms();
    });
  }

  void _incrementRoomCount(int index) {
    setState(() {
      _roomTypes[index]['count']++;
      _updateSelectedRooms();
    });
  }

  void _decrementRoomCount(int index) {
    if (_roomTypes[index]['count'] > 1) {
      setState(() {
        _roomTypes[index]['count']--;
        _updateSelectedRooms();
      });
    }
  }

  void _saveHomeSetup() async {
    // Create a list of rooms to save
    final List<Map<String, dynamic>> roomsToSave = _selectedRooms
        .map((room) => {
              'type': room['name'],
              'count': room['count'],
            })
        .toList();

    try {
      // Save room data to Supabase
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          // First update the homes table
          await Supabase.instance.client.from('homes').upsert({
            'user_id': user.id,
            'rooms': roomsToSave,
          });
          
          // Also update the rooms array in the profiles table
          await Supabase.instance.client.from('profiles').update({
            'rooms': roomsToSave,
          }).eq('id', user.id);
          
          print('Rooms saved to database: $roomsToSave');
        } catch (e) {
          // Log the error but continue with navigation
          print('Error saving to database: $e');
        }
      } else {
        // For demo purposes when not logged in
        print('Demo mode: Saving rooms to database: $roomsToSave');
      }

      // Navigate to control panel regardless of database success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Home setup completed!')),
        );
        // Use pushReplacementNamed to ensure proper navigation
        Navigator.pushReplacementNamed(context, '/control-panel');
      }
    } catch (e) {
      print('Error in home setup: $e');
      // Still try to navigate even if there's an error
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/control-panel');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/illustrations/home_setup.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 10),
                Text(
                  'Welcome, ${widget.userName ?? "Gigi"}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Lets set up your home',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Rooms & Zones Section
                const Text(
                  'Rooms & Zones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Tell us which rooms your home includes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Selected Room Tags - improved to match design and prevent overflow
                SizedBox(
                  height: _selectedRooms.isEmpty ? 0 : 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedRooms.length,
                    itemBuilder: (context, index) {
                      final room = _selectedRooms[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(room['icon'], size: 16, color: Colors.black87),
                              const SizedBox(width: 6),
                              Text(
                                room['count'] > 1 
                                    ? '${room['name']} (${room['count']})'
                                    : room['name'],
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  int idx = _roomTypes.indexWhere((r) => r['name'] == room['name']);
                                  if (idx != -1) {
                                    _toggleRoomSelection(idx);
                                  }
                                },
                                child: const Icon(Icons.close, size: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Room Selection Table - updated to match design
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Header Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Text(
                                  'Room Type',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Button',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Divider(height: 1, thickness: 1),
                        
                        // Room List
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: _roomTypes.length,
                            itemBuilder: (context, index) {
                              final room = _roomTypes[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Row(
                                  children: [
                                    // Room type info
                                    Expanded(
                                      flex: 4,
                                      child: Row(
                                        children: [
                                          Icon(room['icon'], color: Colors.black54, size: 20),
                                          const SizedBox(width: 10),
                                          Text(
                                            room['name'],
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Checkbox and Counter
                                    SizedBox(
                                      width: 110,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Checkbox - updated to match design
                                          GestureDetector(
                                            onTap: () => _toggleRoomSelection(index),
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4),
                                                color: room['selected'] ? KColors.primary : Colors.transparent,
                                                border: Border.all(
                                                  color: room['selected'] ? KColors.primary : Colors.grey.shade300,
                                                  width: 2,
                                                ),
                                              ),
                                              child: room['selected']
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          
                                          // Counter
                                          if (room['selected'])
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Minus button
                                                  SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () => _decrementRoomCount(index),
                                                        customBorder: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.grey.shade300),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Icon(
                                                            Icons.remove,
                                                            size: 14,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  
                                                  // Count
                                                  SizedBox(
                                                    width: 22,
                                                    child: Center(
                                                      child: Text(
                                                        '${room['count']}',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  
                                                  // Plus button
                                                  SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () => _incrementRoomCount(index),
                                                        customBorder: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.grey.shade300),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 14,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Smart Devices & Appliances heading
                const Text(
                  'Smart Devices & Appliances',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Scan Devices Button
                _buildActionButton(
                  title: 'Scan Devices',
                  subtitle: 'Connect smart devices automatically',
                  icon: Icons.wifi,
                  iconColor: KColors.primary,
                  onTap: () {
                    // Navigate to scan devices page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanDevicesPage(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Connect Smart Plugs Button
                _buildActionButton(
                  title: 'Connect Smart Plugs',
                  subtitle: 'Connect non-smart devices',
                  icon: Icons.power_outlined,
                  iconColor: KColors.primary,
                  onTap: () {
                    // Navigate to connect smart plugs page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConnectSmartPlugsPage(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveHomeSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
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
      ),
    );
  }
  
  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.green,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 