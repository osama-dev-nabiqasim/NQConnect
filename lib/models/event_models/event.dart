import 'dart:convert';

/// Represents a single Event coming from the backend `/api/events` endpoints.
class Event {
  final int eventId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? rsvpDeadline;
  final String location;
  final String category;
  final int? maxCapacity;
  final String? coverImageUrl;
  final String? attachmentsJson;
  final int organizerUserId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.rsvpDeadline,
    required this.location,
    required this.category,
    this.maxCapacity,
    this.coverImageUrl,
    this.attachmentsJson,
    required this.organizerUserId,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create Event object from backend JSON.
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['EventID'] ?? json['eventId'] ?? 0,
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      startDate: DateTime.parse(json['StartDate']),
      endDate: DateTime.parse(json['EndDate']),
      rsvpDeadline: json['RSVPDeadline'] != null
          ? DateTime.tryParse(json['RSVPDeadline'])
          : null,
      location: json['Location'] ?? '',
      category: json['Category'] ?? '',
      maxCapacity: json['MaxCapacity'],
      coverImageUrl: json['CoverImageURL'],
      attachmentsJson: json['AttachmentsJSON'],
      organizerUserId: json['OrganizerUserID'] ?? 0,
      isActive: (json['IsActive'] ?? 1) == 1,
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : null,
    );
  }

  /// Convert Event object back to JSON (for creating/updating events).
  Map<String, dynamic> toJson() {
    return {
      'EventID': eventId,
      'Title': title,
      'Description': description,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'RSVPDeadline': rsvpDeadline?.toIso8601String(),
      'Location': location,
      'Category': category,
      'MaxCapacity': maxCapacity,
      'CoverImageURL': coverImageUrl,
      'AttachmentsJSON': attachmentsJson,
      'OrganizerUserID': organizerUserId,
      'IsActive': isActive ? 1 : 0,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Handy method if backend sends a JSON array
  static List<Event> listFromJson(String source) {
    final data = jsonDecode(source) as List;
    return data.map((e) => Event.fromJson(e)).toList();
  }
}
