// ignore_for_file: prefer_const_constructors, deprecated_member_use, unused_local_variable

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/utils/responsive.dart';

class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({super.key});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final TextEditingController _emailotpController = TextEditingController();
  final TextEditingController _phoneotpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _isResendAvailable = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _isResendAvailable = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _isResendAvailable = true;
        });
        timer.cancel();
      }
    });
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      String emailOtp = _emailotpController.text.trim();
      String phoneOtp = _phoneotpController.text.trim();

      // TODO: Add your OTP verification logic (API/controller call)
      if (emailOtp == "123456" && phoneOtp == "123456") {
        Get.snackbar(
          "Success",
          "OTP Verified Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offNamed("/resetpasswordscreen");
      } else {
        Get.snackbar(
          "Error",
          "Invalid OTP, please try again",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _resendOtp() {
    // TODO: Call API to resend OTP
    Get.snackbar(
      "OTP Sent",
      "A new code has been sent to your email and phone number.",
      backgroundColor: Colors.transparent,
      colorText: Colors.white,
      titleText: Text(
        "OTP Sent",
        style: TextStyle(
          color: Colors.black, // ✅ title color black
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),

      messageText: Text(
        "A new code has been sent to your email and phone number.",
        style: TextStyle(
          color: Colors.black, // ✅ title color black
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );

    _startTimer();
  }

  @override
  void dispose() {
    _emailotpController.dispose();
    _phoneotpController.dispose();
    _timer?.cancel();
    super.dispose();
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
          "Enter Code",
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
            radius: 1.4,
            colors: [Colors.blue.shade900, Colors.blue.shade400],
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
                  Icons.lock_clock,
                  size: screenHeight(context) * 0.12,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),

              // Glass Card
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
                            "Enter OTP",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "We have sent a 6-digit code to your email and phone number.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 30),

                          // Email OTP Input
                          TextFormField(
                            controller: _emailotpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter OTP code";
                              } else if (value.length < 6) {
                                return "OTP must be 6 digits";
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              counterText: "",
                              prefixIcon: Icon(Icons.pin, color: Colors.white),
                              hintText: "Enter Email Code",
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
                          SizedBox(height: 16),

                          // OTP Input
                          TextFormField(
                            controller: _phoneotpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter OTP code";
                              } else if (value.length < 6) {
                                return "OTP must be 6 digits";
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              counterText: "",
                              prefixIcon: Icon(Icons.pin, color: Colors.white),
                              hintText: "Enter Phone Number Code",
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

                          _isResendAvailable
                              ? TextButton(
                                  onPressed: _resendOtp,
                                  child: Text(
                                    "Resend Code",
                                    style: TextStyle(
                                      color: Colors.yellowAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Resend available in $_secondsRemaining s",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),

                          SizedBox(height: 25),

                          // Verify Button
                          GestureDetector(
                            onTap: _verifyOtp,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade800,
                                    Colors.blue.shade600,
                                  ],
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
                                  "Verify",
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
