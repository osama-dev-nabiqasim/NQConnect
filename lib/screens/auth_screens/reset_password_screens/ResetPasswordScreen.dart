// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/utils/responsive.dart';
import 'package:nqconnect/services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final email = Get.arguments != null
          ? Get.arguments['email'] as String?
          : null;
      final resetCode = Get.arguments != null
          ? Get.arguments['reset_code'] as String?
          : null;

      if (email == null || resetCode == null) {
        Get.snackbar(
          "Error",
          "Missing email or reset code",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      try {
        await ApiService().resetPassword(
          email,
          resetCode,
          _passwordController.text.trim(),
        );
        Get.snackbar(
          "Success",
          "Password Reset Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Clear stored reset_email/debug_otp if you like
        await ApiService.storage.delete(key: 'reset_email');
        await ApiService.storage.delete(key: 'debug_otp');

        Get.offAllNamed("/login"); // Go back to login
      } catch (e) {
        Get.snackbar(
          "Error",
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          /* optional: clear loading state */
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Reset Password",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: screenWidth(context),
        height: screenHeight(context),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.6,
            colors: [
              const Color.fromARGB(255, 87, 103, 116), // near white
              Color(0xFFF4F6F9), // light greyish
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth(context) * 0.05,
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight(context) * 0.12),
              Center(
                child: Icon(
                  Icons.lock_reset,
                  size: screenHeight(context) * 0.12,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),

              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "Create New Password",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Your new password must be different.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 30),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter password";
                              } else if (value.length < 5) {
                                return "Password must be at least 5 characters";
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                              ),
                              hintText: "New Password",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmController,
                            obscureText: true,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              hintText: "Confirm Password",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),

                          GestureDetector(
                            onTap: _resetPassword,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.buttonPrimary,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: Offset(4, 4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Reset Password",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
