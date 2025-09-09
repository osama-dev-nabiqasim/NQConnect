import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';
import 'package:nqconnect/utils/responsive.dart';

class ApproveRejectScreen extends StatelessWidget {
  final String managerDepartment;
  final SuggestionController controller = Get.find<SuggestionController>();

  ApproveRejectScreen({super.key, required this.managerDepartment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approve / Reject Suggestions"),
        backgroundColor: AppColors.appbarColor[0],
        centerTitle: true,
      ),
      body: Obx(() {
        final deptSuggestions = controller.getDepartmentSuggestions(
          managerDepartment,
        );

        if (deptSuggestions.isEmpty) {
          return Center(child: Text("No suggestions for your department!"));
        }

        return ListView.builder(
          itemCount: deptSuggestions.length,
          padding: EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final Suggestion s = deptSuggestions[index];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  Icons.lightbulb_outline,
                  color: s.status == "Pending"
                      ? Colors.orange
                      : s.status == "Approved"
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(s.title),
                subtitle: Text(
                  "${s.description}\nStatus: ${s.status}\nBy: ${s.employeeId}",
                ),
                isThreeLine: true,
                trailing: s.status == "Pending"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () => controller.approveSuggestion(
                              controller.suggestions.indexOf(s),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => controller.rejectSuggestion(
                              controller.suggestions.indexOf(s),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      }),
    );
  }
}
