import 'package:flutter/material.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';

class HolidayModePage extends StatefulWidget {
  const HolidayModePage({Key? key}) : super(key: key);

  @override
  State<HolidayModePage> createState() => _HolidayModePageState();
}

class _HolidayModePageState extends State<HolidayModePage> {
  final List<_Device> _devices = [
    _Device('Lamp', Icons.lightbulb_outline),
    _Device('TV', Icons.tv),
    _Device('Washer', Icons.local_laundry_service),
    _Device('AC', Icons.ac_unit),
    _Device('Kitchen', Icons.kitchen),
    _Device('Computer', Icons.laptop_mac),
  ];
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    // All devices ON by default
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
          'Holiday Mode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/holiday_mode.png',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay
          Container(
            color: Colors.black.withOpacity(0.18),
          ),
          // Content
          SafeArea(
            child: Stack(
              children: [
                // Title and subtitle positioned in the empty space above the grid
                Positioned(
                  left: 16,
                  right: 16,
                  top: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 32),
                      Text(
                        'Devices to Turn Off',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select the devices you want to turn off while you\'re away.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Grid and button at the bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.95,
                          children: _devices.map((device) {
                            final selected = _selected.contains(device.name);
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
                                  color: selected
                                      ? const Color(0xFFE8FCEB)
                                      : Colors.white.withOpacity(0.82),
                                  borderRadius: BorderRadius.circular(14),
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
                                        color: selected ? Color(0xFF4CD964) : Colors.black54,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
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