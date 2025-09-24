// lib/screens/suggestion_insights_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';
import 'package:nqconnect/utils/responsive.dart';
import 'package:intl/intl.dart';

class SuggestionInsightsScreen extends StatefulWidget {
  const SuggestionInsightsScreen({Key? key}) : super(key: key);

  @override
  State<SuggestionInsightsScreen> createState() =>
      _SuggestionInsightsScreenState();
}

class _SuggestionInsightsScreenState extends State<SuggestionInsightsScreen>
    with WidgetsBindingObserver {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();
  final UserController userController = Get.find<UserController>();

  /// Track which cards are expanded
  final RxSet<int> _expanded = <int>{}.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData(); // ✅ initial load
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when app returns to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData(); // ✅ re-fetch on resume
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _refreshData() async {
    await suggestionController.fetchSuggestions();
    setState(() {}); // rebuild after fetching
  }

  @override
  Widget build(BuildContext context) {
    final String managerDept = userController.department.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Suggestion Insights",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.appbarColor[0],
        centerTitle: true,
      ),
      body: Obx(() {
        final deptSuggestions =
            suggestionController
                .getDepartmentSuggestions(managerDept)
                .where((s) => s.status == "Approved")
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (deptSuggestions.isEmpty) {
          return const Center(
            child: Text("No suggestions for your department yet."),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deptSuggestions.length,
            itemBuilder: (context, index) {
              final Suggestion suggestion = deptSuggestions[index];
              final bool isExpanded = _expanded.contains(index);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: ExpansionTile(
                  key: ValueKey(suggestion.id),
                  onExpansionChanged: (open) {
                    open ? _expanded.add(index) : _expanded.remove(index);
                  },
                  title: Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "👍 ${suggestion.likes}   👎 ${suggestion.dislikes}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    // Description
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        suggestion.description,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Created date
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Created: ${DateFormat('dd MMM yyyy').format(suggestion.createdAt.toLocal())}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chart
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
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
