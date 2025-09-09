import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nqconnect/models/suggestion_model.dart';
import 'package:nqconnect/models/status_history_model.dart';

class SuggestionController extends GetxController {
  var suggestions = <Suggestion>[].obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadSuggestions();
  }

  void approveSuggestion(int index) {
    if (index >= 0 && index < suggestions.length) {
      suggestions[index].status = "Approved";
      suggestions[index].reviewedAt = DateTime.now();
      // You may want to set reviewedBy here too if available
      saveSuggestions();
      suggestions.refresh();
    }
  }

  void rejectSuggestion(int index) {
    if (index >= 0 && index < suggestions.length) {
      suggestions[index].status = "Rejected";
      suggestions[index].reviewedAt = DateTime.now();
      // You may want to set reviewedBy here too if available
      saveSuggestions();
      suggestions.refresh();
    }
  }

  void addSuggestion(Suggestion suggestion) {
    suggestions.add(suggestion);
    saveSuggestions();
  }

  void updateSuggestionStatus(
    String suggestionId,
    String newStatus,
    String reviewedBy,
    String? comments,
  ) {
    final index = suggestions.indexWhere((s) => s.id == suggestionId);
    if (index != -1) {
      suggestions[index].status = newStatus;
      suggestions[index].reviewedBy = reviewedBy;
      suggestions[index].reviewedAt = DateTime.now();
      suggestions[index].reviewComments = comments;

      // Add to status history
      suggestions[index].statusHistory.add(
        StatusHistory(
          status: newStatus,
          changedBy: reviewedBy,
          changedAt: DateTime.now(),
          comments: comments,
        ),
      );

      saveSuggestions();
      suggestions.refresh();
    }
  }

  void archiveSuggestion(String suggestionId, bool archive) {
    final index = suggestions.indexWhere((s) => s.id == suggestionId);
    if (index != -1) {
      suggestions[index].isArchived = archive;
      saveSuggestions();
      suggestions.refresh();
    }
  }

  // Bulk actions
  void bulkUpdateStatus(
    List<String> suggestionIds,
    String newStatus,
    String reviewedBy,
    String? comments,
  ) {
    for (var id in suggestionIds) {
      final index = suggestions.indexWhere((s) => s.id == id);
      if (index != -1) {
        suggestions[index].status = newStatus;
        suggestions[index].reviewedBy = reviewedBy;
        suggestions[index].reviewedAt = DateTime.now();
        suggestions[index].reviewComments = comments;

        suggestions[index].statusHistory.add(
          StatusHistory(
            status: newStatus,
            changedBy: reviewedBy,
            changedAt: DateTime.now(),
            comments: comments ?? 'Bulk action',
          ),
        );
      }
    }
    saveSuggestions();
    suggestions.refresh();
  }

  void bulkArchive(List<String> suggestionIds, bool archive) {
    for (var id in suggestionIds) {
      final index = suggestions.indexWhere((s) => s.id == id);
      if (index != -1) {
        suggestions[index].isArchived = archive;
      }
    }
    saveSuggestions();
    suggestions.refresh();
  }

  // Filter methods
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

  // ✅ Voting functionality (existing)
  void voteOnSuggestion(String suggestionId, String type) {
    final index = suggestions.indexWhere((s) => s.id == suggestionId);
    if (index != -1) {
      if (type == "like") {
        suggestions[index].likes++;
      } else if (type == "dislike") {
        suggestions[index].dislikes++;
      }
      saveSuggestions();
      suggestions.refresh();
    }
  }

  // ✅ Department suggestions (existing)
  List<Suggestion> getDepartmentSuggestions(String department) {
    return suggestions.where((s) => s.department == department).toList();
  }

  // ✅ Local storage (existing with enhanced data)
  void saveSuggestions() {
    final data = suggestions.map((s) => s.toMap()).toList();
    box.write('suggestions', data);
  }

  void loadSuggestions() {
    final data = box.read<List>('suggestions');
    if (data != null) {
      suggestions.value = data
          .map((e) => Suggestion.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  // Statistics methods (existing)
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
