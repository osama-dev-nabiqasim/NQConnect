// ignore_for_file: deprecated_member_use, sized_box_for_whitespace
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/services/api_service.dart';
import 'package:nqconnect/utils/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isButtonEnabled = false;

  // final UserController userController = Get.put(UserController());
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _employeeIdController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      isButtonEnabled =
          _employeeIdController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final employeeId = _employeeIdController.text.trim();
      final password = _passwordController.text.trim();

      try {
        setState(
          () => isButtonEnabled = false,
        ); // Disable button during API call
        // Get.snackbar(
        //   "Please wait",
        //   "Logging in...",
        //   snackPosition: SnackPosition.BOTTOM,
        //   duration: Duration(seconds: 2),
        // );

        // 👇 Call backend API
        final apiService = ApiService();
        final result = await apiService.login(employeeId, password);

        // 👇 Extract user data
        final user = result['user'];
        final token = result['token'];

        print('✅ FULL USER OBJECT: $user');
        print('✅ KEYS IN USER: ${user.keys}');

        // 👇 Save in controller
        userController.setUserData(
          user['Employee_ID'] ?? '', // 👈 Abhi yeh line galat ho sakti hai
          user['name'] ?? '',
          user['role'] ?? '',
          user['department'] ?? '',
        );

        print(
          '✅ AFTER LOGIN - EMPLOYEE ID: ${userController.employeeId.value}',
        );
        Get.snackbar(
          "Login Successful",
          "Welcome, ${user['name']} (${user['department']})",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // 👇 Clear fields
        _employeeIdController.clear();
        _passwordController.clear();

        // 👇 Navigate to dashboard
        Get.offNamed('/dashboard');
      } catch (e) {
        Get.snackbar(
          "Login Failed",
          e.toString().replaceAll("Exception: ", ""),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          icon: Icon(Icons.error_outline, color: Colors.white),
        );
      } finally {
        setState(() => isButtonEnabled = true);
      }
    }
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false, // 🚀 ye Drawer icon hata dega
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          child: Stack(
            children: [
              // Top Gradient Background
              Container(
                height: screenHeight / 2.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade900,
                      Colors.blue.shade700.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // White card container
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20,
                  sigmaY: 20,
                ), // 👈 glass blur

                child: Container(
                  margin: EdgeInsets.only(top: screenHeight / 3),
                  height: screenHeight / 1.5,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    // gradient: RadialGradient(
                    //   center: Alignment.center,
                    //   radius: 1.2,
                    //   colors: [
                    //     const Color.fromARGB(255, 255, 255, 255),
                    //     const Color(0xFFE6E6E6),
                    //   ],
                    //   // begin: Alignment.topLeft,
                    //   // end: Alignment.bottomRight,
                    // ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                ),
              ),

              // Login Form
              Positioned(
                top: screenHeight / 15,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/NQLogo.png",
                      height: screenHeight * 0.125,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),

                    Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.2,
                            colors: [Colors.grey.shade200, Colors.white70],
                            // begin: Alignment.topLeft,
                            // end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                "Login Page",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 30),

                              _employeeIdField(),
                              SizedBox(height: 20),
                              _passwordField(),
                              SizedBox(height: 30),

                              _loginButton(context),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.toNamed('/forgotpassword');
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _employeeIdField() {
    return Material(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      borderRadius: BorderRadius.circular(18),
      child: TextFormField(
        controller: _employeeIdController,
        validator: (value) =>
            value == null || value.isEmpty ? "Employee ID required" : null,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.blue.shade900),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          labelText: "Employee ID",
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Material(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      borderRadius: BorderRadius.circular(18),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !isPasswordVisible,
        validator: (value) =>
            value == null || value.isEmpty ? "Password required" : null,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.blue.shade900),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          labelText: "Password",
          prefixIcon: Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return GestureDetector(
      onTap: isButtonEnabled ? _login : null,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: isButtonEnabled
                ? AppColors.buttonPrimaryLinearGradient
                : AppColors.buttonDisabledLinearGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              "LOGIN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
