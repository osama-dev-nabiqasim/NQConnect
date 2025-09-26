// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  var employeeId = ''.obs;
  var userName = ''.obs;
  var role = ''.obs;
  var department = ''.obs;
  var email = ''.obs;
  var token = ''.obs; // 👈 Add this

  // 👇 Save user + token
  void setUserData(
    String? id,
    String? name,
    String? userRole,
    String? dept,
    String? userEmail, {
    String? jwtToken,
  }) {
    employeeId.value = id ?? ''; // 👈 Save kar raha hai
    userName.value = name ?? '';
    role.value = userRole ?? '';
    department.value = dept ?? '';
    email.value = userEmail ?? '';
    token.value = jwtToken ?? '';
    _saveToPrefs(id, name, userRole, dept, userEmail, jwtToken);
  }

  // 👇 Load from local storage (optional — for auto-login)
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        setUserData(
          user['Employee_ID'] ?? '',
          user['name'] ?? '',
          user['role'] ?? '',
          user['department'] ?? '',
          user['email'] ?? '',
        );
      }
    } catch (e) {
      print('⚠️ Failed to load user: $e');
    }
  }

  // 👇 Clear everything
  void clearUserData() async {
    employeeId.value = '';
    userName.value = '';
    role.value = '';
    department.value = '';
    token.value = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // 👇 Private helper
  Future<void> _saveToPrefs(
    String? id,
    String? name,
    String? role,
    String? dept,
    String? email,
    String? jwtToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'user',
      jsonEncode({
        'Employee_ID': id,
        'name': name,
        'role': role,
        'department': dept,
        'email': email,
        'token': jwtToken,
      }),
    );
  }
}
