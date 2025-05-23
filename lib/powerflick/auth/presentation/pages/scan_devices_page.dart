import 'package:flutter/material.dart';
import '../../../../core/constants/k_colors.dart';

class ScanDevicesPage extends StatefulWidget {
  const ScanDevicesPage({Key? key}) : super(key: key);

  @override
  State<ScanDevicesPage> createState() => _ScanDevicesPageState();
}

class _ScanDevicesPageState extends State<ScanDevicesPage> {
  bool _isScanning = false;
  List<Map<String, dynamic>> _detectedDevices = [];

  @override
  void initState() {
    super.initState();
    // Mock devices for UI preview
    _detectedDevices = [
      {'name': 'LG-SeriesX2900', 'type': 'TV', 'connected': false},
      {'name': 'QLED C3 Series', 'type': 'TV', 'connected': false},
      {'name': 'InstaView ThinQ LFXS2596S', 'type': 'Refrigerator', 'connected': false},
      {'name': 'Profile PTW700BSTWS', 'type': 'Washer', 'connected': false},
    ];
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    // In a real app, this would be an actual device scanning process
    // For now, we'll just simulate scanning with a timer
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isScanning = false;
      });
    });
  }

  void _toggleConnection(int index) {
    setState(() {
      _detectedDevices[index]['connected'] = !_detectedDevices[index]['connected'];
    });
  }

  void _connectAllDevices() {
    // Connect all detected devices and navigate back
    for (var device in _detectedDevices) {
      device['connected'] = true;
    }
    
    // In a real app, you would save this information to a database
    
    // Go back to home setup page
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/illustrations/scan_devices.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Scan Devices',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(flex: 1),
                
                // Scan Button
                Center(
                  child: GestureDetector(
                    onTap: _startScanning,
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: _isScanning
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: KColors.primary,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Icon(
                                  Icons.wifi,
                                  color: KColors.primary,
                                  size: 40,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning ? 'Scanning...' : 'Tap to scan',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Detected Devices Section
                const Text(
                  'Detected Devices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                const Divider(color: Colors.white24, thickness: 1),
                
                // Devices List
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _detectedDevices.length,
                    itemBuilder: (context, index) {
                      final device = _detectedDevices[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              device['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _toggleConnection(index),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, 
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(
                                    color: device['connected'] 
                                        ? KColors.primary 
                                        : Colors.white54,
                                    width: 1,
                                  ),
                                ),
                                backgroundColor: device['connected'] 
                                    ? KColors.primary.withOpacity(0.1) 
                                    : Colors.transparent,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Connect to',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: device['connected'] 
                                          ? KColors.primary 
                                          : Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: device['connected'] 
                                        ? KColors.primary 
                                        : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _connectAllDevices,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Next',
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
} 