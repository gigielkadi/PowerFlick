import 'package:flutter/material.dart';

/// The welcome page of the app
class WelcomePage extends StatelessWidget {
  /// Creates a [WelcomePage]
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CD964).withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4CD964),
                      width: 3,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Color(0xFF4CD964),
                      size: 50,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Welcome to PowerFlick',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Monitor, manage and optimize your home energy usage with our intelligent platform. Save money while saving the planet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black45,
                  height: 1.5,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Image.asset(
                'assets/illustrations/welcomepagedevice.png',
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 16),
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4CD964),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF4CD964),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Color(0xFF4CD964),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 