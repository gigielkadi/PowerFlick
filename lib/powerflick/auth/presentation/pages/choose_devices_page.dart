import 'package:flutter/material.dart';

class ChooseDevicesPage extends StatelessWidget {
  const ChooseDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = [
      {'name': 'Lamp', 'image': 'assets/devices/lamp.png'},
      {'name': 'Charger', 'image': 'assets/devices/charger.png'},
      {'name': 'Computer', 'image': 'assets/devices/computer.png'},
      {'name': 'AC', 'image': 'assets/devices/ac.png'},
      {'name': 'Lights', 'image': 'assets/devices/lights.png'},
      {'name': 'Fan', 'image': 'assets/devices/fan.png'},
      {'name': 'Stove', 'image': 'assets/devices/stove.png'},
      {'name': 'Water Dispenser', 'image': 'assets/devices/water_dispenser.png'},
      {'name': 'Water', 'image': 'assets/devices/water.png'},
      {'name': 'Speakers', 'image': 'assets/devices/speakers.png'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Choose devices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Text(
                    'New Device',
                    style: TextStyle(
                      color: Color(0xFFFFB300),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  label: const Icon(
                    Icons.add,
                    color: Color(0xFFFFB300),
                    size: 20,
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: devices.map((device) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: device['image'] != null
                                    ? Image.asset(device['image']!, fit: BoxFit.contain)
                                    : const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                device['name']!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.check_box_outline_blank, size: 18, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 