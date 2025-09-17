// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/utils/responsive.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _sendResetCode() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String phonenumber = _phoneController.text.trim();

      Get.snackbar(
        "Success",
        "OTP sent to $email and $phonenumber",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.toNamed("/enterotpscreen");
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
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Forgot Password",
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
            // begin: Alignment.topLeft,
            // end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth(context) * 0.02,
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight(context) * 0.12),
              // Logo
              Center(
                child: Image.asset(
                  "assets/images/NQLogo.png",
                  height: screenHeight(context) * 0.1,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),

              // Glassy Card Container
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
                            "Reset Your Password",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Enter your registered email and phone number to receive OTP.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 30),

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              } else if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
                              ).hasMatch(value)) {
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.white,
                              ),
                              hintText: "Email",
                              labelText: "Email",
                              labelStyle: TextStyle(color: Colors.white),
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
                              enabledBorder: OutlineInputBorder(
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

                          // Phone # Input
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                              // Custom formatter to add dash after 3 digits
                              _PakistanPhoneFormatter(),
                            ],
                            validator: (value) {
                              final digitsOnly =
                                  value?.replaceAll('-', '') ?? '';
                              if (digitsOnly.isEmpty) {
                                return "Please enter your phone number";
                              } else if (!RegExp(
                                r'^3[0-9]{9}$',
                              ).hasMatch(digitsOnly)) {
                                return "Enter a valid 10-digit phone number starting with 3";
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "+92",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              hintText: "3XX-XXXXXXX",
                              labelText: "Phone Number",
                              labelStyle: TextStyle(color: Colors.white),
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
                              enabledBorder: OutlineInputBorder(
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

                          // Send Code Button
                          GestureDetector(
                            onTap: _sendResetCode,
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
                                  "Send Code",
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

class _PakistanPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    final newText = newValue.text;
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d]'), '');

    // If empty, return as is
    if (digitsOnly.isEmpty) return newValue;

    // Limit to 10 digits
    final limitedDigits = digitsOnly.length > 10
        ? digitsOnly.substring(0, 10)
        : digitsOnly;

    // Format as 3XX-XXXXXXX
    String formattedText = limitedDigits;
    if (limitedDigits.length > 3) {
      formattedText =
          '${limitedDigits.substring(0, 3)}-${limitedDigits.substring(3)}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
