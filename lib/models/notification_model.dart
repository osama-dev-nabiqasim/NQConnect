// lib/models/notification_model.dart

class AppNotification {
  final int id;
  final String userId;
  final String title;
  final String message;
  final String type;
  bool isRead;
  final String? relatedId;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    // required this.isRead,
    this.isRead = false,
    this.relatedId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // handle different possible representations of is_read
    final dynamic isReadRaw = json['is_read'] ?? json['isRead'] ?? false;
    bool parsedIsRead = false;
    if (isReadRaw is int)
      parsedIsRead = isReadRaw == 1;
    else if (isReadRaw is bool)
      parsedIsRead = isReadRaw;
    else if (isReadRaw is String) {
      parsedIsRead = isReadRaw == '1' || isReadRaw.toLowerCase() == 'true';
    }

    // parse created_at safely
    final createdRaw =
        json['created_at'] ?? json['createdAt'] ?? json['createdAtUtc'];
    DateTime createdAt;
    if (createdRaw == null) {
      createdAt = DateTime.now();
    } else {
      createdAt = DateTime.tryParse(createdRaw.toString()) ?? DateTime.now();
    }

    return AppNotification(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      isRead: json['is_read'] ?? false,

      // isRead: parsedIsRead,
      relatedId: json['related_id']?.toString(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead ? 1 : 0,
      'related_id': relatedId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    int? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? relatedId,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, isRead: $isRead, createdAt: $createdAt)';
  }
}
