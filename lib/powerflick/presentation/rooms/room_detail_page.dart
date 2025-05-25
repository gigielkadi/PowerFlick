import 'package:flutter/material.dart';

class RoomDetailPage extends StatefulWidget {
  final String roomName;
  
  const RoomDetailPage({super.key, required this.roomName});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentRoom;
  
  final List<String> rooms = ['Bedroom', 'Living Room', 'Kitchen', 'Bathroom'];

  @override
  void initState() {
    super.initState();
    _currentRoom = widget.roomName;
    _tabController = TabController(
      length: rooms.length,
      vsync: this,
      initialIndex: rooms.indexOf(_currentRoom),
    );
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentRoom = rooms[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_currentRoom, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF4CAF50),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF4CAF50),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: rooms.map((room) => Tab(text: room)).toList(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: rooms.map((room) {
                  return _buildRoomDevices(room);
                }).toList(),
              ),
            ),
          ],
        ),
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
  
  Widget _buildRoomDevices(String roomName) {
    List<Map<String, dynamic>> devices = _getDevicesForRoom(roomName);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  ),
                ),
                label: const Icon(
                  Icons.add,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return _buildDeviceItem(
                devices[index]['name'],
                devices[index]['icon'],
                devices[index]['isOn'],
                devices[index]['hasSlider'],
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeviceItem(String name, IconData icon, bool isOn, bool hasSlider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  _getDeviceImage(name),
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      icon,
                      size: 30,
                      color: Colors.black54,
                    );
                  },
                ),
                Switch(
                  value: isOn,
                  onChanged: (value) {},
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF4CAF50),
                  inactiveTrackColor: Colors.grey.shade300,
                  inactiveThumbColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasSlider)
              SizedBox(
                height: 30,
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: const Color(0xFF4CAF50),
                    activeTrackColor: const Color(0xFF4CAF50),
                    inactiveTrackColor: Colors.grey.shade200,
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: 0.7,
                    onChanged: (value) {},
                  ),
                ),
              ),
          ],
        ),
      ),
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
  
  String _getDeviceImage(String name) {
    switch (name.toLowerCase()) {
      case 'lamp':
        return 'assets/illustrations/lamp.png';
      case 'charger':
        return 'assets/illustrations/charger.png';
      case 'computer':
        return 'assets/illustrations/computer.png';
      case 'ac':
        return 'assets/illustrations/ac.png';
      case 'lights':
        return 'assets/illustrations/lights.png';
      default:
        return '';
    }
  }
  
  List<Map<String, dynamic>> _getDevicesForRoom(String roomName) {
    switch (roomName) {
      case 'Bedroom':
        return [
          {'name': 'Lamp', 'icon': Icons.lightbulb_outline, 'isOn': true, 'hasSlider': true},
          {'name': 'Charger', 'icon': Icons.electrical_services, 'isOn': true, 'hasSlider': false},
          {'name': 'Computer', 'icon': Icons.computer, 'isOn': false, 'hasSlider': false},
          {'name': 'AC', 'icon': Icons.ac_unit, 'isOn': true, 'hasSlider': false},
          {'name': 'Lights', 'icon': Icons.light, 'isOn': true, 'hasSlider': true},
        ];
      case 'Living Room':
        return [
          {'name': 'TV', 'icon': Icons.tv, 'isOn': true, 'hasSlider': false},
          {'name': 'Lights', 'icon': Icons.light, 'isOn': true, 'hasSlider': true},
          {'name': 'AC', 'icon': Icons.ac_unit, 'isOn': false, 'hasSlider': false},
        ];
      case 'Kitchen':
        return [
          {'name': 'Fridge', 'icon': Icons.kitchen, 'isOn': true, 'hasSlider': false},
          {'name': 'Lights', 'icon': Icons.light, 'isOn': true, 'hasSlider': true},
          {'name': 'Microwave', 'icon': Icons.microwave, 'isOn': false, 'hasSlider': false},
        ];
      case 'Bathroom':
        return [
          {'name': 'Lights', 'icon': Icons.light, 'isOn': true, 'hasSlider': true},
          {'name': 'Water Heater', 'icon': Icons.hot_tub, 'isOn': false, 'hasSlider': false},
        ];
      default:
        return [];
    }
  }
} 