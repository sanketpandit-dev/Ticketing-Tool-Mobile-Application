class Priority {
  final int priorityId;
  final String priorityName;

  Priority({
    required this.priorityId,
    required this.priorityName,
  });

  factory Priority.fromJson(Map<String, dynamic> json) {
    return Priority(
      priorityId: json['priority_id'] as int,
      priorityName: json['priority_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priority_id': priorityId,
      'priority_name': priorityName,
    };
  }
} 