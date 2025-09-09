import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class SuggestionController extends GetxController {
  var suggestions = <Suggestion>[].obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadSuggestions();
  }

  void addSuggestion(Suggestion suggestion) {
    suggestions.add(suggestion);
    saveSuggestions();
  }

  void approveSuggestion(int index) {
    suggestions[index].status = "Approved";
    saveSuggestions();
    suggestions.refresh();
  }

  void rejectSuggestion(int index) {
    suggestions[index].status = "Rejected";
    saveSuggestions();
    suggestions.refresh();
  }

  // ✅ Voting persist karega
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

  // ✅ Sirf specific department ki suggestions return kare
  List<Suggestion> getDepartmentSuggestions(String department) {
    return suggestions.where((s) => s.department == department).toList();
  }

  // ✅ Local storage me save
  void saveSuggestions() {
    final data = suggestions.map((s) => s.toMap()).toList();
    box.write('suggestions', data);
  }

  // ✅ Local storage se load
  void loadSuggestions() {
    final data = box.read<List>('suggestions');
    if (data != null) {
      suggestions.value = data
          .map((e) => Suggestion.fromMap(Map<String, dynamic>.from(e)))
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
