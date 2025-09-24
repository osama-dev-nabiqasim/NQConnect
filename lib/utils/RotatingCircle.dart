import 'package:flutter/material.dart';

class GradientRotatingCircle extends StatefulWidget {
  const GradientRotatingCircle({super.key});

  @override
  State<GradientRotatingCircle> createState() => _GradientRotatingCircleState();
}

class _GradientRotatingCircleState extends State<GradientRotatingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // speed of rotation
      vsync: this,
    )..repeat(); // infinite loop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              const Color.fromARGB(41, 0, 150, 135),
              const Color.fromARGB(115, 0, 187, 212),
              const Color.fromARGB(30, 68, 137, 255),
              const Color.fromARGB(146, 0, 150, 135), // loop back
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}
