// import 'package:get/get.dart';
// import 'package:nqconnect/controllers/suggestion_controller.dart';
// import 'package:nqconnect/controllers/user_controller.dart';

// class SuggestionManagementController extends GetxController {
//   final SuggestionController suggestionController =
//       Get.find<SuggestionController>();
//   final UserController userController = Get.find<UserController>();

//   // Filter states
//   var currentView = 'active'.obs; // 'active' or 'archived'
//   var selectedDepartment = 'all'.obs;
//   var selectedCategory = 'all'.obs;
//   var selectedStatus = 'all'.obs;
//   var searchQuery = ''.obs;
//   var selectedDateRange = <DateTime?>[null, null].obs;

//   // Selection state for bulk actions
//   var selectedSuggestions = <String>[].obs;
//   var isSelecting = false.obs;

//   // Get filtered suggestions based on current filters
//   List<dynamic> get filteredSuggestions {
//     List<dynamic> baseList = currentView.value == 'active'
//         ? suggestionController.getActiveSuggestions()
//         : suggestionController.getArchivedSuggestions();

//     return baseList.where((suggestion) {
//       // Department filter
//       if (selectedDepartment.value != 'all' &&
//           suggestion.department != selectedDepartment.value) {
//         return false;
//       }

//       // Category filter
//       if (selectedCategory.value != 'all' &&
//           suggestion.category != selectedCategory.value) {
//         return false;
//       }

//       // Status filter
//       if (selectedStatus.value != 'all' &&
//           suggestion.status != selectedStatus.value) {
//         return false;
//       }

//       // Date range filter
//       if (selectedDateRange[0] != null && selectedDateRange[1] != null) {
//         final suggestionDate = suggestion.createdAt;
//         if (suggestionDate.isBefore(selectedDateRange[0]!) ||
//             suggestionDate.isAfter(selectedDateRange[1]!)) {
//           return false;
//         }
//       }

//       // Search filter
//       if (searchQuery.value.isNotEmpty) {
//         final query = searchQuery.value.toLowerCase();
//         if (!suggestion.title.toLowerCase().contains(query) &&
//             !suggestion.description.toLowerCase().contains(query) &&
//             !suggestion.employeeName.toLowerCase().contains(query)) {
//           return false;
//         }
//       }

//       return true;
//     }).toList();
//   }

//   // Get unique departments for filter dropdown
//   List<String> get availableDepartments {
//     final departments = suggestionController.suggestions
//         .map((s) => s.department)
//         .toSet()
//         .toList();
//     departments.sort();
//     return ['all', ...departments];
//   }

//   // Get unique categories for filter dropdown
//   List<String> get availableCategories {
//     final categories = suggestionController.suggestions
//         .map((s) => s.category)
//         .toSet()
//         .toList();
//     categories.sort();
//     return ['all', ...categories];
//   }

//   // Get unique statuses for filter dropdown
//   List<String> get availableStatuses {
//     return ['all', 'Pending', 'Approved', 'Rejected'];
//   }

//   // Selection methods
//   void toggleSelection(String suggestionId) {
//     if (selectedSuggestions.contains(suggestionId)) {
//       selectedSuggestions.remove(suggestionId);
//     } else {
//       selectedSuggestions.add(suggestionId);
//     }
//   }

//   void selectAll() {
//     selectedSuggestions.assignAll(
//       filteredSuggestions.map<String>((s) => s.id).toList(),
//     );
//   }

//   void clearSelection() {
//     selectedSuggestions.clear();
//   }

//   // Bulk actions
//   void bulkUpdateStatus(String newStatus, String? comments) {
//     suggestionController.bulkUpdateStatus(
//       selectedSuggestions,
//       newStatus,
//       userController.userName.value,
//       comments,
//     );
//     clearSelection();
//     isSelecting.value = false;
//   }

