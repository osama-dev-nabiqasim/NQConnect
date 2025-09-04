// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/screens/auth_screens/reset_password_screens/EnterOtpScreen.dart';
import 'package:nqconnect/screens/auth_screens/reset_password_screens/ResetPasswordScreen.dart';
import 'package:nqconnect/screens/auth_screens/reset_password_screens/forgot_password.dart';
import 'package:nqconnect/screens/dashboard/dashboard_screen.dart';
import 'package:nqconnect/screens/auth_screens/login_screen.dart';
import 'package:nqconnect/screens/placeholder_screen.dart';
import 'package:nqconnect/screens/suggestion_screens/EmployeeSuggestionFormScreen.dart';

void main() {
  Get.put(UserController(), permanent: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NQconnect",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[900],
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade400,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900], // Dark blue button
            foregroundColor: Colors.white, // Button text color
          ),
        ),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/forgotpassword', page: () => ForgotPasswordScreen()),
        GetPage(name: '/enterotpscreen', page: () => EnterOtpScreen()),
        GetPage(
          name: '/suggestions',
          page: () => EmployeeSuggestionFormScreen(),
        ),

        GetPage(
          name: '/resetpasswordscreen',
          page: () => ResetPasswordScreen(),
        ),
        // Placeholders for now
        // Employee Routes
        GetPage(
          name: '/employee_overview',
          page: () => PlaceholderScreen(title: "Employee Overview"),
        ),
        GetPage(
          name: '/tasks',
          page: () => PlaceholderScreen(title: "My Tasks"),
        ),
        GetPage(
          name: '/suggestions',
          page: () => PlaceholderScreen(title: "Suggestion Box"),
        ),
        GetPage(
          name: '/votes',
          page: () => PlaceholderScreen(title: "Vote on Suggestions"),
        ),

        // Manager Routes
        GetPage(
          name: '/team_overview',
          page: () => PlaceholderScreen(title: "Team Performance Overview"),
        ),
        GetPage(
          name: '/task_assignment',
          page: () => PlaceholderScreen(title: "Task Assignment"),
        ),
        GetPage(
          name: '/suggestion_insights',
          page: () => PlaceholderScreen(title: "Suggestion Insights"),
        ),
        GetPage(
          name: '/approvals',
          page: () => PlaceholderScreen(title: "Approve / Reject Suggestions"),
        ),
        GetPage(
          name: '/activity_feed',
          page: () => PlaceholderScreen(title: "Employee Activity Feed"),
        ),
        GetPage(
          name: '/notifications',
          page: () => PlaceholderScreen(title: "Notifications"),
        ),

        // Admin Routes
        GetPage(
          name: '/suggestion_overview',
          page: () => PlaceholderScreen(title: "System Overview / Analytics"),
        ),
        GetPage(
          name: '/task_overview',
          page: () => PlaceholderScreen(title: "Task Overview"),
        ),
        GetPage(
          name: '/suggestion_management',
          page: () => PlaceholderScreen(title: "Suggestion Management"),
        ),
        GetPage(
          name: '/innovation_analytics',
          page: () => PlaceholderScreen(title: "Innovation Analytics"),
        ),
        GetPage(
          name: '/configurations',
          page: () => PlaceholderScreen(title: "Sections & Configurations"),
        ),
      ],
    );
  }
}
