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
              Colors.teal,
              Colors.cyan,
              Colors.blueAccent,
              Colors.teal, // loop back
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}
