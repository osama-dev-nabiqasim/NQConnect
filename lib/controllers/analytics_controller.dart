// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';
import 'package:nqconnect/services/api_service.dart';

class AnalyticsController extends GetxController {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();
  final UserController userController = Get.find<UserController>();
  var isLoading = false.obs;
  final ApiService _apiService = ApiService();
  var totalEmployees = 0.obs; // 👈 observable

  @override
  void onInit() {
    super.onInit();
    fetchTotalEmployees();
    // Listen to suggestion changes
    suggestionController.suggestions.listen((_) {
      refreshAnalytics();
    });
    refreshAnalytics();
  }

  Future<void> fetchTotalEmployees() async {
    try {
      final count = await _apiService.fetchEmployeeCount();
      totalEmployees.value = count;
      print("🔎 Total employees fetched: $count");
    } catch (e) {
      print("❌ Failed to fetch employee count: $e");
    }
  }

  void refreshAnalytics() {
    isLoading.value = true;
    // Trigger update of observables
    update();
    isLoading.value = false;
  }

  int get totalSuggestions => suggestionController.suggestions.length;

  int get approvedSuggestions =>
      suggestionController.getSuggestionsByStatus("Approved").length;

  int get pendingSuggestions =>
      suggestionController.getSuggestionsByStatus("Pending").length;

  int get rejectedSuggestions =>
      suggestionController.getSuggestionsByStatus("Rejected").length;

  double get approvalRate {
    if (totalSuggestions == 0) return 0.0;
    return (approvedSuggestions / totalSuggestions) * 100;
  }

  String get topPerformingDepartment => suggestionController.getTopDepartment();

  String get mostActiveDepartment {
    final deptCounts = <String, int>{};
    for (var suggestion in suggestionController.suggestions) {
      deptCounts[suggestion.department] =
          (deptCounts[suggestion.department] ?? 0) + 1;
    }
    if (deptCounts.isEmpty) return "N/A";
    return deptCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Map<String, int> get departmentWiseSuggestions {
    final deptCounts = <String, int>{};
    for (var suggestion in suggestionController.suggestions) {
      deptCounts[suggestion.department] =
          (deptCounts[suggestion.department] ?? 0) + 1;
    }
    return deptCounts;
  }

  List<Suggestion> get topVotedSuggestions {
    return suggestionController.suggestions.where((s) => !s.isArchived).toList()
      ..sort((a, b) => (b.likes - b.dislikes).compareTo(a.likes - a.dislikes));
  }

  Map<int, int> get monthlyTrends {
    final trends = <int, int>{};
    for (var suggestion in suggestionController.suggestions) {
      final month = suggestion.createdAt.month;
      trends[month] = (trends[month] ?? 0) + 1;
    }
    return trends;
  }
}
