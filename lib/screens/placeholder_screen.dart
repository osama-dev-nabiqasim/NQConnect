// lib/screens/placeholder_screen.dart

import 'package:flutter/material.dart';
import 'package:nqconnect/utils/responsive.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.appbarColor[0],
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "$title - Coming Soon",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
