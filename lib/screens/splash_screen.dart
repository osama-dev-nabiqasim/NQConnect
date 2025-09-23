import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/utils/responsive.dart';
import 'package:particles_flutter/component/particle/particle.dart';

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
          // return Stack(
          //   children: [
          //     // Background with gradient and logo
          //     Container(
          //       decoration: BoxDecoration(gradient: gradient),
          //       child: Center(
          //         child: AnimatedSwitcher(
          //           duration: const Duration(milliseconds: 800),
          //           child: AnimatedScale(
          //             key: ValueKey(index),
          //             duration: const Duration(milliseconds: 800),
          //             scale: 1.2,
          //             child: Image.asset(logos[index], width: 200),
          //           ),
          //         ),
          //       ),
          //     ),

          //     // Particle effect overlay
          //     Particles(
          //       awayRadius: 850,
          //       particles: createParticles(), // List of particles
          //       height: MediaQuery.of(context).size.height,
          //       width: MediaQuery.of(context).size.width,
          //       onTapAnimation: true,
          //       awayAnimationDuration: const Duration(milliseconds: 100),
          //       awayAnimationCurve: Curves.linear,
          //       enableHover: true,
          //       hoverRadius: 90,
          //       connectDots: false,
          //     ),
          //     // Glowing blurred bottom gradient (like your image)
          //     // Positioned(
          //     //   left: 0,
          //     //   right: 0,
          //     //   bottom: 0,
          //     //   height: 150,
          //     //   child: ClipRRect(
          //     //     borderRadius: const BorderRadius.only(
          //     //       topLeft: Radius.circular(250),
          //     //       topRight: Radius.circular(250),
          //     //     ),
          //     //     child: BackdropFilter(
          //     //       filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
          //     //       child: Container(
          //     //         decoration: BoxDecoration(
          //     //           gradient: LinearGradient(
          //     //             begin: Alignment.bottomCenter,
          //     //             end: Alignment.topCenter,
          //     //             colors: [
          //     //               AppColors.primaryColor.last.withOpacity(0.4),
          //     //               Colors.transparent,
          //     //             ],
          //     //           ),
          //     //         ),
          //     //       ),
          //     //     ),
          //     //   ),
          //     // ),
          //   ],
          // );
        },
      ),
    );
  }

  List<Particle> createParticles() {
    var rng = Random();
    List<Particle> particles = [];
    for (int i = 0; i < 140; i++) {
      particles.add(
        Particle(
          color: const Color.fromARGB(44, 15, 89, 180),
          size: rng.nextDouble() * 10,
          velocity: Offset(
            rng.nextDouble() * 200 * randomSign(),
            rng.nextDouble() * 200 * randomSign(),
          ),
        ),
      );
    }
    return particles;
  }

  double randomSign() {
    var rng = Random();
    return rng.nextBool() ? 1 : -1;
  }
}
