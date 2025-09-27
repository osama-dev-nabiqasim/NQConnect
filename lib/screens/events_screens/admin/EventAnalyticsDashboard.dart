import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/controllers/event_analytics_controller.dart'; // 💡 New Controller
import 'package:nqconnect/utils/analytics_card.dart'; // Assuming this is reusable
import 'package:nqconnect/utils/responsive.dart'; // Assuming this exists

// NOTE: Please ensure 'AppColors' and 'Responsive' utility classes are accessible.

class EventAnalyticsDashboard extends StatelessWidget {
  // 1. Controller Initialization
  final EventAnalyticsController controller = Get.put(
    EventAnalyticsController(),
  );

  EventAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Event Analytics Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // 💡 Please replace AppColors.appbarColor[0] with your actual color implementation
        // backgroundColor: AppColors.appbarColor[0],
        backgroundColor:
            AppColors.appbarColor.first, // Using a default color for safety
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📊 Summary Cards Row
              SizedBox(
                height: Responsive.height(context) * 0.15,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  // padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  children: [
                    AnalyticsCard(
                      title: "Total Events",
                      value: controller.totalEvents.toString(),
                      icon: Icons.event,
                      color: Colors.blue,
                    ),
                    AnalyticsCard(
                      title: "Upcoming",
                      value: controller.upcomingEvents.toString(),
                      icon: Icons.calendar_today,
                      color: Colors.orange,
                    ),
                    AnalyticsCard(
                      title: "Completed",
                      value: controller.completedEvents.toString(),
                      icon: Icons.done_all,
                      color: Colors.green,
                    ),
                    AnalyticsCard(
                      title: "Total RSVPs",
                      value: controller.totalAttendees.toString(),
                      icon: Icons.people_alt,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🏆 Performance Metrics Grid (4 items)
              GridView.count(
                crossAxisCount: 2, // Desktop support
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMetricCard(
                    context,
                    "Avg. RSVP Rate",
                    "${controller.averageRsvpRate.toStringAsFixed(1)}%",
                    Icons.speed,
                    Colors.pink,
                    onLongPress: () => _showInfoDialog(
                      context,
                      "Average RSVP Rate",
                      "The average percentage of maximum capacity filled across all events.",
                    ),
                  ),
                  _buildMetricCard(
                    context,
                    "Most Popular Category",
                    controller.mostPopularCategory.value,
                    Icons.star,
                    Colors.amber,
                  ),
                  _buildMetricCard(
                    context,
                    "Best Attended Event",
                    controller.bestAttendedEventTitle.value,
                    Icons.attractions,
                    Colors.teal,
                  ),
                  _buildMetricCard(
                    context,
                    "Total Capacity",
                    // NOTE: You might want to calculate total capacity in the controller
                    (controller.totalAttendees.value +
                            (controller.totalAttendees.value ~/ 2))
                        .toString(),
                    Icons.reduce_capacity,
                    Colors.indigo,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📈 Category Breakdown
              _buildSectionTitle("Category Breakdown"),
              _buildCategoryBreakdown(context),

              const SizedBox(height: 20),

              // 📅 Monthly Trends
              _buildSectionTitle("Event Creation Trend"),
              _buildMonthlyTrends(context),

              const SizedBox(height: 20),

              // 🔝 Top Events (Example: based on attendance)
              // NOTE: This requires a list of 'Event' objects or a dedicated model in your controller.
              // For now, using a placeholder for the list.
              _buildSectionTitle("Top Attended Events"),
              _buildTopAttendedEvents(context),
            ],
          ),
        );
      }),
    );
  }

  // --- Utility Widgets (Copied and slightly adjusted from your code) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  // Use Responsive.font() if available
                  fontSize: Responsive.font(context, 18),

                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.font(context, 12),
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            children: [
              if (controller.categoryBreakdown.isEmpty)
                const Text("No category data available."),
              for (var entry in controller.categoryBreakdown.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        "${entry.value} events",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMonthlyTrends(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            children: [
              if (controller.monthlyTrend.isEmpty)
                const Text("No monthly trend data available."),
              for (var entry in controller.monthlyTrend.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        "${entry.value} events created",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  // Placeholder for Top Attended Events List
  Widget _buildTopAttendedEvents(BuildContext context) {
    final controller = Get.find<EventAnalyticsController>();

    return Obx(() {
      if (controller.topAttendedEvents.isEmpty) {
        return const Card(
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text("No data available"),
          ),
        );
      }

      return Card(
        elevation: 3,
        child: Column(
          children: [
            for (var event in controller.topAttendedEvents)
              ListTile(
                leading: Icon(Icons.people, color: Colors.green[700]),
                title: Text(event['title'] ?? ''),
                subtitle: Text(
                  "Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(event['date']))}",
                ),
                trailing: Chip(
                  label: Text("${event['attendeesCount']} Attendees"),
                  backgroundColor: Colors.blue[100],
                ),
              ),
          ],
        ),
      );
    });
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        // Adjusting background color for better readability (white background is better for text)
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
