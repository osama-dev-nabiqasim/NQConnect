// ignore_for_file: unnecessary_cast, unnecessary_import, await_only_futures, unrelated_type_equality_checks

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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _apiService.getSuggestions();
      // 👇 FIX 1: Type cast to Map<String, dynamic>
      suggestions.value = data
          .map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
          .toList();
      _saveToLocal();
    } catch (e) {
      loadSuggestions();
      Get.snackbar('Offline Mode', 'Loaded data from local storage');
    }
  }

  void addSuggestion(Suggestion suggestion) async {
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

      // 👇 FIX 2: Type cast result to Map
      final resultMap = result as Map<String, dynamic>;

      // 👇 FIX 3: Safe ID assignment
      final newId = resultMap['id'];
      if (newId != null) {
        suggestion.id = newId is int
            ? newId
            : int.tryParse(newId.toString()) ?? suggestion.id;
      }
      // 👇 FIX 4: Safe DateTime parsing
      final createdAt = resultMap['created_at'];
      if (createdAt is String) {
        suggestion.createdAt = DateTime.parse(createdAt);
      } else {
        suggestion.createdAt = DateTime.now();
      }

      // 👇 FIX 5: Ensure unique ID
      if (suggestion.id <= 0) {
        suggestion.id = DateTime.now().millisecondsSinceEpoch;
      }

      suggestions.add(suggestion);
      _saveToLocal();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add suggestion');
    }
  }

  Future<void> updateSuggestionStatus(
    String suggestionId,
    String newStatus,
    String reviewedBy,
    String? comments,
  ) async {
    try {
      final data = {
        'status': newStatus,
        'reviewed_by': reviewedBy,
        'comments': comments,
      };

      await _apiService.updateSuggestionStatus(suggestionId, data);

      final index = suggestions.indexWhere((s) => s.id == suggestionId);
      if (index != -1) {
        suggestions[index].status = newStatus;
        suggestions[index].reviewedBy = reviewedBy;
        suggestions[index].reviewedAt = DateTime.now();
        suggestions[index].reviewComments = comments;
        suggestions.refresh();

        suggestions[index].statusHistory.add(
          StatusHistory(
            status: newStatus,
            changedBy: reviewedBy,
            changedAt: DateTime.now(),
            comments: comments,
          ),
        );
      }
      _saveToLocal();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }

  Future<void> voteOnSuggestion(
    String suggestionId,
    String type,
    String employeeId,
  ) async {
    try {
      await _apiService.voteOnSuggestion(suggestionId, type, employeeId);

      final index = suggestions.indexWhere((s) => s.id == suggestionId);
      if (index != -1) {
        if (type == "like") {
          suggestions[index].likes++;
        } else if (type == "dislike") {
          suggestions[index].dislikes++;
        }
        _saveToLocal();
        suggestions.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to vote');
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
      // 👇 Optional: Refresh data to reflect changes
      // await fetchSuggestions();
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
      // 👇 Optional: Refresh data to reflect changes
      // await fetchSuggestions();
    }
  }

  Future<void> fetchSuggestions() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getSuggestions();
      suggestions.value = data
          .map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
          .toList();
      _saveToLocal();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load suggestions');
    } finally {
      isLoading.value = false;
    }
  }

  // 👇 Add this method for bulk status update
  void bulkUpdateStatus(
    List<String> suggestionIds,
    String newStatus,
    String reviewedBy,
    String? comments,
  ) async {
    try {
      for (var id in suggestionIds) {
        final index = suggestions.indexWhere((s) => s.id.toString() == id);
        if (index != -1) {
          // 👇 Update locally
          suggestions[index].status = newStatus;
          suggestions[index].reviewedBy = reviewedBy;
          suggestions[index].reviewedAt = DateTime.now();
          suggestions[index].reviewComments = comments;

          // 👇 Add to status history
          suggestions[index].statusHistory.add(
            StatusHistory(
              status: newStatus,
              changedBy: reviewedBy,
              changedAt: DateTime.now(),
              comments: comments ?? 'Bulk action',
            ),
          );

          // 👇 Call backend API
          await _apiService.updateSuggestionStatus(id, {
            'status': newStatus,
            'reviewed_by': reviewedBy,
            'comments': comments,
          });
        }
      }
      _saveToLocal();
      suggestions.refresh();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status in bulk');
    }
  }

  // 👇 Add this method for bulk archive
  void bulkArchive(List<String> suggestionIds, bool archive) async {
    try {
      for (var id in suggestionIds) {
        final index = suggestions.indexWhere((s) => s.id.toString() == id);
        if (index != -1) {
          // 👇 Update locally
          suggestions[index].isArchived = archive;

          // 👇 If you have backend API for archive — call it here
          // await _apiService.archiveSuggestion(id, archive);
        }
      }
      _saveToLocal();
      suggestions.refresh();
    } catch (e) {
      Get.snackbar('Error', 'Failed to archive in bulk');
    }
  }

  void archiveSuggestion(String suggestionId, bool archive) {
    final index = suggestions.indexWhere((s) => s.id == suggestionId);
    if (index != -1) {
      suggestions[index].isArchived = archive;
      _saveToLocal();
      suggestions.refresh();
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
    return suggestions
        .where((s) => s.department == department && !s.isArchived)
        .toList();
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

  List<Suggestion> getDepartmentSuggestions(String department) {
    return suggestions.where((s) => s.department == department).toList();
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
