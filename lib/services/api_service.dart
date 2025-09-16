// lib/services/api_service.dart

// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:5000/api';
  // 👇 Add this method inside ApiService class
  static const storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      print('No JWT token found in storage'); // Debug log
    }
    return token;
  }

  Future<Map<String, dynamic>> login(String employeeId, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'employee_id': employeeId, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      print(
        'Login response: ${response.statusCode} ${response.body}',
      ); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await storage.write(key: 'jwt_token', value: data['token']);
          return data;
        } else {
          throw Exception('Invalid Employee ID or Password. Please try again.');
        }
      } else if (response.statusCode == 401) {
        // 👇 Also handle 401 explicitly
        throw Exception('Invalid Employee ID or Password. Please try again.');
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server is currently offline or experiencing issues. Please try again later.',
        );
      } else {
        throw Exception('Something went wrong. Please try again later.');
      }
    } on SocketException {
      // 👈 Handle connection refused (server off)
      print('Login error: SocketException - Server unreachable');
      throw Exception(
        'Server is offline or unreachable. Please check if the server is running and try again.',
      );
    } on http.ClientException catch (e) {
      print('Network error in login: $e');
      throw Exception(
        'Server is offline or unreachable. Please check if the backend is running and try again.',
      );
    } catch (e) {
      print('Login error: $e');
      throw Exception(
        'Unable to connect to server. Please check your internet connection.',
      );
    }
  }

  // Suggestions fetch karein
  Future<List<dynamic>> getSuggestions() async {
    try {
      final token = await _getToken();
      // final response = await http.get(Uri.parse('$baseUrl/suggestions'));
      final response = await http.get(
        Uri.parse('$baseUrl/suggestions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        'Get suggestions response: ${response.statusCode} ${response.body}',
      ); // Debug log

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
      print('Get suggestions error: $e'); // Debug log
      throw Exception('Network Error: $e');
    }
  }

  // POST new suggestion
  Future<Map<String, dynamic>> addSuggestion(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/suggestions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print(
        'Add suggestion response: ${response.statusCode} ${response.body}',
      ); // Debug log

      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        throw Exception('Failed to add suggestion: ${response.statusCode}');
      }
    } catch (e) {
      print('Add suggestion error: $e'); // Debug log
      throw Exception('Network error: $e');
    }
  }

  // PUT update suggestion status
  // Future<void> updateSuggestionStatus(
  //   String id,
  //   Map<String, dynamic> data,
  // ) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('$baseUrl/suggestions/$id/status'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(data),
  //     );
  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to update status');
  //     }
  //   } catch (e) {
  //     throw Exception('Network error: $e');
  //   }
  // }

  // // POST like/dislike
  // Future<void> voteOnSuggestion(
  //   String suggestionId,
  //   String type,
  //   String employeeId,
  // ) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/suggestions/$suggestionId/vote'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'type': type, 'employee_id': employeeId}),
  //     );
  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to vote');
  //     }
  //   } catch (e) {
  //     throw Exception('Network error: $e');
  //   }
  // }

  // Future<String?> getUserVote(String suggestionId, String employeeId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //         '$baseUrl/suggestions/$suggestionId/vote?employee_id=$employeeId',
  //       ),
  //     );
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return data['data'];
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<Map<String, dynamic>> updateSuggestionStatus(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No JWT token available');
      final response = await http.put(
        Uri.parse(
          '$baseUrl/suggestions/$id/status',
        ), // Aligned with previous backend
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print(
        'Update suggestion status response: ${response.statusCode} ${response.body}',
      ); // Debug log

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      print('Update suggestion status error: $e'); // Debug log

      throw Exception('Network error: $e');
    }
  }

  Future<void> voteOnSuggestion(
    String suggestionId,
    String type,
    String employeeId,
  ) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/suggestions/$suggestionId/vote'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'type': type, 'employee_id': employeeId}),
      );
      print(
        'Vote response: ${response.statusCode} ${response.body}',
      ); // Debug log
      if (response.statusCode != 200) {
        throw Exception('Failed to vote: ${response.statusCode}');
      }
    } catch (e) {
      print('Vote error: $e'); // Debug log
      throw Exception('Network error: $e');
    }
  }

  Future<String?> getUserVote(String suggestionId, String employeeId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/suggestions/$suggestionId/vote?employee_id=$employeeId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(
        'Get user vote response: ${response.statusCode} ${response.body}',
      ); // Debug log
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      print('Get user vote error: $e'); // Debug log
      return null;
    }
  }
}
