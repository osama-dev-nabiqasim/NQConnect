// lib/screens/vote_on_suggestion_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class VoteOnSuggestionScreen extends StatefulWidget {
  const VoteOnSuggestionScreen({super.key});

  @override
  State<VoteOnSuggestionScreen> createState() => _VoteOnSuggestionScreenState();
}

class _VoteOnSuggestionScreenState extends State<VoteOnSuggestionScreen> {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();

  // Track user vote locally
  final Map<String, String> userVotes = {}; // {suggestionId: "like"/"dislike"}

  void _vote(Suggestion suggestion, String type) {
    setState(() {
      userVotes[suggestion.id] = type;
    });
    suggestionController.voteOnSuggestion(suggestion.id, type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Vote on Suggestions",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: Obx(() {
        final approvedSuggestions = suggestionController.suggestions
            .where((s) => s.status == "Approved")
            .toList();

        if (approvedSuggestions.isEmpty) {
          return const Center(child: Text("No approved suggestions yet."));
        }

        return ListView.builder(
          itemCount: approvedSuggestions.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final suggestion = approvedSuggestions[index];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(12),
                title: Text(
                  suggestion.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text("Category: ${suggestion.category}"),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(suggestion.description),
                        const SizedBox(height: 8),
                        Text(
                          "Department: ${suggestion.department}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Text(
                          "Created: ${suggestion.createdAt.toLocal().toString().split(' ')[0]}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        if (suggestion.image != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              suggestion.image!,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _vote(suggestion, "like"),
                              icon: const Icon(Icons.thumb_up),
                              label: const Text("Like"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    userVotes[suggestion.id] == "like"
                                    ? Colors.green
                                    : Colors.grey.shade200,
                                foregroundColor:
                                    userVotes[suggestion.id] == "like"
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _vote(suggestion, "dislike"),
                              icon: const Icon(Icons.thumb_down),
                              label: const Text("Dislike"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    userVotes[suggestion.id] == "dislike"
                                    ? Colors.red
                                    : Colors.grey.shade200,
                                foregroundColor:
                                    userVotes[suggestion.id] == "dislike"
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
