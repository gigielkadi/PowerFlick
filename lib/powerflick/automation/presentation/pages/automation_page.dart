import 'package:flutter/material.dart';
import 'holiday_mode_page.dart';
import 'night_mode_page.dart';
import 'emergency_mode_page.dart';
import 'work_from_home_mode_page.dart';

class AutomationPage extends StatefulWidget {
  const AutomationPage({Key? key}) : super(key: key);

  @override
  State<AutomationPage> createState() => _AutomationPageState();
}

class _AutomationPageState extends State<AutomationPage> {
  final List<_AutomationMode> _modes = [
    _AutomationMode(
      icon: Icons.flight,
      iconBg: const Color(0xFFEAF5EA),
      title: 'Holiday Mode',
      description: "Turns off non essentials while you're away.",
      enabled: false,
    ),
    _AutomationMode(
      icon: Icons.nightlight,
      iconBg: const Color(0xFFF3F0FA),
      title: 'Night Mode',
      description: 'Dims lights, powers down entertainment, enables nightlights.',
      enabled: false,
    ),
    _AutomationMode(
      icon: Icons.warning_amber_rounded,
      iconBg: const Color(0xFFFFEAEA),
      title: 'Emergency Mode',
      description: 'Cuts power to risky devices, sends alerts.',
      enabled: true,
    ),
    _AutomationMode(
      icon: Icons.eco,
      iconBg: const Color(0xFFEAF5EA),
      title: 'Eco Mode',
      description: 'Maximizes energy efficiency using smart schedules.',
      enabled: false,
    ),
    _AutomationMode(
      icon: Icons.laptop_mac,
      iconBg: const Color(0xFFEAF3FF),
      title: 'Work-from Home Mode',
      description: 'Powers workspace devices only.',
      enabled: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const appGreen = Color(0xFF4CD964); // Use the app's primary green
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Automation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: _modes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final mode = _modes[index];
            return GestureDetector(
              onTap: () {
                if (mode.title == 'Holiday Mode') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HolidayModePage(),
                    ),
                  );
                } else if (mode.title == 'Night Mode') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NightModePage(),
                    ),
                  );
                } else if (mode.title == 'Emergency Mode') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EmergencyModePage(),
                    ),
                  );
                } else if (mode.title == 'Work-from Home Mode') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WorkFromHomeModePage(),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: mode.iconBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(mode.icon, color: Colors.black87, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: mode.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(text: '  '),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: Icon(Icons.edit, size: 15, color: Color(0xFFFFB300)),
                                        ),
                                        const TextSpan(text: ' '),
                                        TextSpan(
                                          text: 'Edit',
                                          style: TextStyle(
                                            color: Color(0xFFFFB300),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mode.description,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Transform.scale(
                        scale: 1.1,
                        child: Switch(
                          value: mode.enabled,
                          onChanged: (val) {
                            setState(() {
                              _modes[index] = mode.copyWith(enabled: val);
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: appGreen,
                          inactiveThumbColor: const Color(0xFFB0B3AE),
                          inactiveTrackColor: const Color(0xFFE0E0E0),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AutomationMode {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String description;
  final bool enabled;

  _AutomationMode({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.enabled,
  });

  _AutomationMode copyWith({bool? enabled}) => _AutomationMode(
        icon: icon,
        iconBg: iconBg,
        title: title,
        description: description,
        enabled: enabled ?? this.enabled,
      );
} 