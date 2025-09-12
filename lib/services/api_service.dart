// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:5000/api';
  // 👇 Add this method inside ApiService class

  Future<Map<String, dynamic>> login(String employeeId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'employee_id': employeeId, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception('Invalid Employee ID or Password. Please try again.');
        }
      } else if (response.statusCode == 401) {
        // 👇 Also handle 401 explicitly
        throw Exception('Invalid Employee ID or Password. Please try again.');
      } else {
        throw Exception('Something went wrong. Please try again later.');
      }
    } catch (e) {
      throw Exception(
        'Unable to connect to server. Please check your internet connection.',
      );
    }
  }

  // Suggestions fetch karein
  Future<List<dynamic>> getSuggestions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/suggestions'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load suggestions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // POST new suggestion
  Future<Map<String, dynamic>> addSuggestion(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/suggestions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        throw Exception('Failed to add suggestion');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT update suggestion status
  Future<void> updateSuggestionStatus(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/suggestions/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST like/dislike
  Future<void> voteOnSuggestion(String id, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/suggestions/$id/vote'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type': type}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to vote');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
