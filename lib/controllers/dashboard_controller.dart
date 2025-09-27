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
      fullWidth: false,
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
    Section(
      name: "Logout",
      icon: Icons.logout_outlined,
      route: "",
      fullWidth: false,
    ),
  ];
  // ----------------------------------Admin Section--------------------------------------------------------
  List<Section> adminSections = [
    Section(
      name: "Create Event",
      icon: Icons.add_box,
      route: "/event_create",
      fullWidth: true,
    ),
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
    final isHR = department.toUpperCase() == "HR";

    if (role == "admin") {
      baseSections = adminSections;
    } else if (role == "manager") {
      baseSections = managerSections;
    } else {
      // Default to employee sections
      baseSections = employeeSections;
    }

    List<Section> finalSections = baseSections
        .map(
          (s) => Section(
            name: s.name,
            icon: s.icon,
            route: s.route,
            fullWidth: s.fullWidth,
          ),
        )
        .toList();

    // ------------------------ Apply New Custom Full-Width Logic ------------------------

    // 💡 HR Department ke liye Event Management sections add karein
    if (role == "employee" && !isHR) {
      finalSections = finalSections.map((sec) {
        if (sec.name == "Upcoming Events") {
          return sec.copyWith(fullWidth: true); // ✅ Upcoming Events full-width
        } else if (sec.name == "Logout") {
          return sec.copyWith(
            fullWidth: true,
          ); // ✅ Employee (non-HR) mein Logout full-width
        }
        return sec.copyWith(fullWidth: false); // Baki sab half width
      }).toList();

      // Condition 2: agr role = employee and depart=HR ho tw logout ka button full width may show nhi ho.
    } else if (role == "employee" && isHR) {
      // 💡 HR Employee ke liye Event Management sections add karein
      finalSections.insertAll(0, eventAdminSections);

      // Update flags in the combined list
      finalSections = finalSections.map((sec) {
        if (sec.name == "Logout") {
          return sec.copyWith(
            fullWidth: false,
          ); // ✅ HR Employee: Logout is NOT full-width
        }
        // Create Event is already true in eventAdminSections
        return sec;
      }).toList();

      // Condition 3: agr role=manager and depart=any except HR, logout ka box full width ho.
    } else if (role == "manager" && !isHR) {
      finalSections = finalSections.map((sec) {
        if (sec.name == "Logout") {
          return sec.copyWith(
            fullWidth: true,
          ); // ✅ Non-HR Manager: Logout full-width
        }
        return sec;
      }).toList();

      // Condition 4: Manager (HR)
    } else if (role == "manager" && isHR) {
      // 💡 HR Manager ke liye Event Management sections add karein
      finalSections.insertAll(0, eventAdminSections);

      // Update flags in the combined list
      finalSections = finalSections.map((sec) {
        if (sec.name == "Logout") {
          return sec.copyWith(
            fullWidth: true,
          ); // ✅ HR Manager: Logout is NOT full-width
        }
        // Create Event is already true in eventAdminSections
        return sec;
      }).toList();
    }

    // Final step for HR/Admin: Remove duplicate "Upcoming Events" if it was added from baseSections
    final uniqueSections = <String, Section>{};
    for (var sec in finalSections) {
      uniqueSections[sec.name] = sec;
    }

    // Logout ko sabse last mein rakhne ke liye sort karein
    final result = uniqueSections.values.toList();
    result.sort(
      (a, b) => a.name == "Logout"
          ? 1
          : b.name == "Logout"
          ? -1
          : 0,
    );

    return result;
  }
}
