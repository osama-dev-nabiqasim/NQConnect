import 'package:flutter/material.dart';

class Section {
  final String name;
  final IconData icon;
  final String route;
  final bool fullWidth;

  Section({
    required this.name,
    required this.icon,
    required this.route,
    this.fullWidth = false,
  });
}
