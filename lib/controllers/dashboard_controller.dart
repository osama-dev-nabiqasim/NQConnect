import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/models/section_model.dart';

class DashboardController extends GetxController {
  // Role-based sections

  // 💡 HR Role ke liye Admin Sections
  List<Section> eventAdminSections = [
    Section(
      name: "Create Event",
      icon: Icons.add_box,
      route: "/event_create",
      fullWidth: true, // ✅ Admin/HR: Create Event full width
    ),
    Section(
      name: "Manage Events",
      icon: Icons.manage_search,
      route: "/event_management",
    ),
    Section(
      name: "Events Analytics",
      icon: Icons.event_note,
      route: "/eventanalytics",
    ),
  ];

  // ------------------------Employee Section-----------------------------

  List<Section> employeeSections = [
    Section(
      name: "Upcoming Events",
      icon: Icons.event_available,
      route: "/events",
      fullWidth: false,
    ),
    // Section(name: "My Tasks", icon: Icons.task, route: "/tasks"),
    Section(
      name: "Suggestion Box",
      icon: Icons.lightbulb_outline,
      route: "/suggestions",
    ),
    Section(
      name: "Vote on Suggestions",
      icon: Icons.how_to_vote,
      route: "/votes",
    ),
    Section(
      name: "Logout",
      icon: Icons.logout_outlined,
      route: "",
      fullWidth: true,
    ),
  ];

  // ------------------------Manager Section-----------------------------

  List<Section> managerSections = [
    Section(
      name: "Upcoming Events",
      icon: Icons.event,
      route: "/events",
      // fullWidth: true,
    ),
    // Section(
    //   name: "Task Assignment",
    //   icon: Icons.assignment,
    //   route: "/task_assignment",
    // ),
    Section(
      name: "Suggestion Insights",
      icon: Icons.insights,
      route: "/suggestion_insights",
    ),
    Section(
      name: "Approve / Reject Suggestions",
      icon: Icons.check_circle,
      route: "/approvals",
    ),
    Section(
      name: "Vote on Suggestions",
      icon: Icons.how_to_vote,
      route: "/manager_vote_on_suggestion",
    ),
    // Section(
    //   name: "Notifications",
    //   icon: Icons.notifications,
    //   route: "/notifications",
    // ),
    Section(name: "Logout", icon: Icons.logout_outlined, route: ""),
  ];
  // ----------------------------------Admin Section--------------------------------------------------------
  List<Section> adminSections = [
    Section(
      name: "Manage Events",
      icon: Icons.manage_search,
      route: "/event_management",
      // fullWidth: false,
    ),
    Section(
      name: "Suggestions Analytics",
      icon: Icons.analytics,
      route: "/suggestion_overview",
      // fullWidth: true,
    ),
    Section(
      name: "Suggestion Management",
      icon: Icons.manage_accounts,
      route: "/suggestion_management",
    ),

    Section(
      name: "Events Analytics",
      icon: Icons.event_note,
      route: "/eventanalytics",
      // fullWidth: true,
    ),

    Section(
      name: "Create Event",
      icon: Icons.add_box,
      route: "/event_create",
      fullWidth: true,
    ),

    Section(
      name: "Logout",
      icon: Icons.logout_outlined,
      route: "",
      fullWidth: true,
    ),
  ];

  // List<Section> getSections(String role) {
  //   if (role == "employee") return employeeSections;
  //   if (role == "manager") return managerSections;
  //   if (role == "admin") return adminSections;
  //   return [];
  // }
  List<Section> getSections(String role, String department) {
    List<Section> baseSections;

    if (role == "admin") {
      baseSections = adminSections;
    } else if (role == "manager") {
      baseSections = managerSections;
    } else {
      // Default to employee sections
      baseSections = employeeSections;
    }

    // 💡 HR Department ke liye Event Management sections add karein
    if ((role == "employee" || role == "manager") &&
        department.toUpperCase() == "HR") {
      // Admin sections ko base sections mein merge karein, lekin duplicates avoid karein
      // Hum eventAdminSections ko baseSections se pehle daalenge
      final allSections = <Section>[...eventAdminSections, ...baseSections];

      // Logout ko sabse last mein rakhne ke liye sort karein
      allSections.sort(
        (a, b) => a.name == "Logout"
            ? 1
            : b.name == "Logout"
            ? -1
            : 0,
      );

      // Duplicate sections ko remove karne ke liye, hum sirf unique routes (ya names) lenge.
      final uniqueSections = <String, Section>{};
      for (var sec in allSections) {
        // Agar Logout hai, toh hamesha usko fullWidth rakhna hai jaisa Admin mein hai.
        if (sec.name == "Logout") {
          uniqueSections[sec.name] = Section(
            name: sec.name,
            icon: sec.icon,
            route: sec.route,
            fullWidth: true,
          );
        } else {
          uniqueSections[sec.name] = sec;
        }
      }
      return uniqueSections.values.toList();
    }

    return baseSections;
  }
}
