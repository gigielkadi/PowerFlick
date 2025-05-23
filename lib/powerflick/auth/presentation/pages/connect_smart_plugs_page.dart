import 'package:flutter/material.dart';
import '../../../../core/constants/k_colors.dart';

class ConnectSmartPlugsPage extends StatefulWidget {
  const ConnectSmartPlugsPage({Key? key}) : super(key: key);

  @override
  State<ConnectSmartPlugsPage> createState() => _ConnectSmartPlugsPageState();
}

class _ConnectSmartPlugsPageState extends State<ConnectSmartPlugsPage> {
  bool _isScanning = false;
  List<Map<String, dynamic>> _detectedPlugs = [];

  @override
  void initState() {
    super.initState();
    // Mock plugs for UI preview
    _detectedPlugs = [
      {'name': 'Smart plug -ESP32', 'type': 'Smart Plug', 'connected': false},
      {'name': 'Smart plug ESP32-1', 'type': 'Smart Plug', 'connected': false},
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
      _detectedPlugs[index]['connected'] = !_detectedPlugs[index]['connected'];
    });
  }

  void _connectAllPlugs() {
    // Connect all detected plugs and navigate back
    for (var plug in _detectedPlugs) {
      plug['connected'] = true;
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
            image: AssetImage('assets/illustrations/connect_smart_plug.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    
                    // Header
                    const Center(
                      child: Text(
                        'A click to connect!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // Light gray panel for bottom half
                    Expanded(
                      flex: 6,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              // Scan Button
                              Center(
                                child: GestureDetector(
                                  onTap: _startScanning,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
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
                                                size: 30,
                                              ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _isScanning ? 'Scanning...' : 'Scan Plug',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Detected Plugs Section
                              Row(
                                children: [
                                  Text(
                                    'Detected Plugs',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              const Divider(thickness: 1),
                              
                              // Plugs List
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: _detectedPlugs.length,
                                  itemBuilder: (context, index) {
                                    final plug = _detectedPlugs[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            plug['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade800,
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
                                                  color: plug['connected'] 
                                                      ? KColors.primary 
                                                      : Colors.grey.shade400,
                                                  width: 1,
                                                ),
                                              ),
                                              backgroundColor: plug['connected'] 
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
                                                    color: plug['connected'] 
                                                        ? KColors.primary 
                                                        : Colors.grey.shade800,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 16,
                                                  color: plug['connected'] 
                                                      ? KColors.primary 
                                                      : Colors.grey.shade800,
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
                              
                              // Next Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _connectAllPlugs,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 