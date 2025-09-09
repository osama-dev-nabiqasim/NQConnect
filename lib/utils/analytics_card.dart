import 'package:flutter/material.dart';
import 'package:nqconnect/utils/responsive.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.width(context) * 0.4,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Added this
        children: [
          Icon(icon, size: 24, color: color), // Reduced icon size
          const SizedBox(height: 6), // Reduced spacing
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.font(context, 16), // Reduced font size
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center, // Added text alignment
            maxLines: 1, // Prevent text wrapping
            overflow: TextOverflow.ellipsis, // Handle overflow
          ),
          const SizedBox(height: 4), // Reduced spacing
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.font(context, 10), // Reduced font size
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2, // Allow title to wrap to 2 lines
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
