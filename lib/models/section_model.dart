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

  Section copyWith({
    String? name,
    IconData? icon,
    String? route,
    bool? fullWidth,
  }) {
    return Section(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      fullWidth: fullWidth ?? this.fullWidth,
    );
  }
}
