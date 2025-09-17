// lib/screens/vote_on_suggestion_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';
import 'package:nqconnect/utils/responsive.dart';

class VoteOnSuggestionScreen extends StatefulWidget {
  const VoteOnSuggestionScreen({super.key});

  @override
  State<VoteOnSuggestionScreen> createState() => _VoteOnSuggestionScreenState();
}

class _VoteOnSuggestionScreenState extends State<VoteOnSuggestionScreen> {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();
  final UserController userController = Get.find<UserController>();
  // Track user vote locally
  Map<String, String> userVotes = {};

  @override
  void initState() {
    super.initState();
    _loadUserVotes(); // 👈 Load votes from backend on init
  }

  Future<void> _loadUserVotes() async {
    final approvedSuggestions = suggestionController.suggestions
        .where((s) => s.status == "Approved")
        .toList();

    for (var suggestion in approvedSuggestions) {
      final vote = await suggestionController.getUserVote(
        suggestion.id.toString(),
        userController.employeeId.value, // 👈 Current user's ID
      );
      if (vote != null) {
        setState(() {
          userVotes[suggestion.id.toString()] = vote;
        });
      }
    }
  }

  void _vote(Suggestion suggestion, String type) async {
    final suggestionId = suggestion.id.toString();
    final employeeId = userController.employeeId.value;

    // 👇 First, update local state
    setState(() {
      userVotes[suggestionId] = type;
    });

    try {
      // 👇 Call backend to update vote
      await suggestionController.voteOnSuggestion(
        suggestionId,
        type,
        employeeId,
      );

      Get.snackbar(
        type == "like" ? "Liked!" : "Disliked!",
        "Your vote has been recorded",
        backgroundColor: type == "like" ? Colors.green : Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to record vote");
      // Revert local state on error
      setState(() {
        userVotes.remove(suggestionId);
      });
    }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: AppColors.appbarColor[0],
      ),
      body: Obx(() {
        // 👇 Filter 1: Only approved suggestions
        final approvedSuggestions =
            suggestionController.suggestions
                .where((s) => s.status == "Approved")
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // 👇 Filter 2: Only suggestions where user has NOT voted
        final unvotedSuggestions =
            approvedSuggestions
                .where(
                  (suggestion) =>
                      !userVotes.containsKey(suggestion.id.toString()),
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (unvotedSuggestions.isEmpty) {
          return const Center(child: Text("No new suggestions to vote!"));
        }

        return ListView.builder(
          itemCount: unvotedSuggestions.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final suggestion = unvotedSuggestions[index];
            final currentVote = userVotes[suggestion.id.toString()];

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
                        // Text(
                        //   "Submitted by: ${suggestion.employeeId}",
                        //   style: const TextStyle(color: Colors.black54),
                        // ),
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

                        // 👇 Show only the voted button — or both if not voted
                        if (currentVote != null)
                          ElevatedButton.icon(
                            onPressed: null, // 👈 Disable after vote
                            icon: Icon(
                              currentVote == "like"
                                  ? Icons.thumb_up
                                  : Icons.thumb_down,
                            ),
                            label: Text(
                              currentVote == "like" ? "Liked" : "Disliked",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentVote == "like"
                                  ? Colors.green
                                  : Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _vote(suggestion, "like"),
                                icon: const Icon(Icons.thumb_up),
                                label: const Text("Like"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _vote(suggestion, "dislike"),
                                icon: const Icon(Icons.thumb_down),
                                label: const Text("Dislike"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  foregroundColor: Colors.black,
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
