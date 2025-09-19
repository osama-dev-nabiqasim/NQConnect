// ignore_for_file: file_names, prefer_const_constructors, deprecated_member_use, avoid_print

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/utils/responsive.dart';
import 'package:http_parser/http_parser.dart';
import '../../../controllers/suggestion_controller.dart';

class EmployeeSuggestionFormScreen extends StatefulWidget {
  const EmployeeSuggestionFormScreen({super.key});

  @override
  State<EmployeeSuggestionFormScreen> createState() =>
      _EmployeeSuggestionFormScreenState();
}

class _EmployeeSuggestionFormScreenState
    extends State<EmployeeSuggestionFormScreen> {
  final _descriptionController = TextEditingController();
  final UserController userController = Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  String? _selectedCategory;
  // String? _imagePath; // optional

  File? _pickedImage;

  final List<String> categories = ["Workplace", "Process", "Team", "Other"];

  // void _pickImage() async {
  //   // for now dummy, later integrate with image_picker
  //   setState(() {
  //     _imagePath = "assets/images/sample.png"; // placeholder
  //   });
  // }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  // void _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       // 👇 Prepare data for API
  //       final data = {
  //         'title': _titleController.text.trim(),
  //         'description': _descriptionController.text.trim(),
  //         'category': _selectedCategory ?? "Workplace",
  //         'employee_id': userController.employeeId.value,
  //         'employee_name': userController.userName.value,
  //         'department': userController.department.value,
  //       };
  //       print('✅ SUBMIT DATA: $data');

  //       // 👇 Call backend API (you need to implement this in ApiService)
  //       final response = await http.post(
  //         Uri.parse(
  //           'http://10.0.2.2:5000/api/suggestions',
  //         ), // 👈 Your backend URL
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode(data),
  //       );

  //       print('✅ RESPONSE STATUS: ${response.statusCode}'); // 👈 DEBUG
  //       print('✅ RESPONSE BODY: ${response.body}'); // 👈 DEBUG

  //       if (response.statusCode == 201 || response.statusCode == 200) {
  //         Get.snackbar(
  //           "Success",
  //           "Suggestion sent for review",
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.green,
  //           colorText: Colors.white,
  //         );

  //         final suggestionController = Get.find<SuggestionController>();
  //         await suggestionController.fetchSuggestions();

  //         Get.offNamed("/my_suggestions"); // Navigate to list
  //       } else {
  //         Get.snackbar("Error", "Failed to submit suggestion");
  //       }
  //     } catch (e) {
  //       Get.snackbar("Error", "Network error: $e");
  //     }
  //   }
  // }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final uri = Uri.parse('http://10.0.2.2:5000/api/suggestions');
      final request = http.MultipartRequest('POST', uri)
        ..fields['title'] = _titleController.text.trim()
        ..fields['description'] = _descriptionController.text.trim()
        ..fields['category'] = _selectedCategory ?? 'Workplace'
        ..fields['employee_id'] = userController.employeeId.value
        ..fields['employee_name'] = userController.userName.value
        ..fields['department'] = userController.department.value;

      if (_pickedImage != null) {
        final ext = _pickedImage!.path.split('.').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _pickedImage!.path,
            contentType: MediaType('image', ext),
          ),
        );
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final status = response.statusCode;
      print('✅ RESPONSE STATUS: $status');
      print('✅ RESPONSE BODY: $respStr');
      if (status == 200 || status == 201) {
        Get.snackbar(
          "Success",
          "Suggestion sent for review",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Get.find<SuggestionController>().fetchSuggestions();
        Get.offNamed("/my_suggestions");
      } else {
        Get.snackbar("Error", "Failed to submit suggestion ($status)");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor[0],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "New Suggestion",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // gradient: RadialGradient(
          //   center: Alignment.center,
          //   radius: 1.4,
          //   colors: [Colors.blue.shade900, Colors.blue.shade400],
          // ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        61,
                        61,
                        61,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color.fromARGB(
                          255,
                          143,
                          143,
                          143,
                        ).withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Employee ID: ${userController.employeeId.value}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Email: ${userController.email.value}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          SizedBox(height: 20),

                          // Title
                          TextFormField(
                            controller: _titleController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Enter title"
                                : null,
                            style: TextStyle(color: Colors.black),
                            decoration: _inputDecoration("Title", Icons.title),
                          ),
                          SizedBox(height: 20),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            validator: (value) => value == null || value.isEmpty
                                ? "Enter description"
                                : null,
                            style: TextStyle(color: Colors.black),
                            maxLines: 4,
                            decoration: _inputDecoration(
                              "Description",
                              Icons.description,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Category Dropdown
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            style: TextStyle(color: Colors.black),
                            decoration: _inputDecoration(
                              "Category",
                              Icons.category,
                            ),
                            value: _selectedCategory,
                            items: categories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(
                                      cat,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() => _selectedCategory = val);
                            },
                            validator: (value) =>
                                value == null ? "Select a category" : null,
                          ),
                          SizedBox(height: 20),

                          // Optional Image
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.image),
                                label: Text("Upload Image"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              if (_pickedImage != null)
                                Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                          SizedBox(height: 30),

                          // Submit Button
                          GestureDetector(
                            onTap: _submitForm,
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
                                  "Submit Suggestion",
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
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => Get.toNamed("/my_suggestions"),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade700, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      "My Submitted Suggestions",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 16,
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
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      labelText: label,
      labelStyle: TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.black54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.blue.shade700,
          width: 1.5,
        ), // Blue when focused
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.red), // Red for errors
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.red,
          width: 1.5,
        ), // Red when focused with error
      ),
    );
  }
}
