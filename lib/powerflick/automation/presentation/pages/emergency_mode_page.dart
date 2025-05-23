import 'package:flutter/material.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';

class EmergencyModePage extends StatefulWidget {
  const EmergencyModePage({Key? key}) : super(key: key);

  @override
  State<EmergencyModePage> createState() => _EmergencyModePageState();
}

class _EmergencyModePageState extends State<EmergencyModePage> {
  final List<_Device> _devices = [
    _Device('Lights', Icons.lightbulb_outline),
    _Device('EV Charger', Icons.ev_station),
    _Device('High-Power Appliances', Icons.bolt),
    _Device('Add Device', Icons.add),
  ];
  late Set<String> _selected;
  bool _autoActivate = true;

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
          'Emergency Mode',
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
              'assets/illustrations/emergency_mode.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.7),
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
                      children: [
                        // Red cut-off button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.flash_on, color: Colors.white, size: 22),
                            label: const Text(
                              'Cut Off Electricity From Whole House.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Control how your system behaves during an emergency.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Devices to turn off immediately',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.08,
                      children: _devices.map((device) {
                        final selected = _selected.contains(device.name);
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(device.icon, size: 28, color: selected ? Color(0xFF4CD964) : Colors.black38),
                                  const SizedBox(height: 8),
                                  Text(
                                    device.name,
                                    textAlign: TextAlign.center,
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
                  const SizedBox(height: 24),
                  // Auto-activate card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Auto-Activate During Power Outage',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Switch(
                                value: _autoActivate,
                                onChanged: (val) {
                                  setState(() {
                                    _autoActivate = val;
                                  });
                                },
                                activeColor: const Color(0xFF4CD964),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Automatically enable emergency mode when power is lost',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
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