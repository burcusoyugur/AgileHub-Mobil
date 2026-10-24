class Sprint {
  final int id;
  final int projectId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int totalStoryPoints;
  final int completedStoryPoints;

  const Sprint({
    required this.id,
    required this.projectId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.totalStoryPoints,
    required this.completedStoryPoints,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) {
    return Sprint(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      totalStoryPoints: json['totalStoryPoints'] as int? ?? 0,
      completedStoryPoints: json['completedStoryPoints'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isActive': isActive,
        'totalStoryPoints': totalStoryPoints,
        'completedStoryPoints': completedStoryPoints,
      };
}
