import 'package:flutter/material.dart';
import 'dart:math';
import '../../../presentation/rooms/my_rooms_page.dart';
import '../../../widgets/powerflick_bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/home_providers.dart';
import 'package:flutter/services.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Today', 'This week', 'This month'];

  @override
  Widget build(BuildContext context) {
    final totalKwhAsync = ref.watch(totalKwhProvider);
    final userGoalAsync = ref.watch(userGoalProvider);
    final tariffModeAsync = ref.watch(tariffModeProvider);
    final selectedBracketAsync = ref.watch(selectedBracketProvider);
    const double pricePerKwh = 1.2; // EGP per kWh
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          userGoalAsync.when(
            data: (goal) => IconButton(
              icon: const Icon(Icons.flag, color: Colors.green),
              tooltip: 'Set Goal',
              onPressed: () async {
                final totalKwh = await ref.read(totalKwhProvider.future);
                final tariffMode = await ref.read(tariffModeProvider.future);
                final selectedBracket = await ref.read(selectedBracketProvider.future);
                double pricePerKwh = await getPricePerKwh(
                  mode: tariffMode,
                  manualBracket: selectedBracket,
                  usageKwh: totalKwh,
                );
                double kwhValue = goal;
                double egpValue = kwhValue * pricePerKwh;
                int bracketIndex = selectedBracket;
                TariffMode mode = tariffMode;
                bool byKwh = true;
                await showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.7),
                  builder: (context) {
                    final kwhController = TextEditingController(text: kwhValue.toStringAsFixed(2));
                    final egpController = TextEditingController(text: egpValue.toStringAsFixed(2));
                    return StatefulBuilder(
                      builder: (context, setState) {
                        void updateFromKwh(String value) {
                          final kwh = double.tryParse(value) ?? 0;
                          kwhValue = kwh;
                          egpValue = kwh * pricePerKwh;
                          egpController.text = egpValue.toStringAsFixed(2);
                        }
                        void updateFromEgp(String value) {
                          final egp = double.tryParse(value) ?? 0;
                          egpValue = egp;
                          kwhValue = pricePerKwh > 0 ? egp / pricePerKwh : 0;
                          kwhController.text = kwhValue.toStringAsFixed(2);
                        }
                        void updatePrice() async {
                          pricePerKwh = await getPricePerKwh(
                            mode: mode,
                            manualBracket: bracketIndex,
                            usageKwh: totalKwh,
                          );
                          if (byKwh) {
                            egpValue = kwhValue * pricePerKwh;
                            egpController.text = egpValue.toStringAsFixed(2);
                          } else {
                            kwhValue = pricePerKwh > 0 ? egpValue / pricePerKwh : 0;
                            kwhController.text = kwhValue.toStringAsFixed(2);
                          }
                          setState(() {});
                        }
                        return Dialog(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Set Consumption Goal',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Goal type toggle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _StyledChip(
                                      label: 'By kWh',
                                      selected: byKwh,
                                      onTap: () => setState(() => byKwh = true),
                                      green: true,
                                    ),
                                    const SizedBox(width: 8),
                                    _StyledChip(
                                      label: 'By EGP',
                                      selected: !byKwh,
                                      onTap: () => setState(() => byKwh = false),
                                      green: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                // Input fields
                                if (byKwh)
                                  _StyledTextField(
                                    controller: kwhController,
                                    label: 'Goal (kWh)',
                                    onChanged: (v) => setState(() => updateFromKwh(v)),
                                    green: true,
                                  )
                                else
                                  _StyledTextField(
                                    controller: egpController,
                                    label: 'Goal (EGP)',
                                    onChanged: (v) => setState(() => updateFromEgp(v)),
                                    green: true,
                                  ),
                                const SizedBox(height: 14),
                                // Tariff mode toggle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _StyledChip(
                                      label: 'Auto',
                                      selected: mode == TariffMode.auto,
                                      onTap: () {
                                        setState(() {
                                          mode = TariffMode.auto;
                                          updatePrice();
                                        });
                                      },
                                      green: true,
                                    ),
                                    const SizedBox(width: 8),
                                    _StyledChip(
                                      label: 'Manual',
                                      selected: mode == TariffMode.manual,
                                      onTap: () {
                                        setState(() {
                                          mode = TariffMode.manual;
                                          updatePrice();
                                        });
                                      },
                                      green: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                // Bracket dropdown (if manual)
                                if (mode == TariffMode.manual)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF00FF99), width: 2),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        dropdownColor: Colors.black,
                                        value: bracketIndex,
                                        items: List.generate(residentialBrackets.length, (i) {
                                          final b = residentialBrackets[i];
                                          return DropdownMenuItem(
                                            value: i,
                                            child: Text(
                                              '${b['label']} - EGP ${b['price']}',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          );
                                        }),
                                        onChanged: (i) {
                                          if (i != null) {
                                            setState(() {
                                              bracketIndex = i;
                                              updatePrice();
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 14),
                                // Price per kWh display
                                Center(
                                  child: Text(
                                    'Price per kWh: EGP ${pricePerKwh.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        textStyle: const TextStyle(fontSize: 16),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await ref.read(setUserGoalProvider(kwhValue).future);
                                        await ref.read(setTariffModeProvider(mode).future);
                                        await ref.read(setSelectedBracketProvider(bracketIndex).future);
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF00E676),
                                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: userGoalAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (maxConsumption) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // Tab buttons - more compact
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == index ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                border: _selectedTabIndex == index 
                                    ? Border.all(color: const Color(0xFFE0E0E0), width: 1)
                                    : null,
                                boxShadow: _selectedTabIndex == index
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _tabs[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selectedTabIndex == index ? FontWeight.w600 : FontWeight.w400,
                                  color: _selectedTabIndex == index ? const Color(0xFF4CAF50) : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Energy Consumption Circle - smaller size
                  totalKwhAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (totalKwh) {
                      final percent = maxConsumption > 0 ? (totalKwh / maxConsumption).clamp(0, 1).toDouble() : 0.0;
                      final minArc = 0.01; // 1% minimum arc
                      final displayPercent = (percent > 0 && percent < minArc) ? minArc : percent;
                      final costEstimation = totalKwh * pricePerKwh;
                      return Center(
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Circle progress
                              CustomPaint(
                                size: const Size(180, 180),
                                painter: CircularProgressPainter(
                                  progress: displayPercent,
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                              
                              // Center content
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Energy icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.bolt,
                                      color: Color(0xFF4CAF50),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Percentage text
                                  Text(
                                    '${(percent * 100).toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Energy value
                                  Text(
                                    '${totalKwh.toStringAsFixed(2)} kWh',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'of $maxConsumption kWh',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Cost Estimation
                  totalKwhAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (totalKwh) {
                      final costEstimation = totalKwh * pricePerKwh;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cost Estimation',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                          Text(
                            'EGP ${costEstimation.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Monitor section - more compact
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.analytics_outlined,
                                  color: Color(0xFF4CAF50),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Monitor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6E7787),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildMonitorItem('Cost Estimation', 'EGP 52'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ),
                          _buildMonitorItem('CO₂ Emissions', '5.4 kg'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ),
                          _buildMonitorItem(
                            'Compared to Yesterday',
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.withOpacity(0.1),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.arrow_upward,
                                    size: 10,
                                    color: Colors.red,
                                  ),
                                ),
                                const Text(
                                  ' +8% or ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.arrow_downward,
                                    size: 10,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                                const Text(
                                  ' -3%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Activities section - more compact with horizontal layout
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                color: Color(0xFF4CAF50),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Activities',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6E7787),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // Activities cards in a row
                        Expanded(
                          child: Row(
                            children: [
                              // View Rooms button
                              Expanded(
                                child: _buildActivityCard(
                                  'View Rooms',
                                  Icons.meeting_room,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => const MyRoomsPage()),
                                    );
                                  },
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // View History button
                              Expanded(
                                child: _buildActivityCard(
                                  'View History',
                                  Icons.history,
                                  onTap: () {
                                    // TODO: Navigate to History page
                                  },
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF616161), Color(0xFF9E9E9E)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: PowerFlickBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildMonitorItem(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF3C3C3C),
          ),
        ),
        if (value is String)
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3C3C3C),
            ),
          )
        else
          value,
      ],
    );
  }

  Widget _buildActivityCard(
    String text, 
    IconData icon, 
    {required VoidCallback onTap, required Gradient gradient}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final paintBg = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius - 12,
      paintBg,
    );

    // Draw progress arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      center: Alignment.center,
      startAngle: -pi / 2,
      endAngle: 2 * pi - pi / 2,
      colors: [
        color.withOpacity(0.7),
        color,
      ],
      stops: const [0.0, 1.0],
      transform: GradientRotation(-pi / 2 + progress * 2 * pi / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final progressAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 12),
      -pi / 2, // Start from top
      progressAngle,
      false,
      paint,
    );

    // Draw dots around circle
    final dotPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    const numberOfDots = 30; // Fewer dots
    const dotRadius = 1.5; // Smaller dots
    for (int i = 0; i < numberOfDots; i++) {
      final angle = (2 * pi / numberOfDots) * i;
      final dotX = center.dx + (radius - 12) * cos(angle);
      final dotY = center.dy + (radius - 12) * sin(angle);

      canvas.drawCircle(
        Offset(dotX, dotY),
        dotRadius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StyledChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool green;
  const _StyledChip({required this.label, required this.selected, required this.onTap, this.green = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF181818) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF00E676) : Colors.white24, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF00E676) : const Color(0xFFEFEFEF),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final bool green;
  const _StyledTextField({required this.controller, required this.label, required this.onChanged, this.green = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: green ? const Color(0xFF00E676) : Colors.white24, width: 2),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          isDense: true,
          fillColor: Colors.black,
          filled: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        cursorColor: const Color(0xFF00E676),
      ),
    );
  }
} 