// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/notification_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/controllers/dashboard_controller.dart';
import 'package:nqconnect/models/section_model.dart';
import 'package:nqconnect/utils/RotatingCircle.dart';
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
            child: Text("Yes", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, Section section, int index) {
    final bool isLargeScreen = Responsive.width(context) > 600;

    final isCircle = section.name == "Tasks" || section.name == "Suggestions";
    final isWide = section.name == "Logout" || section.name == "Overview";

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (section.name == "Logout") {
            _logout(context);
          } else {
            Get.toNamed(section.route);
          }
        },
        child: AnimatedScale(
          duration: Duration(milliseconds: 200),
          scale: 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.white24,
              borderRadius: BorderRadius.circular(isCircle ? 100 : 20),
              child: Container(
                width: isWide ? double.infinity : null,
                height: isCircle ? 100 : null,
                padding: EdgeInsets.all(Responsive.width(context) * 0.05),
                decoration: BoxDecoration(
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isCircle ? null : BorderRadius.circular(20),
                  gradient: AppColors.secondaryLinearGradient,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: Offset(2, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Color.fromARGB(255, 202, 202, 202),
                          Color.fromARGB(255, 255, 255, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Icon(
                        section.icon,
                        size: isLargeScreen ? 70 : 50,
                        color: Colors.white, // Required for ShaderMask
                      ),
                    ),
                    if (!isCircle) ...[
                      SizedBox(height: 8),
                      Text(
                        section.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Responsive.font(context, 16),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Dark text for light theme
                        ),
                      ),
                    ],
                  ],
                ),
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
      if (sec.fullWidth || sec.name == "Logout" || sec.name == "Overview") {
        children.add(_buildSectionCard(context, sec, i));
        children.add(SizedBox(height: Responsive.height(context) * 0.016));
      } else {
        if (i + 1 < sections.length &&
            !sections[i + 1].fullWidth &&
            sections[i + 1].name != "Logout" &&
            sections[i + 1].name != "Overview") {
          children.add(
            Row(
              children: [
                Expanded(child: _buildSectionCard(context, sec, i)),
                SizedBox(width: Responsive.width(context) * 0.04),
                Expanded(
                  child: _buildSectionCard(context, sections[i + 1], i + 1),
                ),
              ],
            ),
          );
          children.add(SizedBox(height: Responsive.height(context) * 0.016));
          i++;
        } else {
          children.add(_buildSectionCard(context, sec, i));
          children.add(SizedBox(height: Responsive.height(context) * 0.016));
        }
      }
    }
    return Column(children: children);
  }

  @override
  Widget build(BuildContext context) {
    final role = userController.role.value;
    final department = userController.department.value;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        actions: [
          Obx(() {
            final notifController = Get.put(NotificationController());
            final count = notifController.unreadCount;
            return Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black87),
                  onPressed: () => Get.toNamed('/notifications'),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$count',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.font(
              context,
              Responsive.height(context) * 0.028,
            ),
            color: Colors.black87, // dark color
            shadows: [
              Shadow(
                offset: Offset(1, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
        ),

        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // 🔹 Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.backgroundColor,
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),

          // 🔹 Blob Top-Left
          Positioned(top: -80, left: -80, child: GradientRotatingCircle()),

          // 🔹 Blob Bottom-Right
          // Positioned(bottom: -50, right: -50, child: GradientRotatingCircle()),

          // 🔹 Foreground content
          Column(
            children: [
              // 🔹 Welcome Banner (Glassy Look)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ), // blur effect
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                      top: screenHeight(context) * 0.13,
                      left: screenWidth(context) * 0.025,
                      right: screenWidth(context) * 0.025,
                      bottom: screenHeight(context) * 0.014,
                    ),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(
                        0,
                        255,
                        255,
                        255,
                      ).withOpacity(0.25), // glassy transparency
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4), // subtle border
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.0),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "👋 Welcome ${userController.userName.value},",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "$role • $department",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(context) * 0.04,
                    vertical: 10,
                  ),
                  child: _buildRoleBasedLayout(context, role),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
