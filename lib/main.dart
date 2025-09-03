// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/screens/dashboard/dashboard_screen.dart';
import 'package:nqconnect/screens/login/login_screen.dart';

void main() {
  Get.put(UserController(), permanent: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
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
        // GetPage(name: '/profile', page: () => ProfileScreen()),
        // GetPage(name: '/tasks', page: () => TasksScreen()),
        // GetPage(name: '/messages', page: () => MessagesScreen()),
        // GetPage(name: '/reports', page: () => ReportsScreen()),
        // GetPage(name: '/settings', page: () => SettingsScreen()),
        // GetPage(name: '/logout', page: () => LogoutScreen()),
      ],
    );
  }
}
