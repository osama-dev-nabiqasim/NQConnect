// lib/screens/suggestion_insights_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class SuggestionInsightsScreen extends StatelessWidget {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();
  final UserController userController = Get.find<UserController>();

  SuggestionInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String managerDept = userController.department.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Suggestion Insights",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),
      body: Obx(() {
        final deptSuggestions = suggestionController
            .getDepartmentSuggestions(managerDept)
            .where((s) => s.status == "Approved") // sirf approved
            .toList();

        if (deptSuggestions.isEmpty) {
          return const Center(
            child: Text("No suggestions for your department yet."),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deptSuggestions.length,
          itemBuilder: (context, index) {
            final Suggestion suggestion = deptSuggestions[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestion.description,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Chart
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY:
                              (suggestion.likes > suggestion.dislikes
                                  ? suggestion.likes.toDouble()
                                  : suggestion.dislikes.toDouble()) +
                              2,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text("👍 Likes");
                                    case 1:
                                      return const Text("👎 Dislikes");
                                    default:
                                      return const Text("");
                                  }
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: suggestion.likes.toDouble(),
                                  color: Colors.green,
                                  width: 28,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: suggestion.dislikes.toDouble(),
                                  color: Colors.red,
                                  width: 28,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      "👍 ${suggestion.likes}   👎 ${suggestion.dislikes}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
