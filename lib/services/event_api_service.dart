// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/models/event_models/event.dart';
import 'package:nqconnect/models/event_models/event_stats.dart';
import 'package:nqconnect/utils/api_constants.dart';

/// Handles all network calls for Events
/// Make sure to pass a valid JWT token when calling secured endpoints.
class EventApiService {
  /// Change to your actual backend base URL if needed.
  // static const String _baseUrl = "$ApiConstants.bas";
  final String _baseUrl = ApiConstants.eventbaseUrl;
  // 🔑 Get the logged-in user's token from UserController
  String get _token {
    final userController = Get.find<UserController>();
    return userController.token.value;
  }

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $_token",
  };

  /// GET /api/events
  /// Fetch all active events for employee/admin
  Future<List<Event>> fetchEvents() async {
    print("➡️  Fetching events from $_baseUrl");
    final res = await http.get(Uri.parse(_baseUrl), headers: _headers);
    print("⬅️  Response [${res.statusCode}]: ${res.body}");

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      print("✅ Parsed ${data.length} events");
      return data.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load events: ${res.body}");
    }
  }

  /// POST /api/events
  /// Admin/HR create new event
  Future<Event> createEvent(Event event) async {
    print("➡️  Creating event with data: ${event.toJson()}");
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(event.toJson()),
    );
    print("⬅️  Response [${res.statusCode}]: ${res.body}");

    if (res.statusCode == 201) {
      // backend returns { message: "...", eventId: id }
      final json = jsonDecode(res.body);
      print("✅ Event created with ID: ${json['eventId']}");

      return Event(
        eventId: json["eventId"] ?? 0,
        title: event.title,
        description: event.description,
        startDate: event.startDate,
        endDate: event.endDate,
        rsvpDeadline: event.rsvpDeadline,
        location: event.location,
        category: event.category,
        maxCapacity: event.maxCapacity,
        coverImageUrl: event.coverImageUrl,
        attachmentsJson: event.attachmentsJson,
        organizerUserId: event.organizerUserId,
        isActive: true,
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception("Failed to create event: ${res.body}");
    }
  }

  /// POST /api/events/{id}/rsvp
  /// Employee or Admin respond to event (Going / NotGoing / Maybe)
  /// responseType: 1 = Going, 2 = Not Going, 3 = Maybe
  // Future<void> rsvpEvent({
  //   required int eventId,
  //   required int responseType,
  //   String? comment,
  // }) async {
  //   final res = await http.post(
  //     Uri.parse("$_baseUrl/$eventId/rsvp"),
  //     headers: _headers,
  //     body: jsonEncode({"responseType": responseType, "comment": comment}),
  //   );

  //   if (res.statusCode != 200) {
  //     throw Exception("Failed to RSVP: ${res.body}");
  //   }
  // }

  Future<void> rsvpEvent({
    required int eventId,
    required int responseType,
    String? comment,
  }) async {
    final url = "$_baseUrl/$eventId/rsvp";
    final body = jsonEncode({"responseType": responseType, "comment": comment});
    print("➡️  RSVP to $url with body: $body");

    final res = await http.post(Uri.parse(url), headers: _headers, body: body);
    print("⬅️  Response [${res.statusCode}]: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("❌ Failed to RSVP: ${res.body}");
    }
    print("✅ RSVP successful for event $eventId");
  }

  /// GET /api/events/{id}/stats
  /// Admin/HR fetch statistics of a single event
  // Future<EventStats> fetchEventStats(int eventId) async {
  //   final res = await http.get(
  //     Uri.parse("$_baseUrl/$eventId/stats"),
  //     headers: _headers,
  //   );

  //   if (res.statusCode == 200) {
  //     return EventStats.fromJson(jsonDecode(res.body));
  //   } else {
  //     throw Exception("Failed to fetch stats: ${res.body}");
  //   }
  // }

  Future<EventStats> fetchEventStats(int eventId) async {
    final url = "$_baseUrl/$eventId/stats";
    print("➡️  Fetching stats from $url");
    final res = await http.get(Uri.parse(url), headers: _headers);
    print("⬅️  Response [${res.statusCode}]: ${res.body}");

    if (res.statusCode == 200) {
      final stats = EventStats.fromJson(jsonDecode(res.body));
      print(
        "✅ Stats parsed: Going ${stats.goingCount}, NotGoing ${stats.notGoingCount}, Maybe ${stats.maybeCount}",
      );
      return stats;
    } else {
      throw Exception("❌ Failed to fetch stats: ${res.body}");
    }
  }

  // Future<int> fetchUserRsvpStatus(String eventId) async {
  //   // 💡 Base URL ko API URL ke saath jodein
  //   final url =
  //       "$_baseUrl/$eventId/my-rsvp"; // Example: your_base_url/123/my-rsvp
  //   print("➡️ Fetching user RSVP status from $url");

  //   final res = await http.get(Uri.parse(url), headers: _headers);
  //   print("⬅️ Response [${res.statusCode}]: ${res.body}");

  //   if (res.statusCode == 200) {
  //     final data = jsonDecode(res.body);
  //     // ✅ Assume API returns: {"responseType": 1}
  //     return data['responseType'] as int;
  //   }
  //   // Agar API response code 404/204 de ya koi khaas code de jab response na ho
  //   else if (res.statusCode == 404 || res.statusCode == 204) {
  //     print("✅ No existing RSVP found for event $eventId.");
  //     return 0; // 0 means No Response
  //   } else {
  //     throw Exception('❌ Failed to load user RSVP: ${res.body}');
  //   }
  // }

  Future<int> fetchUserRsvpStatus(String eventId) async {
    // 💡 FIX 1: Correct URL structure. _baseUrl already contains the base path.
    // Example URL: http://10.10.5.188:5000/api/events/2/my-rsvp
    final url = "$_baseUrl/$eventId/my-response";
    print("➡️  Fetching user RSVP status from $url");

    // 💡 FIX 2: Headers (including Authorization token) pass karein
    final res = await http.get(
      Uri.parse(url),
      headers: _headers, // <--- 🚀 Yeh zaroori hai
    );
    print("⬅️  Response [${res.statusCode}]: ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final responseValue = data['responseType'];
      if (responseValue is String) {
        // Agar value String hai (e.g., "1"), toh usko parse karein
        return int.tryParse(responseValue) ?? 0;
      } else if (responseValue is int) {
        // Agar value already int hai, toh use return karein
        return responseValue;
      }
      return 0;
    }
    // Agar server kahay 'Not Found' (404) ya 'No Content' (204), toh 0 return karein.
    else if (res.statusCode == 404 || res.statusCode == 204) {
      print("✅ No existing RSVP found (Status: ${res.statusCode}).");
      return 0; // 0 means No Response
    } else {
      // Baaki errors ke liye exception throw karein.
      throw Exception(
        '❌ Failed to load user RSVP (Code ${res.statusCode}): ${res.body}',
      );
    }
  }

  Future<Map<String, dynamic>> fetchAnalytics() async {
    final url = Uri.parse('$_baseUrl/analytics');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load analytics: ${response.body}');
    }
  }
}
