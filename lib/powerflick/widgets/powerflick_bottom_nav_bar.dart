import 'package:flutter/material.dart';

class PowerFlickBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const PowerFlickBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 0,
      selectedItemColor: const Color(0xFF4CD964),
      unselectedItemColor: Colors.grey[400],
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      currentIndex: currentIndex,
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else {
          // Default navigation logic
          switch (index) {
            case 0:
              Navigator.of(context).pushNamedAndRemoveUntil('/control-panel', (route) => false);
              break;
            case 1:
              Navigator.of(context).pushNamed('/add-device');
              break;
            case 2:
              // Alerts page (implement route if exists)
              break;
            case 3:
              // Settings page (implement route if exists)
              break;
          }
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.devices_rounded),
          label: 'Devices',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_rounded),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
} 