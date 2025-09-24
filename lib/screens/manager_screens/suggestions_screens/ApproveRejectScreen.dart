// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';
import 'package:nqconnect/utils/api_constants.dart';
import 'package:nqconnect/utils/responsive.dart';

class ApproveRejectScreen extends StatefulWidget {
  final String managerDepartment;

  const ApproveRejectScreen({Key? key, required this.managerDepartment})
    : super(key: key);

  @override
  State<ApproveRejectScreen> createState() => _ApproveRejectScreenState();
}

class _ApproveRejectScreenState extends State<ApproveRejectScreen>
    with WidgetsBindingObserver {
  final SuggestionController controller = Get.find<SuggestionController>();
  final UserController userController = Get.find<UserController>();
  final String baseUrl = ApiConstants.imagebaseUrl;

  /// Track which cards are expanded
  final RxSet<int> _expanded = <int>{}.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 👈 observe lifecycle
    // first load
    controller.fetchSuggestions(); // ✅ immediate refresh
  }

  // 🔑 Called whenever app comes to foreground or page is revisited
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.fetchSuggestions(); // ✅ re-fetch every time
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _vote(Suggestion suggestion, String type) async {
    final suggestionId = suggestion.id.toString();
    final employeeId = userController.employeeId.value;
    try {
      await controller.voteOnSuggestion(suggestionId, type, employeeId);
    } catch (_) {
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
        title: const Text("Approve / Reject Suggestions"),
        backgroundColor: AppColors.appbarColor[0],
        centerTitle: true,
      ),
      body: Obx(() {
        final deptSuggestions =
            controller.suggestions
                .where((s) => s.department == widget.managerDepartment)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (deptSuggestions.isEmpty) {
          return const Center(
            child: Text("No suggestions for your department!"),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchSuggestions(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: deptSuggestions.length,
            itemBuilder: (context, index) {
              final s = deptSuggestions[index];
              final isExpanded = _expanded.contains(index);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 4,
                child: ExpansionTile(
                  key: ValueKey(s.id),
                  initiallyExpanded: false,
                  onExpansionChanged: (open) {
                    open ? _expanded.add(index) : _expanded.remove(index);
                  },
                  leading: Icon(
                    Icons.lightbulb_outline,
                    color: s.status == "Pending"
                        ? Colors.orange
                        : s.status == "Approved"
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    s.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    s.status,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: s.status == "Approved"
                          ? Colors.green
                          : s.status == "Rejected"
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),
                  children: [
                    // Expanded details
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.description,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "By: ${s.employeeName}  —  ${s.employeeId}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Text(
                            "Date: ${DateFormat('dd MMM yyyy').format(s.createdAt.toLocal())}",
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
                          const SizedBox(height: 8),

                          if (s.status == "Pending")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: () async {
                                    await controller.approveSuggestionById(
                                      s.id.toString(),
                                    );
                                    _vote(s, 'like'); // manager's vote
                                    Get.snackbar(
                                      "Approved",
                                      "${s.title} approved successfully",
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      duration: Duration(seconds: 2),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await controller.rejectSuggestionById(
                                      s.id.toString(),
                                    );
                                    Get.snackbar(
                                      "Rejected",
                                      "${s.title} rejected successfully",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      duration: Duration(seconds: 2),
                                    );
                                  },
                                ),
                              ],
                            )
                          else
                            Container(),
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
