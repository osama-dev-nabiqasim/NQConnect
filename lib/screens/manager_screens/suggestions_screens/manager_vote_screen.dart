import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';
import 'package:nqconnect/utils/api_constants.dart';
import 'package:nqconnect/utils/responsive.dart';

class ManagerVoteScreen extends StatefulWidget {
  const ManagerVoteScreen({super.key});

  @override
  State<ManagerVoteScreen> createState() => _ManagerVoteScreenState();
}

class _ManagerVoteScreenState extends State<ManagerVoteScreen>
    with WidgetsBindingObserver {
  final suggestionController = Get.find<SuggestionController>();
  final userController = Get.find<UserController>();
  final String baseUrl = ApiConstants.imagebaseUrl;

  /// keep track of votes this manager has cast
  final Map<String, String> managerVotes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadManagerVotes();
  }

  // 🔑 whenever app/page comes to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadManagerVotes(); // ✅ re-fetch on resume
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadManagerVotes() async {
    // all approved suggestions
    final approved = suggestionController.suggestions
        .where((s) => s.status == "Approved")
        .toList();

    for (final s in approved) {
      // already voted?
      final vote = await suggestionController.getUserVote(
        s.id.toString(),
        userController.employeeId.value,
      );

      // auto-like if this manager approved it
      final autoLiked =
          s.department == userController.department.value &&
          s.reviewedBy == userController.employeeId.value;

      if (vote != null || autoLiked) {
        managerVotes[s.id.toString()] = vote ?? "like";
      }
    }
    setState(() {});
  }

  Future<void> _vote(Suggestion s, String type) async {
    final id = s.id.toString();
    final empId = userController.employeeId.value;

    // mark locally so UI updates immediately
    setState(() => managerVotes[id] = type);

    try {
      await suggestionController.voteOnSuggestion(id, type, empId);
      Get.snackbar(
        type == "like" ? "Liked!" : "Disliked!",
        "Your vote has been recorded",
        backgroundColor: type == "like" ? Colors.green : Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      // revert on error
      managerVotes.remove(id);
      setState(() {});
      Get.snackbar(
        "Error",
        "Failed to record vote",
        duration: Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manager Voting",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.appbarColor[0],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // only approved & not yet voted by this manager
        final unvoted =
            suggestionController.suggestions
                .where(
                  (s) =>
                      s.status == "Approved" &&
                      !managerVotes.containsKey(s.id.toString()),
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (unvoted.isEmpty) {
          return const Center(child: Text("No new suggestions to vote on."));
        }

        return RefreshIndicator(
          onRefresh: _loadManagerVotes,
          child: ListView.builder(
            itemCount: unvoted.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final s = unvoted[i];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.all(12),
                  title: Text(
                    s.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Dept: ${s.department} • 👍 ${s.likes} • 👎 ${s.dislikes}",
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.description),
                          const SizedBox(height: 8),
                          Text(
                            "Created: ${DateFormat('dd MMM yyyy').format(s.createdAt.toLocal())}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          if (s.image != null && s.image!.isNotEmpty) ...[
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
                                      imageUrl: "$baseUrl${s.image!}",
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

                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _vote(s, "like"),
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
                                onPressed: () => _vote(s, "dislike"),
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
