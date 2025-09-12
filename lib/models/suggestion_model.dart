import 'package:nqconnect/models/status_history_model.dart';

class Suggestion {
  int id; // 👈 Remove 'final'
  String title;
  String description;
  String category;
  String employeeId;
  String employeeName;
  String department;
  String status;
  int likes;
  int dislikes;
  DateTime createdAt;
  DateTime? reviewedAt;
  String? reviewedBy;
  String? reviewComments;
  bool isArchived;
  String? image;
  List<StatusHistory> statusHistory;
  String? userVote;

  Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.status,
    required this.likes,
    required this.dislikes,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewComments,
    this.isArchived = false,
    this.image,
    this.userVote,
    this.statusHistory = const [],
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      employeeId: json['employee_id'],
      employeeName: json['employee_name'],
      department: json['department'],
      status: json['status'],
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      reviewedBy: json['reviewed_by'],
      reviewComments: json['review_comments'],
      isArchived: json['is_archived'] ?? false,
      image: json['image'],
      userVote: json['userVote'],
      statusHistory: (json['statusHistory'] as List? ?? [])
          .map((e) => StatusHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'userVote': userVote,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'department': department,
      'status': status,
      'likes': likes,
      'dislikes': dislikes,
      'created_at': createdAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
      'review_comments': reviewComments,
      'is_archived': isArchived,
      'image': image,
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
    };
  }

  // 👇 Optional: CopyWith method for immutable updates (if you want to keep fields final later)
  Suggestion copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? employeeId,
    String? employeeName,
    String? department,
    String? status,
    int? likes,
    int? dislikes,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewComments,
    bool? isArchived,
    String? image,
    List<StatusHistory>? statusHistory,
  }) {
    return Suggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      status: status ?? this.status,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewComments: reviewComments ?? this.reviewComments,
      isArchived: isArchived ?? this.isArchived,
      image: image ?? this.image,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}
