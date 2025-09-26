/// Represents the RSVP statistics returned by
/// GET /api/events/:id/stats endpoint.
class EventStats {
  final int goingCount;
  final int notGoingCount;
  final int maybeCount;
  final int totalResponded;

  EventStats({
    required this.goingCount,
    required this.notGoingCount,
    required this.maybeCount,
    required this.totalResponded,
  });

  factory EventStats.fromJson(Map<String, dynamic> json) {
    return EventStats(
      goingCount: json['GoingCount'] ?? 0,
      notGoingCount: json['NotGoingCount'] ?? 0,
      maybeCount: json['MaybeCount'] ?? 0,
      totalResponded: json['TotalResponded'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GoingCount': goingCount,
      'NotGoingCount': notGoingCount,
      'MaybeCount': maybeCount,
      'TotalResponded': totalResponded,
    };
  }
}
