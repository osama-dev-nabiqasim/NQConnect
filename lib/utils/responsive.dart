import 'package:flutter/material.dart';

class Responsive {
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double font(BuildContext context, double size) =>
      (width(context) / 390) * size; // base iPhone 12 width reference
}
