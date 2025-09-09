// ignore_for_file: unused_import, use_super_parameters, library_private_types_in_public_api

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/utils/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentLogoIndex = 0;

  final List<String> _logoPaths = [
    'assets/images/NQLogo.png',
    'assets/images/EtdcLogo.JPG',
    'assets/images/PplLogo.JPG',
    'assets/images/SplLogo.JPG',
    'assets/images/SurgeLogo.JPG',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000), // Slower animation
      vsync: this,
    );

    // Start logo sequence
    _startLogoSequence();

    // Navigate after all animations
    Future.delayed(Duration(milliseconds: 3200), () {
      if (mounted) {
        Get.offNamed('/login');
      }
    });
  }

  void _startLogoSequence() async {
    for (int i = 0; i < _logoPaths.length; i++) {
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Slower transition
      if (mounted) {
        setState(() {
          _currentLogoIndex = i;
        });
      }
      // Restart animation for each logo
      _controller.reset();
      _controller.forward();

      // Wait for this logo to complete before showing next
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundColor,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.3, 0.7],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main animated logo with better effects
              _buildMainLogoAnimation(),

              SizedBox(height: 0),

              // App name with better animation
              _buildAppName(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainLogoAnimation() {
    return SizedBox(
      width: Responsive.width(context) * 1,
      height: Responsive.height(context) * 0.5,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(_logoPaths.length, (index) {
          final position = _calculateLogoPosition(index);
          return AnimatedPositioned(
            duration: const Duration(
              milliseconds: 300,
            ), // Very fast position change
            curve: Curves.easeOut,
            left: position.dx,
            top: position.dy,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250), // Very fast opacity
              opacity: _currentLogoIndex == index ? 1.0 : 0.4,
              child: Transform.scale(
                scale: _currentLogoIndex == index
                    ? 1.15
                    : 0.8, // Less extreme scaling
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentLogoIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _currentLogoIndex == index
                              ? Colors.blueAccent.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: _currentLogoIndex == index ? 12 : 6,
                          spreadRadius: _currentLogoIndex == index ? 2 : 0.5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      _logoPaths[index],
                      width: Responsive.width(context) * 0.2,
                      height: Responsive.height(context) * 0.04,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Offset _calculateLogoPosition(int index) {
    final centerX = Responsive.width(context) * 0.4;
    final centerY = Responsive.height(context) * 0.2;
    final radius = Responsive.width(context) * 0.3;

    final angle = 2 * 3.1416 * index / _logoPaths.length;
    return Offset(centerX + radius * cos(angle), centerY + radius * sin(angle));
  }

  Widget _buildAppName() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: 1.0, // Always visible
      child: const Text(
        'NQ Connect',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 1.2,
          shadows: [
            Shadow(blurRadius: 10, color: Colors.white, offset: Offset(2, 2)),
          ],
        ),
      ),
    );
  }
}
