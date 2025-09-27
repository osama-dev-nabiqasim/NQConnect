import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/controllers/analytics_controller.dart';
import 'package:nqconnect/utils/analytics_card.dart';
import 'package:nqconnect/utils/responsive.dart'; // Assuming this exists

class AnalyticsDashboard extends StatelessWidget {
  final AnalyticsController controller = Get.put(AnalyticsController());

  AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Suggestion Analytics",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.appbarColor[0],
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📊 Summary Cards Row
              SizedBox(
                height: Responsive.height(context) * 0.15,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    AnalyticsCard(
                      title: "Total Suggestions",
                      value: controller.totalSuggestions.toString(),
                      icon: Icons.lightbulb_outline,
                      color: Colors.blue,
                    ),
                    AnalyticsCard(
                      title: "Approved",
                      value: controller.approvedSuggestions.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    AnalyticsCard(
                      title: "Pending",
                      value: controller.pendingSuggestions.toString(),
                      icon: Icons.access_time,
                      color: Colors.orange,
                    ),
                    AnalyticsCard(
                      title: "Rejected",
                      value: controller.rejectedSuggestions.toString(),
                      icon: Icons.cancel,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 🏆 Performance Metrics Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMetricCard(
                    context,
                    "Top Department",
                    controller.topPerformingDepartment,
                    Icons.emoji_events,
                    Colors.amber,
                    onLongPress: () => _showInfoDialog(
                      context,
                      "Top Department",
                      "Department with the highest number of approved suggestions.",
                    ),
                  ),
                  _buildMetricCard(
                    context,
                    "Most Active Dept",
                    controller.mostActiveDepartment,
                    Icons.trending_up,
                    Colors.purple,
                    onLongPress: () => _showInfoDialog(
                      context,
                      "Most Active Department",
                      "Department with higher number of suggestions.",
                    ),
                  ),
                  _buildMetricCard(
                    context,
                    "Approval Rate",
                    "${controller.approvalRate.toStringAsFixed(1)}%",
                    Icons.thumb_up,
                    Colors.green,
                  ),
                  _buildMetricCard(
                    context,
                    "Total Employees",
                    controller.totalEmployees.value.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 📈 Department-wise Breakdown
              _buildSectionTitle("Department Statistics"),
              _buildDepartmentStats(context),
              const SizedBox(height: 20),
              // 🔥 Top Voted Suggestions
              _buildSectionTitle("Top Voted Suggestions"),
              _buildTopSuggestions(context),
              const SizedBox(height: 20),
              // 📅 Monthly Trends
              _buildSectionTitle("Monthly Trends"),
              _buildMonthlyTrends(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
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

  Widget _buildDepartmentStats(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            children: [
              for (var entry in controller.departmentWiseSuggestions.entries)
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
                        "${entry.value} suggestions",
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

  Widget _buildTopSuggestions(BuildContext context) {
    return Obx(() {
      final topSuggestions = controller.topVotedSuggestions.take(5).toList();
      return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (var suggestion in topSuggestions)
                ListTile(
                  leading: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                  ),
                  title: Text(suggestion.title),
                  subtitle: Text(
                    "${suggestion.likes} 👍 • "
                    "${suggestion.department} • "
                    "${DateFormat('dd MMM yyyy').format(suggestion.createdAt)}",
                  ),
                  trailing: Chip(
                    label: Text("+${suggestion.likes - suggestion.dislikes}"),
                    backgroundColor: Colors.green[100],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMonthlyTrends(BuildContext context) {
    return Obx(() {
      return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (var entry in controller.monthlyTrends.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Month ${entry.key}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        "${entry.value} suggestions",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(32, 0, 0, 0),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () => Navigator.pop(context),
        //     child: const Text("OK"),
        //   ),
        // ],
      ),
    );
  }
}
