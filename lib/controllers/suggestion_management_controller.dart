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
    // List<Suggestion> baseList = currentView.value == 'active'
    //     ? suggestionController.getActiveSuggestions()
    //     : suggestionController.getArchivedSuggestions();
    List<Suggestion> baseList;

    switch (currentView.value) {
      case 'archived':
        // ✅ Show ONLY archived
        baseList = suggestionController.suggestions
            .where((s) => s.isArchived == true)
            .toList();
        break;

      case 'on_process':
        // ✅ Only non-archived + position OnProcess
        baseList = suggestionController.suggestions
            .where(
              (s) =>
                  s.isArchived == false &&
                  s.position != null &&
                  s.position == 'OnProcess',
            )
            .toList();
        break;

      case 'done':
        // ✅ Only non-archived + position Implemented
        baseList = suggestionController.suggestions
            .where(
              (s) =>
                  s.isArchived == false &&
                  s.position != null &&
                  s.position == 'Implemented',
            )
            .toList();
        break;

      case 'active':
      default:
        // ✅ Active = all NON-archived suggestions
        //     except those already OnProcess or Implemented
        baseList = suggestionController.suggestions
            .where(
              (s) =>
                  s.isArchived == false &&
                  (s.position == null ||
                      (s.position != 'OnProcess' &&
                          s.position != 'Implemented')),
            )
            .toList();
    }

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

  Future<void> updateCategory(String id, String category) async {
    await suggestionController.updateCategory(id, category);
    await suggestionController.fetchSuggestions();
  }
}
