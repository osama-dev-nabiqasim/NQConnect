import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/utils/responsive.dart';

class SplashVariant1 extends StatefulWidget {
  const SplashVariant1({super.key});
  @override
  State<SplashVariant1> createState() => _SplashVariant1State();
}

class _SplashVariant1State extends State<SplashVariant1> {
  final logos = [
    'assets/images/NQLogo.png',
    'assets/images/EtdcLogo.png',
    'assets/images/PplLogo.png',
    'assets/images/SplLogo.png',
    'assets/images/SurgeLogo.png',
  ];
  int index = 0;

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  void _cycle() async {
    for (var i = 0; i < logos.length; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => index = i);
    }
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Get.offNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 5), // slow gradient transition
        builder: (context, t, _) {
          // interpolate between background → primary colors
          final gradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(
                AppColors.backgroundColor.first,
                AppColors.primaryColor.first,
                t,
              )!,
              Color.lerp(
                AppColors.backgroundColor.last,
                AppColors.primaryColor.last,
                t,
              )!,
            ],
          );

          return Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: AnimatedScale(
                  key: ValueKey(index),
                  duration: const Duration(milliseconds: 800),
                  scale: 1.2,
                  child: Image.asset(logos[index], width: 200),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
