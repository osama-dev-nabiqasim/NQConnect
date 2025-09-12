// ignore_for_file: use_key_in_widget_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 1. Initialize GetStorage FIRST
  await GetStorage.init();

  // 👇 2. Initialize SharedPreferences (if using)
  await SharedPreferences.getInstance();

  // 👇 3. Safe async controller initialization
  try {
    await Get.putAsync(() async {
      final controller = UserController();
      await controller.loadFromPrefs();
      return controller;
    });
  } catch (e) {
    print('⚠️ UserController failed to load: $e');
    Get.put(UserController()); // Fallback
  }

  // 👇 4. Now put other controllers (sync is safe now)
  Get.put(SuggestionController());

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
      initialRoute: '/splash',
      getPages: AppRoutes.routes,
    );
  }
}
