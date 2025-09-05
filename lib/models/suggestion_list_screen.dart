// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class SuggestionListScreen extends StatelessWidget {
  final SuggestionController controller = Get.put(SuggestionController());
  SuggestionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    final SuggestionController controller = Get.find<SuggestionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submitted Suggestions"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.suggestions.isEmpty) {
          return const Center(
            child: Text(
              "No suggestions yet!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.suggestions.length,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          itemBuilder: (context, index) {
            final Suggestion suggestion = controller.suggestions[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: suggestion.image != null
                    ? Image.file(
                        suggestion.image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.lightbulb_outline, color: Colors.blue),
                title: Text(
                  suggestion.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${suggestion.description}\nCategory: ${suggestion.category ?? "N/A"}",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      }),
    );
  }
}
