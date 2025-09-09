import 'package:nqconnect/models/status_history_model.dart';

class Suggestion {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String category;
  final String employeeId;
  final String employeeName; // 👈 Added employee name
  final String department;
  final DateTime createdAt;
  String status; // Pending / Approved / Rejected / Archived

  // For voting functionality
  int likes;
  int dislikes;

  // New fields for management
  DateTime? reviewedAt;
  String? reviewedBy;
  String? reviewComments;
  bool isArchived;
  List<StatusHistory> statusHistory;

  Suggestion({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.category,
    required this.employeeId,
    required this.employeeName, // 👈 Added
    required this.department,
    required this.createdAt,
    this.status = "Pending",
    this.likes = 0,
    this.dislikes = 0,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewComments,
    this.isArchived = false,
    List<StatusHistory>? statusHistory,
  }) : statusHistory = statusHistory ?? [];

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
      "category": category,
      "employeeId": employeeId,
      "employeeName": employeeName, // 👈 Added
      "department": department,
      "createdAt": createdAt.toIso8601String(),
      "status": status,
      "likes": likes,
      "dislikes": dislikes,
      "reviewedAt": reviewedAt?.toIso8601String(),
      "reviewedBy": reviewedBy,
      "reviewComments": reviewComments,
      "isArchived": isArchived,
      "statusHistory": statusHistory.map((h) => h.toMap()).toList(),
    };
  }

  // Create from Map
  factory Suggestion.fromMap(Map<String, dynamic> map) {
    return Suggestion(
      id: map["id"],
      title: map["title"],
      description: map["description"],
      image: map["image"],
      category: map["category"],
      employeeId: map["employeeId"],
      employeeName: map["employeeName"] ?? "Unknown", // 👈 Added
      department: map["department"],
      createdAt: DateTime.parse(map["createdAt"]),
      status: map["status"] ?? "Pending",
      likes: map["likes"] ?? 0,
      dislikes: map["dislikes"] ?? 0,
      reviewedAt: map["reviewedAt"] != null
          ? DateTime.parse(map["reviewedAt"])
          : null,
      reviewedBy: map["reviewedBy"],
      reviewComments: map["reviewComments"],
      isArchived: map["isArchived"] ?? false,
      statusHistory: map["statusHistory"] != null
          ? (map["statusHistory"] as List)
                .map((h) => StatusHistory.fromMap(h))
                .toList()
          : [],
    );
  }
}