//   void bulkArchive(bool archive) {
//     suggestionController.bulkArchive(selectedSuggestions, archive);
//     clearSelection();
//     isSelecting.value = false;
//   }

//   // Reset filters
//   void resetFilters() {
//     selectedDepartment.value = 'all';
//     selectedCategory.value = 'all';
//     selectedStatus.value = 'all';
//     searchQuery.value = '';
//     selectedDateRange.value = [null, null];
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class SuggestionManagementController extends GetxController {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();
  final UserController userController = Get.find<UserController>();

  var currentView = 'active'.obs;
  var selectedDepartment = 'all'.obs;
  var selectedCategory = 'all'.obs;
  var selectedStatus = 'all'.obs;
  var searchQuery = ''.obs;
  var selectedDateRange = <DateTime?>[null, null].obs;
  var selectedSuggestions = <String>[].obs;
  var isSelecting = false.obs;

  List<Suggestion> get filteredSuggestions {
    List<Suggestion> baseList = currentView.value == 'active'
        ? suggestionController.getActiveSuggestions()
        : suggestionController.getArchivedSuggestions();

    return baseList.where((suggestion) {
      if (selectedDepartment.value != 'all' &&
          suggestion.department != selectedDepartment.value) {
        return false;
      }
      if (selectedCategory.value != 'all' &&
          suggestion.category != selectedCategory.value) {
        return false;
      }
      if (selectedStatus.value != 'all' &&
          suggestion.status != selectedStatus.value) {
        return false;
      }
      if (selectedDateRange[0] != null && selectedDateRange[1] != null) {
        final suggestionDate = suggestion.createdAt;
        if (suggestionDate.isBefore(selectedDateRange[0]!) ||
            suggestionDate.isAfter(selectedDateRange[1]!)) {
          return false;
        }
      }
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!suggestion.title.toLowerCase().contains(query) &&
            !suggestion.description.toLowerCase().contains(query) &&
            !suggestion.employeeName.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<String> get availableDepartments {
    final departments = suggestionController.suggestions
        .map((s) => s.department)
        .toSet()
        .toList();
    departments.sort();
    return ['all', ...departments];
  }

  List<String> get availableCategories {
    final categories = suggestionController.suggestions
        .map((s) => s.category)
        .toSet()
        .toList();
    categories.sort();
    return ['all', ...categories];
  }

  List<String> get availableStatuses => [
    'all',
    'Pending',
    'Approved',
    'Rejected',
  ];

  void toggleSelection(String suggestionId) {
    if (selectedSuggestions.contains(suggestionId)) {
      selectedSuggestions.remove(suggestionId);
    } else {
      selectedSuggestions.add(suggestionId);
    }
  }

  void selectAll() {
    selectedSuggestions.assignAll(
      filteredSuggestions.map((s) => s.id.toString()).toList(),
    );
  }

  void clearSelection() {
    selectedSuggestions.clear();
  }

  void bulkUpdateStatus(String newStatus, String? comments) {
    suggestionController
        .bulkUpdateStatus(
          selectedSuggestions,
          newStatus,
          userController.userName.value,
          comments,
        )
        .then((_) {
          Get.snackbar(
            '$newStatus Successful',
            'Updated ${selectedSuggestions.length} suggestions',
            backgroundColor: newStatus == 'Approved'
                ? Colors.green
                : Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        });
    clearSelection();
    isSelecting.value = false;
  }

  void bulkArchive(bool archive) {
    suggestionController.bulkArchive(selectedSuggestions, archive);
    Get.snackbar(
      archive ? 'Archived' : 'Unarchived',
      '${selectedSuggestions.length} suggestions ${archive ? 'archived' : 'unarchived'}',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    clearSelection();
    isSelecting.value = false;
  }

  void resetFilters() {
    selectedDepartment.value = 'all';
    selectedCategory.value = 'all';
    selectedStatus.value = 'all';
    searchQuery.value = '';
    selectedDateRange.value = [null, null];
  }
}
