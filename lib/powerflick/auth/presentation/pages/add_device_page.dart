import 'package:flutter/material.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/constants/k_colors.dart';

class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/illustrations/devices.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken), // Darken the image
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: KSize.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: KSize.xxl),
                const Text(
                  'Connect Your Device',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // Changed text color to white
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: KSize.lg),
                Text(
                  'Add your first smart device to start monitoring your energy usage',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70, // Changed text color to white70
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: KSize.xxl),
                // Keep the image asset or replace if needed for the new design
                Image.asset(
                  'assets/illustrations/house.png', // Consider updating this image as well
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () {
                      // TODO: Implement device setup
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: KColors.primary, // Use primary color for button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Set Up Device',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: KSize.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 