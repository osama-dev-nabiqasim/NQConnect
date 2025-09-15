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
        final deptSuggestions = controller.suggestions
            .where((s) => s.department == managerDepartment)
            .toList();
        // final deptSuggestions = controller.getDepartmentSuggestions(managerDepartment);

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
              elevation: 4,
              child: ListTile(
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
                // subtitle: Text(
                //   "${s.description}\nStatus: ${s.status}\nBy: ${s.employeeId}",
                // ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text("Status: ${s.status}"),
                    Text("By: ${s.employeeId}"),
                  ],
                ),
                isThreeLine: true,
                trailing: s.status == "Pending"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await controller.approveSuggestionById(
                                s.id.toString(),
                              );
                              Get.snackbar(
                                "Approved",
                                "${s.title} approved successfully",
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await controller.rejectSuggestionById(
                                s.id.toString(),
                              );
                              Get.snackbar(
                                "Rejected",
                                "${s.title} rejected successfully",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: s.status == "Approved"
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          s.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: s.status == "Approved"
                                ? Colors.green
                                : Colors.red,
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
