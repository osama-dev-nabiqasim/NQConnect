// ignore_for_file: file_names, prefer_const_constructors, deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';

class EmployeeSuggestionFormScreen extends StatefulWidget {
  const EmployeeSuggestionFormScreen({super.key});

  @override
  State<EmployeeSuggestionFormScreen> createState() =>
      _EmployeeSuggestionFormScreenState();
}

class _EmployeeSuggestionFormScreenState
    extends State<EmployeeSuggestionFormScreen> {
  final _descriptionController = TextEditingController();
  // String? _selectedCategory;

  final SuggestionController _controller = Get.find<SuggestionController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  // final TextEditingController _descController = TextEditingController();
  String? _selectedCategory;
  String? _imagePath; // optional
  // final SuggestionController _controller = Get.find<SuggestionController>();
  final List<String> categories = ["Workplace", "Process", "Team", "Other"];

  void _pickImage() async {
    // for now dummy, later integrate with image_picker
    setState(() {
      _imagePath = "assets/images/sample.png"; // placeholder
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final suggestion = Suggestion(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory ?? "General",
      );

      _controller.addSuggestion(suggestion);

      Get.snackbar(
        "Success",
        "Suggestion sent for review",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offNamed("/suggestion_list"); // Navigate to list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,

        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 61, 61, 61).withOpacity(0.1),
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
                    children: [
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
                          if (_imagePath != null)
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
