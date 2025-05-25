import 'package:flutter/material.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';

class NightModePage extends StatefulWidget {
  const NightModePage({super.key});

  @override
  State<NightModePage> createState() => _NightModePageState();
}

class _NightModePageState extends State<NightModePage> {
  final List<_Device> _devices = [
    _Device('Lamp', Icons.lightbulb_outline),
    _Device('TV', Icons.tv),
    _Device('Washer', Icons.local_laundry_service),
    _Device('AC', Icons.ac_unit),
    _Device('Heater', Icons.fireplace),
    _Device('Add Device', Icons.add),
  ];
  late Set<String> _selected;
  double _lampBrightness = 0.7;

  @override
  void initState() {
    super.initState();
    _selected = _devices.map((d) => d.name).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Night Mode',
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
              'assets/illustrations/night_mode.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),
          // Warm brown overlay for night effect
          Container(
            color: const Color(0xCC3B241C).withOpacity(0.82), // warm brown overlay
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Devices to turn off or dim the lights',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select the devices you want to turn off while you\'re sleeping.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.08,
                      children: _devices.map((device) {
                        final selected = _selected.contains(device.name);
                        if (device.name == 'Lamp') {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selected.remove(device.name);
                                } else {
                                  _selected.add(device.name);
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(selected ? 0.98 : 0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected ? const Color(0xFF4CD964) : Colors.grey.shade300,
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
                                  Icon(device.icon, size: 28, color: selected ? Color(0xFF4CD964) : Colors.black38),
                                  const SizedBox(height: 8),
                                  Text(
                                    device.name,
                                    style: TextStyle(
                                      color: selected ? Color(0xFF4CD964) : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (selected)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0, left: 8, right: 8),
                                      child: Slider(
                                        value: _lampBrightness,
                                        onChanged: (val) {
                                          setState(() {
                                            _lampBrightness = val;
                                          });
                                        },
                                        min: 0.0,
                                        max: 1.0,
                                        activeColor: const Color(0xFF4CD964),
                                        inactiveColor: Colors.grey.shade300,
                                        thumbColor: const Color(0xFF4CD964),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        } else if (device.name == 'Add Device') {
                          return GestureDetector(
                            onTap: () {
                              // TODO: Implement add device action
                            },
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
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selected.remove(device.name);
                                } else {
                                  _selected.add(device.name);
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(selected ? 0.98 : 0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected ? const Color(0xFF4CD964) : Colors.grey.shade300,
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
                                  Icon(device.icon, size: 28, color: selected ? Color(0xFF4CD964) : Colors.black38),
                                  const SizedBox(height: 8),
                                  Text(
                                    device.name,
                                    style: TextStyle(
                                      color: selected ? Color(0xFF4CD964) : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const SizedBox(height: 16),
                ],
              ),
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