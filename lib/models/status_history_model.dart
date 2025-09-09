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
      'changedBy': changedBy,
      'changedAt': changedAt.toIso8601String(),
      'comments': comments,
    };
  }

  factory StatusHistory.fromMap(Map<String, dynamic> map) {
    return StatusHistory(
      status: map['status'],
      changedBy: map['changedBy'],
      changedAt: DateTime.parse(map['changedAt']),
      comments: map['comments'],
    );
  }
}
