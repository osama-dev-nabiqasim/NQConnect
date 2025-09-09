import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/data/dummy_db.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class AnalyticsController extends GetxController {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();
  final UserController userController = Get.find<UserController>();

  // Total Suggestions Count
  int get totalSuggestions => suggestionController.suggestions.length;

  // Suggestions by Status
  int get pendingSuggestions => suggestionController.suggestions
      .where((s) => s.status == "Pending")
      .length;

  int get approvedSuggestions => suggestionController.suggestions
      .where((s) => s.status == "Approved")
      .length;

  int get rejectedSuggestions => suggestionController.suggestions
      .where((s) => s.status == "Rejected")
      .length;

  // Department-wise Performance
  Map<String, int> get departmentWiseSuggestions {
    Map<String, int> departmentCount = {};
    for (var suggestion in suggestionController.suggestions) {
      departmentCount[suggestion.department] =
          (departmentCount[suggestion.department] ?? 0) + 1;
    }
    return departmentCount;
  }

  String get topPerformingDepartment {
    if (departmentWiseSuggestions.isEmpty) return 'No data';
    return departmentWiseSuggestions.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Monthly Trends
  Map<String, int> get monthlyTrends {
    Map<String, int> monthlyData = {};
    for (var suggestion in suggestionController.suggestions) {
      String monthYear =
          '${suggestion.createdAt.month}/${suggestion.createdAt.year}';
      monthlyData[monthYear] = (monthlyData[monthYear] ?? 0) + 1;
    }
    return monthlyData;
  }

  // Top Voted Suggestions
  List<Suggestion> get topVotedSuggestions {
    return suggestionController.suggestions
      ..sort((a, b) => (b.likes - b.dislikes).compareTo(a.likes - a.dislikes));
  }

  // Employee Statistics (Using your DummyDB)
  int get totalEmployees {
    return DummyDB.users.where((user) => user["role"] == "employee").length;
  }

  Map<String, int> get departmentWiseEmployees {
    Map<String, int> departmentCount = {};
    for (var user in DummyDB.users.where((u) => u["role"] == "employee")) {
      String dept = user["department"] ?? "Unknown"; // ✅ safe assignment

      departmentCount[dept] = (departmentCount[dept] ?? 0) + 1;
    }
    return departmentCount;
  }

  int get totalDepartments {
    return DummyDB.users
        .map((user) => user["department"])
        .toSet()
        .where((dept) => dept != "All")
        .length;
  }

  // Most Active Department (based on suggestions + votes)
  String get mostActiveDepartment {
    if (departmentWiseSuggestions.isEmpty) return 'No data';

    // Calculate department score (suggestions + total votes)
    Map<String, int> departmentScores = {};
    for (var suggestion in suggestionController.suggestions) {
      int score = 1 + suggestion.likes; // 1 for suggestion + likes
      departmentScores[suggestion.department] =
          (departmentScores[suggestion.department] ?? 0) + score;
    }

    return departmentScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Suggestion Approval Rate
  double get approvalRate {
    if (totalSuggestions == 0) return 0;
    return (approvedSuggestions / totalSuggestions) * 100;
  }
}
