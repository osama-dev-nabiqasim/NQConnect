import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/models/section_model.dart';

class DashboardController extends GetxController {
  // Role-based sections

  // ------------------------Employee Section-----------------------------

  List<Section> employeeSections = [
    Section(
      name: "Upcoming Events",
      icon: Icons.event_available,
      route: "/events",
      fullWidth: true,
    ),
    Section(name: "My Tasks", icon: Icons.task, route: "/tasks"),
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
    Section(name: "Logout", icon: Icons.logout_outlined, route: ""),
  ];

  // ------------------------Manager Section-----------------------------

  List<Section> managerSections = [
    Section(
      name: "Upcoming Events",
      icon: Icons.event,
      route: "/events",
      fullWidth: true,
    ),
    Section(
      name: "Task Assignment",
      icon: Icons.assignment,
      route: "/task_assignment",
    ),
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
    Section(
      name: "Notifications",
      icon: Icons.notifications,
      route: "/notifications",
    ),
    Section(name: "Logout", icon: Icons.logout_outlined, route: ""),
  ];
  // ----------------------------------Admin Section--------------------------------------------------------
  List<Section> adminSections = [
    Section(
      name: "Events Overview",
      icon: Icons.event_note,
      route: "/events", // list + respond
      fullWidth: true,
    ),
    Section(name: "Create Event", icon: Icons.add_box, route: "/event_create"),
    Section(
      name: "Manage Events",
      icon: Icons.manage_search,
      route: "/event_management",
    ),

    Section(
      name: "Suggestion Management",
      icon: Icons.manage_accounts,
      route: "/suggestion_management",
    ),

    Section(
      name: "Notifications",
      icon: Icons.notifications,
      route: "/notifications",
    ),
    Section(name: "Logout", icon: Icons.logout_outlined, route: ""),
  ];

  List<Section> getSections(String role) {
    if (role == "employee") return employeeSections;
    if (role == "manager") return managerSections;
    if (role == "admin") return adminSections;
    return [];
  }
}
