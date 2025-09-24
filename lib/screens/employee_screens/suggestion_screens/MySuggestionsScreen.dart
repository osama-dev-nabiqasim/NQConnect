// ignore_for_file: dead_code, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/utils/api_constants.dart';
import 'package:nqconnect/utils/responsive.dart';

class MySuggestionsScreen extends StatefulWidget {
  MySuggestionsScreen({super.key});

  @override
  State<MySuggestionsScreen> createState() => _MySuggestionsScreenState();
}

class _MySuggestionsScreenState extends State<MySuggestionsScreen>
    with WidgetsBindingObserver {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();
  final String baseUrl = ApiConstants.imagebaseUrl;

  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Fetch immediately when screen opens
    suggestionController.fetchSuggestions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ Called when app goes background/foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      suggestionController.fetchSuggestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor[0],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "My Suggestions",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final currentEmployeeId = userController.employeeId.value;

        print('✅ USER EMPLOYEE ID: ${userController.employeeId.value}');
        print(
          '✅ ALL SUGGESTION EMPLOYEE IDs: ${suggestionController.suggestions.map((s) => s.employeeId).toList()}',
        );

        // filter only current employee’s suggestions
        final mySuggestions =
            suggestionController.suggestions
                .where(
                  (suggestion) => suggestion.employeeId == currentEmployeeId,
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        print('✅ MY SUGGESTIONS COUNT: ${mySuggestions.length}');
        if (mySuggestions.isEmpty) {
          return Center(child: Text("No suggestions submitted yet."));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await suggestionController.fetchSuggestions();
          },

          child: ListView.builder(
            itemCount: mySuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = mySuggestions[index];
              final totalVotes = suggestion.likes + suggestion.dislikes;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                child: ListTile(
                  title: Text(suggestion.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(suggestion.description),
                      SizedBox(height: 8),
                      Text("Category: ${suggestion.category}"),
                      SizedBox(height: 2),
                      Text(
                        "Date: ${DateFormat('dd MMM yyyy').format(suggestion.createdAt)}",
                      ),
                      SizedBox(height: 2),

                      Text(
                        "Status: ${suggestion.status}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: suggestion.status == "Approved"
                              ? Colors.green
                              : suggestion.status == "Rejected"
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                      if (suggestion.image != null &&
                          suggestion.image!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.image, color: Colors.black),
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
                    ],
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalVotes votes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
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
