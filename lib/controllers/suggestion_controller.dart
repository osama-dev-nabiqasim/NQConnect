// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class SuggestionController extends GetxController {
  var suggestions = <Suggestion>[].obs;

  void addSuggestion(Suggestion suggestion) {
    suggestions.add(suggestion);
  }
}
