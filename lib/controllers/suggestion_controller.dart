// ignore_for_file: unnecessary_cast, unnecessary_import, await_only_futures, unrelated_type_equality_checks, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
import '../models/suggestion_model.dart';
import '../models/status_history_model.dart';

class SuggestionController extends GetxController {
  final ApiService _apiService = ApiService();
  final box = GetStorage();
  var suggestions = <Suggestion>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // _loadData();
    fetchSuggestions();
  }

  Future<void> deleteSuggestion(String id) async {
    try {
      await _apiService.deleteSuggestion(id);
      // remove locally
      suggestions.removeWhere((s) => s.id.toString() == id);
      // optionally refresh from server:
      await fetchSuggestions();
    } catch (e) {
      print('SuggestionController.deleteSuggestion error: $e');
      rethrow;
    }
  }

  Future<void> bulkDeleteSuggestions(List<String> ids) async {
    try {
      await _apiService.bulkDeleteSuggestions(ids);
      suggestions.removeWhere((s) => ids.contains(s.id.toString()));
      await fetchSuggestions();
    } catch (e) {
      print('SuggestionController.bulkDeleteSuggestions error: $e');
      rethrow;
    }
  }

  Future<void> fetchSuggestions() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getSuggestions();
      print('Fetched suggestions: ${data.length} items');
      suggestions.value = data
          .map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
          .toList();
      _saveToLocal();
    } catch (e) {
      loadSuggestions();
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSuggestion(Suggestion suggestion) async {
    try {
      final data = {
        'title': suggestion.title,
        'description': suggestion.description,
        'category': suggestion.category,
        'employee_id': suggestion.employeeId,
        'employee_name': suggestion.employeeName,
        'department': suggestion.department,
      };

      final result = await _apiService.addSuggestion(data);
      final newId = result['id'] is int
          ? result['id']
          : int.tryParse(result['id'].toString()) ??
                DateTime.now().millisecondsSinceEpoch;
      final createdAt = result['created_at'] != null
          ? DateTime.parse(result['created_at'])
          : DateTime.now();

      final newSuggestion = suggestion.copyWith(
        id: newId,
        createdAt: createdAt,
      );
      suggestions.add(newSuggestion);
      _saveToLocal();
      suggestions.refresh();
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Failed to add suggestion',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateSuggestionStatus(
    String suggestionId,
    String newStatus,
    String reviewedBy,
    String? comments,
  ) async {
    try {
      isLoading.value = true;
      print('Updating suggestion ID: $suggestionId to status: $newStatus');
      // Call backend API
      final response = await _apiService.updateSuggestionStatus(suggestionId, {
        'status': newStatus,
        'reviewed_by': reviewedBy,
        'comments': comments,
      });
      print('API Response: $response');

      // Update local state
      final index = suggestions.indexWhere(
        (s) => s.id.toString() == suggestionId,
      );
      print('Found index: $index for suggestion ID: $suggestionId');
      if (index != -1) {
        suggestions[index] = suggestions[index].copyWith(
          status: newStatus,
          reviewedBy: reviewedBy,
          reviewedAt: DateTime.now(),
          reviewComments: comments,
          statusHistory: [
            ...suggestions[index].statusHistory,
            StatusHistory(
              status: newStatus,
              changedBy: reviewedBy,
              changedAt: DateTime.now(),
              comments: comments,
            ),
          ],
        );
        print(
          'Updated suggestion at index $index: ${suggestions[index].status}',
        ); // Debug log
        suggestions.refresh();
        _saveToLocal();
      } else {
        print(
          'Suggestion ID $suggestionId not found in suggestions list',
        ); // Debug log
      }
    } catch (e) {
      print('Error updating status: $e'); // Debug log
      Get.snackbar(
        'Error',
        'Failed to update status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveSuggestionById(String suggestionId) async {
    await updateSuggestionStatus(
      suggestionId,
      "Approved",
      "Manager",
      "Approved via Approve/Reject Screen",
    );
  }

  Future<void> rejectSuggestionById(String suggestionId) async {
    await updateSuggestionStatus(
      suggestionId,
      "Rejected",
      "Manager",
      "Rejected via Approve/Reject Screen",
    );
  }

  Future<void> voteOnSuggestion(
    String suggestionId,
    String type,
    String employeeId,
  ) async {
    try {
      await _apiService.voteOnSuggestion(suggestionId, type, employeeId);
      final index = suggestions.indexWhere(
        (s) => s.id.toString() == suggestionId,
      );
      if (index != -1) {
        suggestions[index] = suggestions[index].copyWith(
          likes: type == "like"
              ? suggestions[index].likes + 1
              : suggestions[index].likes,
          dislikes: type == "dislike"
              ? suggestions[index].dislikes + 1
              : suggestions[index].dislikes,
        );
        suggestions.refresh();
        _saveToLocal();
      }
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Failed to vote',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<String?> getUserVote(String suggestionId, String employeeId) async {
    try {
      return await _apiService.getUserVote(suggestionId, employeeId);
    } catch (e) {
      return null;
    }
  }

  Future<void> approveSuggestion(int index) async {
    if (index >= 0 && index < suggestions.length) {
      final suggestion = suggestions[index];
      await updateSuggestionStatus(
        suggestion.id.toString(), // 👈 Convert to String
        "Approved",
        "Manager", // 👈 Better than "System"
        "Approved via Approve/Reject Screen",
      );
      // 👇 No need to refresh — updateSuggestionStatus already calls suggestions.refresh()
    }
  }

  Future<void> rejectSuggestion(int index) async {
    if (index >= 0 && index < suggestions.length) {
      final suggestion = suggestions[index];
      await updateSuggestionStatus(
        suggestion.id.toString(), // 👈 Convert to String
        "Rejected",
        "Manager",
        "Rejected via Approve/Reject Screen",
      );
      // 👇 No need to refresh — updateSuggestionStatus already calls suggestions.refresh()
    }
  }

  List<Suggestion> getDepartmentSuggestions(String department) {
    return suggestions.where((s) => s.department == department).toList();
  }

  Future<void> bulkUpdateStatus(
    List<String> suggestionIds,
    String newStatus,
    String reviewedBy,
    String? comments,
  ) async {
    try {
      isLoading.value = true;
      for (var id in suggestionIds) {
        await _apiService.updateSuggestionStatus(id, {
          'status': newStatus,
          'reviewed_by': reviewedBy,
          'comments': comments,
        });
        final index = suggestions.indexWhere((s) => s.id.toString() == id);
        if (index != -1) {
          suggestions[index] = suggestions[index].copyWith(
            status: newStatus,
            reviewedBy: reviewedBy,
            reviewedAt: DateTime.now(),
            reviewComments: comments,
            statusHistory: [
              ...suggestions[index].statusHistory,
              StatusHistory(
                status: newStatus,
                changedBy: reviewedBy,
                changedAt: DateTime.now(),
                comments: comments ?? 'Bulk action',
              ),
            ],
          );
        }
      }
      suggestions.refresh();
      _saveToLocal();
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Failed to update status in bulk',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bulkArchive(List<String> suggestionIds, bool archive) async {
    try {
      isLoading.value = true;
      for (var id in suggestionIds) {
        final index = suggestions.indexWhere((s) => s.id.toString() == id);
        if (index != -1) {
          suggestions[index] = suggestions[index].copyWith(isArchived: archive);
        }
      }
      suggestions.refresh();
      _saveToLocal();
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Failed to archive in bulk',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void archiveSuggestion(String suggestionId, bool archive) {
    final index = suggestions.indexWhere(
      (s) => s.id.toString() == suggestionId,
    );
    if (index != -1) {
      suggestions[index] = suggestions[index].copyWith(isArchived: archive);
      suggestions.refresh();
      _saveToLocal();
    }
  }

  List<Suggestion> getActiveSuggestions() {
    return suggestions.where((s) => !s.isArchived).toList();
  }

  List<Suggestion> getArchivedSuggestions() {
    return suggestions.where((s) => s.isArchived).toList();
  }

  List<Suggestion> getSuggestionsByStatus(String status) {
    return suggestions
        .where((s) => s.status == status && !s.isArchived)
        .toList();
  }

  List<Suggestion> getSuggestionsByDepartment(String department) {
    return suggestions.where((s) => s.department == department).toList();
  }

  List<Suggestion> searchSuggestions(String query) {
    final q = query.toLowerCase();
    return suggestions
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.description.toLowerCase().contains(q) ||
              s.employeeName.toLowerCase().contains(q) ||
              s.department.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q),
        )
        .toList();
  }

  void _saveToLocal() {
    final data = suggestions.map((s) => s.toMap()).toList();
    box.write('suggestions', data);
  }

  void loadSuggestions() {
    final data = box.read<List>('suggestions');
    if (data != null) {
      suggestions.value = data
          .map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  int getTotalPending() =>
      suggestions.where((s) => s.status == "Pending").length;
  int getTotalApproved() =>
      suggestions.where((s) => s.status == "Approved").length;
  int getTotalRejected() =>
      suggestions.where((s) => s.status == "Rejected").length;

  String getTopDepartment() {
    final deptVotes = <String, int>{};
    for (var s in suggestions) {
      if (s.status == "Approved") {
        deptVotes[s.department] = (deptVotes[s.department] ?? 0) + s.likes;
      }
    }
    if (deptVotes.isEmpty) return "N/A";
    return deptVotes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
