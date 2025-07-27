import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/k_colors.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';
import '../pages/add_more_devices_page.dart';

class ChooseDevicesPage extends StatefulWidget {
  const ChooseDevicesPage({super.key});

  @override
  State<ChooseDevicesPage> createState() => _ChooseDevicesPageState();
}

class _ChooseDevicesPageState extends State<ChooseDevicesPage> {
  List<Map<String, dynamic>> _devices = [];
  bool _loading = true;
  Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final response = await Supabase.instance.client
          .from('devices')
          .select()
          .eq('user_id', user.id);
      setState(() {
        _devices = List<Map<String, dynamic>>.from(response);
        // Sort devices: online devices first
        _devices.sort((a, b) {
          final statusA = a['status'] ?? 'offline';
          final statusB = b['status'] ?? 'offline';
          if (statusA == 'online' && statusB != 'online') {
            return -1; // a comes before b
          } else if (statusA != 'online' && statusB == 'online') {
            return 1; // b comes before a
          } else {
            return 0; // maintain relative order if both are online or offline
          }
        });
        _selectedIndexes = _devices
            .asMap()
            .entries
            .where((entry) => entry.value['status'] == 'online')
            .map((entry) => entry.key)
            .toSet();
        _loading = false;
      });
    } catch (e) {
      print('Error fetching devices: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateDeviceStatus(int index, bool isSelected) async {
    if (index < 0 || index >= _devices.length) return;

    final device = _devices[index];
    final deviceId = device['id']; // Assuming 'id' is the device ID column
    final newStatus = isSelected ? 'online' : 'offline';

    try {
      await Supabase.instance.client
          .from('devices')
          .update({'status': newStatus})
          .eq('id', deviceId);

      // Update the local state after successful database update
      setState(() {
        _devices[index]['status'] = newStatus;
        if (isSelected) {
          _selectedIndexes.add(index);
        } else {
          _selectedIndexes.remove(index);
        }
      });

    } catch (e) {
      // Handle error, e.g., show a SnackBar
      print('Error updating device status: $e');
    }
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'ac':
        return Icons.ac_unit;
      case 'lamp':
        return Icons.lightbulb_outline;
      case 'fan':
        return Icons.toys;
      case 'charger':
        return Icons.power;
      case 'computer':
        return Icons.computer;
      case 'lights':
        return Icons.light_mode;
      case 'tv':
        return Icons.tv;
      case 'speaker':
        return Icons.speaker;
      case 'console':
        return Icons.sports_esports;
      case 'microwave':
        return Icons.microwave;
      case 'oven':
        return Icons.kitchen;
      case 'fridge':
        return Icons.kitchen_outlined;
      case 'coffee maker':
        return Icons.coffee;
      case 'water heater':
        return Icons.hot_tub;
      case 'stove':
        return Icons.local_fire_department;
      case 'water dispenser':
        return Icons.water;
      case 'speakers':
        return Icons.speaker_group;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add device',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/illustrations/devices.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose devices',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddMoreDevicesPage(),
                        ),
                      );
                      if (result == true) {
                        _fetchDevices();
                      }
                    },
                    icon: const Text(
                      'New Device',
                      style: TextStyle(
                        color: Color(0xFFFFB300),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    label: const Icon(
                      Icons.add,
                      color: Color(0xFFFFB300),
                      size: 22,
                    ),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _devices.isEmpty
                        ? const Center(child: Text('No devices found'))
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              final device = _devices[index];
                              final selected = device['status'] == 'online'; // Determine selected based on status
                              return GestureDetector(
                                onTap: () {
                                  final isSelected = !selected; // Toggle based on current status
                                  _updateDeviceStatus(index, isSelected); // Call the update function
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  decoration: BoxDecoration(
                                    color: selected ? KColors.primary.withOpacity(0.12) : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected ? KColors.primary : Colors.grey.shade200,
                                      width: selected ? 2.5 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _getDeviceIcon(device['type'] ?? ''),
                                              size: 48,
                                              color: selected ? KColors.primary : Colors.grey[800],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              device['name'] ?? device['type'] ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: selected ? KColors.primary : Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: selected ? KColors.primary : Colors.white,
                                            border: Border.all(
                                              color: selected ? KColors.primary : Colors.grey.shade300,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            selected ? Icons.check_box : Icons.check_box_outline_blank,
                                            size: 20,
                                            color: selected ? Colors.white : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PowerFlickBottomNavBar(
        currentIndex: 1, // Assuming this page corresponds to the 'Devices' tab
      ),
    );
  }
} 