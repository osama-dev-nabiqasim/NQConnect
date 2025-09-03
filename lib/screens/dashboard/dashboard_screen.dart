// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/controllers/dashboard_controller.dart';
import 'package:nqconnect/models/section_model.dart';
import 'package:nqconnect/utils/responsive.dart';

class DashboardScreen extends StatelessWidget {
  final UserController userController = Get.find<UserController>();
  final DashboardController controller = Get.put(DashboardController());

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("No")),
          TextButton(
            onPressed: () {
              userController.clearUserData();
              Get.snackbar(
                "",
                "Loggedout Successful",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              Get.offAllNamed('/login');
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, Section section) {
    return GestureDetector(
      onTap: () {
        if (section.name == "Logout") {
          _logout(context);
        } else {
          Get.toNamed(section.route);
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(section.icon, size: 50, color: Colors.blue.shade900),
              SizedBox(height: 12),
              Text(
                section.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.font(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBasedLayout(BuildContext context, String role) {
    final sections = controller.getSections(role);

    List<Widget> children = [];
    for (int i = 0; i < sections.length; i++) {
      final sec = sections[i];
      if (sec.fullWidth) {
        // Full width section
        children.add(_buildSectionCard(context, sec));
        children.add(SizedBox(height: 16));
      } else {
        // Pair side by side (except logout if last)
        if (i + 1 < sections.length && !sections[i + 1].fullWidth) {
          children.add(
            Row(
              children: [
                Expanded(child: _buildSectionCard(context, sec)),
                SizedBox(width: 16),
                Expanded(child: _buildSectionCard(context, sections[i + 1])),
              ],
            ),
          );
          children.add(SizedBox(height: 16));
          i++; // skip next
        } else {
          children.add(_buildSectionCard(context, sec));
          children.add(SizedBox(height: 16));
        }
      }
    }

    return Column(children: children);
  }

  @override
  Widget build(BuildContext context) {
    final role = userController.role.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: Responsive.font(context, 28),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildRoleBasedLayout(context, role),
      ),
    );
  }
}
