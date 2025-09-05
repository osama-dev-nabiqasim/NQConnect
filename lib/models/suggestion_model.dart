// lib/models/suggestion_model.dart
class Suggestion {
  final String id; // Unique ID for suggestion
  final String title; // Suggestion title
  final String description; // Suggestion details
  final String? image; // Optional image path or URL
  final String category; // Category (HR, Finance, Operations, etc.)
  final String employeeId; // 👈 kis employee ne diya
  final String department; // 👈 uska department
  final DateTime createdAt; // Date of suggestion
  String status; // Pending / Approved / Rejected

  Suggestion({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.category,
    required this.employeeId,
    required this.department,
    required this.createdAt,
    this.status = "Pending",
  });

  // Convert to Map (useful for DB or API)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "image": image,
      "category": category,
      "employeeId": employeeId,
      "department": department,
      "createdAt": createdAt.toIso8601String(),
      "status": status,
    };
  }

  // Create Suggestion object from Map
  factory Suggestion.fromMap(Map<String, dynamic> map) {
    return Suggestion(
      id: map["id"],
      title: map["title"],
      description: map["description"],
      image: map["image"],
      category: map["category"],
      employeeId: map["employeeId"],
      department: map["department"],
      createdAt: DateTime.parse(map["createdAt"]),
      status: map["status"] ?? "Pending",
    );
  }
}
