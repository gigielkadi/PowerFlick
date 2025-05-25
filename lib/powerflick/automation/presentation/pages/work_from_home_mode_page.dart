import 'package:flutter/material.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';

class WorkFromHomeModePage extends StatefulWidget {
  const WorkFromHomeModePage({super.key});

  @override
  State<WorkFromHomeModePage> createState() => _WorkFromHomeModePageState();
}

class _WorkFromHomeModePageState extends State<WorkFromHomeModePage> {
  final List<_Device> _devices = [
    _Device('Computer', Icons.desktop_windows),
    _Device('Printer', Icons.print),
    _Device('Lamp', Icons.lightbulb_outline),
    _Device('Wi-Fi', Icons.wifi),
    _Device('Computer', Icons.laptop_mac),
    _Device('Add Device', Icons.add),
  ];
  late Map<String, bool> _deviceStates;

  @override
  void initState() {
    super.initState();
    _deviceStates = {for (var d in _devices) d.name: true};
    _deviceStates['Add Device'] = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Work From Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image (if available)
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/work_from_home_mode.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF222222)),
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.55),
          ),
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Optimize your home office',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose the devices to enable while you are working',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.05,
                      children: _devices.map((device) {
                        if (device.name == 'Add Device') {
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add, size: 28, color: Colors.black26),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Device',
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(_deviceStates[device.name]! ? 0.98 : 0.85),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _deviceStates[device.name]! ? const Color(0xFF4CD964) : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(device.icon, size: 28, color: _deviceStates[device.name]! ? Color(0xFF4CD964) : Colors.black38),
                                const SizedBox(height: 8),
                                Text(
                                  device.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _deviceStates[device.name]! ? Color(0xFF4CD964) : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Switch(
                                  value: _deviceStates[device.name]!,
                                  onChanged: (val) {
                                    setState(() {
                                      _deviceStates[device.name] = val;
                                    });
                                  },
                                  activeColor: const Color(0xFF4CD964),
                                ),
                              ],
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CD964),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PowerFlickBottomNavBar(currentIndex: 0),
    );
  }
}

class _Device {
  final String name;
  final IconData icon;
  _Device(this.name, this.icon);
} 