// ignore_for_file: dead_code, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/utils/responsive.dart';

class MySuggestionsScreen extends StatelessWidget {
  final SuggestionController suggestionController =
      Get.find<SuggestionController>();
  final UserController userController = Get.find<UserController>();

  MySuggestionsScreen({super.key});

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

        return ListView.builder(
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
                      'Date: ${suggestion.createdAt.toString().split(' ')[0]}',
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
        );
      }),
    );
  }
}
