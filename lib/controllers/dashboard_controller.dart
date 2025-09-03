import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/models/section_model.dart';

class DashboardController extends GetxController {
  // Role-based sections
  List<Section> employeeSections = [
    Section(
      name: "Quick Stats / Overview",
      icon: Icons.dashboard,
      route: "/employee_overview",
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

  List<Section> managerSections = [
    Section(
      name: "Team Performance Overview",
      icon: Icons.bar_chart,
      route: "/team_overview",
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
      name: "Employee Activity Feed",
      icon: Icons.feed,
      route: "/activity_feed",
    ),
    Section(
      name: "Notifications",
      icon: Icons.notifications,
      route: "/notifications",
    ),
    Section(name: "Logout", icon: Icons.logout_outlined, route: ""),
  ];

  List<Section> adminSections = [
    Section(
      name: "System Overview / Analytics",
      icon: Icons.analytics,
      route: "/system_overview",
      fullWidth: true,
    ),
    Section(name: "Task Overview", icon: Icons.task, route: "/task_overview"),
    Section(
      name: "Suggestion Management",
      icon: Icons.manage_accounts,
      route: "/suggestion_management",
    ),
    Section(
      name: "Innovation Analytics",
      icon: Icons.trending_up,
      route: "/innovation_analytics",
    ),
    Section(
      name: "Sections & Configurations",
      icon: Icons.settings,
      route: "/configurations",
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
