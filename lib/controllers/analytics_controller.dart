// import 'package:get/get.dart';
// import 'package:nqconnect/controllers/suggestion_controller.dart';
// import 'package:nqconnect/controllers/user_controller.dart';
// import 'package:nqconnect/data/dummy_db.dart';
// import 'package:nqconnect/models/suggestion_model.dart';

// class AnalyticsController extends GetxController {
//   final SuggestionController suggestionController =
//       Get.find<SuggestionController>();
//   final UserController userController = Get.find<UserController>();

//   // Total Suggestions Count
//   int get totalSuggestions => suggestionController.suggestions.length;

//   // Suggestions by Status
//   int get pendingSuggestions => suggestionController.suggestions
//       .where((s) => s.status == "Pending")
//       .length;

//   int get approvedSuggestions => suggestionController.suggestions
//       .where((s) => s.status == "Approved")
//       .length;

//   int get rejectedSuggestions => suggestionController.suggestions
//       .where((s) => s.status == "Rejected")
//       .length;

//   // Department-wise Performance
//   Map<String, int> get departmentWiseSuggestions {
//     Map<String, int> departmentCount = {};
//     for (var suggestion in suggestionController.suggestions) {
//       departmentCount[suggestion.department] =
//           (departmentCount[suggestion.department] ?? 0) + 1;
//     }
//     return departmentCount;
//   }

//   String get topPerformingDepartment {
//     if (departmentWiseSuggestions.isEmpty) return 'No data';
//     return departmentWiseSuggestions.entries
//         .reduce((a, b) => a.value > b.value ? a : b)
//         .key;
//   }

//   // Monthly Trends
//   Map<String, int> get monthlyTrends {
//     Map<String, int> monthlyData = {};
//     for (var suggestion in suggestionController.suggestions) {
//       String monthYear =
//           '${suggestion.createdAt.month}/${suggestion.createdAt.year}';
//       monthlyData[monthYear] = (monthlyData[monthYear] ?? 0) + 1;
//     }
//     return monthlyData;
//   }

//   // Top Voted Suggestions
//   List<Suggestion> get topVotedSuggestions {
//     return suggestionController.suggestions
//       ..sort((a, b) => (b.likes - b.dislikes).compareTo(a.likes - a.dislikes));
//   }

//   // Employee Statistics (Using your DummyDB)
//   int get totalEmployees {
//     return DummyDB.users.where((user) => user["role"] == "employee").length;
//   }

//   Map<String, int> get departmentWiseEmployees {
//     Map<String, int> departmentCount = {};
//     for (var user in DummyDB.users.where((u) => u["role"] == "employee")) {
//       String dept = user["department"] ?? "Unknown"; // ✅ safe assignment

//       departmentCount[dept] = (departmentCount[dept] ?? 0) + 1;
//     }
//     return departmentCount;
//   }

//   int get totalDepartments {
//     return DummyDB.users
//         .map((user) => user["department"])
//         .toSet()
//         .where((dept) => dept != "All")
//         .length;
//   }

//   // Most Active Department (based on suggestions + votes)
//   String get mostActiveDepartment {
//     if (departmentWiseSuggestions.isEmpty) return 'No data';

//     // Calculate department score (suggestions + total votes)
//     Map<String, int> departmentScores = {};
//     for (var suggestion in suggestionController.suggestions) {
//       int score = 1 + suggestion.likes; // 1 for suggestion + likes
//       departmentScores[suggestion.department] =
//           (departmentScores[suggestion.department] ?? 0) + score;
//     }

//     return departmentScores.entries
//         .reduce((a, b) => a.value > b.value ? a : b)
//         .key;
//   }

//   // Suggestion Approval Rate
//   double get approvalRate {
//     if (totalSuggestions == 0) return 0;
//     return (approvedSuggestions / totalSuggestions) * 100;
//   }
// }

import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class AnalyticsController extends GetxController {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to suggestion changes
    suggestionController.suggestions.listen((_) {
      refreshAnalytics();
    });
    refreshAnalytics();
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

  int get totalEmployees {
    // Placeholder: Fetch from a UserController or API
    return 50; // Replace with actual logic
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
