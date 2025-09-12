// Status History Model (New file: lib/models/status_history_model.dart)
class StatusHistory {
  final String status;
  final String changedBy;
  final DateTime changedAt;
  final String? comments;

  StatusHistory({
    required this.status,
    required this.changedBy,
    required this.changedAt,
    this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'changed_by': changedBy,
      'changed_at': changedAt.toIso8601String(),
      'comments': comments,
    };
  }

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      status: json['status'],
      changedBy: json['changed_by'],
      changedAt: DateTime.parse(json['changed_at']),
      comments: json['comments'],
    );
  }
}
