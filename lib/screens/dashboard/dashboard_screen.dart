// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use
import 'dart:ui';
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
    final bool isLargeScreen = Responsive.width(context) > 600;
    return GestureDetector(
      onTap: () {
        if (section.name == "Logout") {
          _logout(context);
        } else {
          Get.toNamed(section.route);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 👈 glass blur
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade900.withOpacity(0.9), // 👈 transparency
                  Colors.blue.shade700.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2), // 👈 frosted border
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(6, 6),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  offset: Offset(-6, -6),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.width(context) * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    section.icon,
                    size: isLargeScreen ? 70 : 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: Responsive.height(context) * 0.012),
                  Text(
                    section.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Responsive.font(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
        children.add(SizedBox(height: Responsive.height(context) * 0.016));
      } else {
        // Pair side by side (except logout if last)
        if (i + 1 < sections.length && !sections[i + 1].fullWidth) {
          children.add(
            Row(
              children: [
                Expanded(child: _buildSectionCard(context, sec)),
                SizedBox(width: Responsive.width(context) * 0.04),
                Expanded(child: _buildSectionCard(context, sections[i + 1])),
              ],
            ),
          );
          children.add(SizedBox(height: Responsive.height(context) * 0.016));
          i++; // skip next
        } else {
          children.add(_buildSectionCard(context, sec));
          children.add(SizedBox(height: Responsive.height(context) * 0.016));
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
            fontSize: Responsive.font(
              context,
              Responsive.height(context) * 0.035,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.width(context) * 0.04),
        child: _buildRoleBasedLayout(context, role),
      ),
    );
  }
}
