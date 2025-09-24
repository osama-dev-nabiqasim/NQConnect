import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';
import 'package:nqconnect/utils/api_constants.dart';
import 'package:nqconnect/utils/responsive.dart';

class VoteOnSuggestionScreen extends StatefulWidget {
  const VoteOnSuggestionScreen({super.key});

  @override
  State<VoteOnSuggestionScreen> createState() => _VoteOnSuggestionScreenState();
}

class _VoteOnSuggestionScreenState extends State<VoteOnSuggestionScreen>
    with WidgetsBindingObserver {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();

  final UserController userController = Get.find<UserController>();
  final String baseUrl = ApiConstants.imagebaseUrl;

  // Track user vote locally
  Map<String, String> userVotes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshSuggestions();
    _loadUserVotes(); // 👈 Load votes from backend on init
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ Refresh whenever app returns to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSuggestions();
    }
  }

  Future<void> _refreshSuggestions() async {
    await suggestionController.fetchSuggestions();
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
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to record vote",
        duration: Duration(seconds: 2),
      );
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

        return RefreshIndicator(
          onRefresh: _refreshSuggestions,
          child: ListView.builder(
            itemCount: unvotedSuggestions.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final suggestion = unvotedSuggestions[index];
              final currentVote = userVotes[suggestion.id.toString()];
              final totallikes = suggestion.likes;
              final totaldislikes = suggestion.dislikes;

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
                  subtitle: Text(
                    "Category: ${suggestion.category} • 👍 $totallikes • 👎 $totaldislikes",
                  ),
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
                            "Created: ${DateFormat('dd MMM yyyy').format(suggestion.createdAt.toLocal())}",
                            style: const TextStyle(color: Colors.black54),
                          ),

                          if (suggestion.image != null &&
                              suggestion.image!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.image,
                                color: Colors.black,
                              ),
                              label: const Text(
                                "View Image",
                                style: TextStyle(color: Colors.black),
                              ),

                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImageView(
                                      imageUrl: "$baseUrl${suggestion.image!}",
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  63,
                                  255,
                                  255,
                                  255,
                                ),
                              ),
                            ),
                          ],

                          // ClipRRect(
                          //   borderRadius: BorderRadius.circular(8),
                          //   child: Image.network(
                          //     "$baseUrl${suggestion.image!}",
                          //     //  suggestion.image!,
                          //     height: 120,
                          //     fit: BoxFit.cover,
                          //     // errorBuilder: (context, error, stackTrace) =>
                          //     //     const Text('Image not available'),
                          //   ),
                          // ),
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
                                    backgroundColor:
                                        Colors.green, // ✅ green background
                                    foregroundColor:
                                        Colors.white, // white text/icon
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _vote(suggestion, "dislike"),
                                  icon: const Icon(Icons.thumb_down),
                                  label: const Text("Dislike"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.red, // ✅ green background
                                    foregroundColor:
                                        Colors.white, // white text/icon
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
          ),
        );
      }),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'Image not available',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
