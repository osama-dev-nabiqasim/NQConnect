// suggestion_controller.dart
import 'package:get/get.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class SuggestionController extends GetxController {
  var suggestions = <Suggestion>[].obs;

  void addSuggestion(Suggestion suggestion) {
    suggestions.add(suggestion);
  }

  void approveSuggestion(int index) {
    suggestions[index].status = "Approved";
    suggestions.refresh();
  }

  void rejectSuggestion(int index) {
    suggestions[index].status = "Rejected";
    suggestions.refresh();
  }

  // Sirf specific department ki suggestions return kare
  List<Suggestion> getDepartmentSuggestions(String department) {
    return suggestions.where((s) => s.department == department).toList();
  }
}
