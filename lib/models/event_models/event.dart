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
  // factory Event.fromJson(Map<String, dynamic> json) {
  //   return Event(
  //     eventId: json['EventID'] ?? json['eventId'] ?? 0,
  //     title: json['Title'] ?? '',
  //     description: json['Description'] ?? '',
  //     startDate: DateTime.parse(json['StartDate']),
  //     endDate: DateTime.parse(json['EndDate']),
  //     rsvpDeadline: json['RSVPDeadline'] != null
  //         ? DateTime.tryParse(json['RSVPDeadline'])
  //         : null,
  //     location: json['Location'] ?? '',
  //     category: json['Category'] ?? '',
  //     maxCapacity: json['MaxCapacity'],
  //     coverImageUrl: json['CoverImageURL'],
  //     attachmentsJson: json['AttachmentsJSON'],
  //     organizerUserId: json['OrganizerUserID'] ?? 0,
  //     isActive: (json['IsActive'] ?? 1) == 1,
  //     createdAt: DateTime.parse(json['CreatedAt']),
  //     updatedAt: json['UpdatedAt'] != null
  //         ? DateTime.tryParse(json['UpdatedAt'])
  //         : null,
  //   );
  // }

  // factory Event.fromJson(Map<String, dynamic> json) {
  //   return Event(
  //     eventId: json['eventId'] ?? json['eventId'] ?? 0,
  //     title: json['title'] ?? '',
  //     description: json['description'] ?? '',
  //     startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
  //     endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
  //     rsvpDeadline: DateTime.tryParse(json['rsvpDeadline'] ?? ''),
  //     location: json['location'] ?? '',
  //     category: json['category'] ?? '',
  //     maxCapacity: json['maxCapacity'],
  //     coverImageUrl: json['coverImageURL'],
  //     attachmentsJson: json['attachmentsJSON'],
  //     organizerUserId: json['createdBy'] ?? 0,
  //     isActive: (json['IsActive'] ?? 1) == 1,
  //     createdAt: DateTime.tryParse(json['CreatedAt'] ?? '') ?? DateTime.now(),
  //     updatedAt: DateTime.tryParse(json['UpdatedAt'] ?? ''),
  //   );
  // }
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['EventID'] ?? 0,
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      startDate: DateTime.parse(json['StartDate']),
      endDate: DateTime.parse(json['EndDate']),
      rsvpDeadline: DateTime.parse(json['RSVPDeadline']),
      location: json['Location'] ?? '',
      category: json['Category'] ?? '',
      maxCapacity: json['MaxCapacity'] ?? 0,
      coverImageUrl: json['CoverImageURL'] ?? '',
      attachmentsJson: json['AttachmentsJSON'] ?? '',
      organizerUserId: json['OrganizerUserID'] ?? 0,
      isActive: json['IsActive'] ?? true,
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'])
          : null,
    );
  }

  /// Convert Event object back to JSON (for creating/updating events).
  Map<String, dynamic> toJson() => {
    "eventId": eventId,
    "title": title,
    "description": description,
    "startDate": startDate.toUtc().toIso8601String(),
    "endDate": endDate.toUtc().toIso8601String(),
    "rsvpDeadline": rsvpDeadline!.toUtc().toIso8601String(),
    "location": location,
    "category": category,
    "maxCapacity": maxCapacity,
    "coverImageURL": coverImageUrl,
    "attachmentsJSON": attachmentsJson,
    "createdBy": organizerUserId,
    "IsActive": isActive ? 1 : 0,
    "CreatedAt": createdAt.toUtc().toIso8601String(),
    "UpdatedAt": updatedAt?.toUtc().toIso8601String(),
  };

  /// Handy method if backend sends a JSON array
  static List<Event> listFromJson(String source) {
    final data = jsonDecode(source) as List;
    return data.map((e) => Event.fromJson(e)).toList();
  }
}
