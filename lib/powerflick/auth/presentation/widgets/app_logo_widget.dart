import 'package:flutter/material.dart';

/// Widget that displays the PowerFlick app logo
class AppLogoWidget extends StatelessWidget {
  /// Creates an [AppLogoWidget]
  const AppLogoWidget({
    super.key,
    this.size = 120.0,
  });

  /// The size of the logo widget
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF35D06A).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Outer gradient ring
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD0FF52), // Light green
                  Color(0xFF35D06A), // Primary green
                ],
              ),
            ),
          ),
          // White ring
          Padding(
            padding: EdgeInsets.all(size * 0.05),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          // Black center
          Padding(
            padding: EdgeInsets.all(size * 0.1),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: Center(
                child: Icon(
                  Icons.bolt,
                  color: const Color(0xFF35D06A),
                  size: size * 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 