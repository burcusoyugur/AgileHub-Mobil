enum TaskStatus { todo, inProgress, testing, done }

enum TaskPriority { low, medium, high, critical }

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Yapılacak';
      case TaskStatus.inProgress:
        return 'Yapılıyor';
      case TaskStatus.testing:
        return 'Test';
      case TaskStatus.done:
        return 'Bitti';
    }
  }

  static TaskStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'testing':
        return TaskStatus.testing;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Düşük';
      case TaskPriority.medium:
        return 'Orta';
      case TaskPriority.high:
        return 'Yüksek';
      case TaskPriority.critical:
        return 'Kritik';
    }
  }

  static TaskPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'critical':
        return TaskPriority.critical;
      default:
        return TaskPriority.low;
    }
  }
}

class Task {
  final int id;
  final int sprintId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final int storyPoints;
  final int? assignedUserId;
  final String? assignedUserName;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.sprintId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.storyPoints,
    this.assignedUserId,
    this.assignedUserName,
    required this.createdAt,
  });

  Task copyWith({
    TaskStatus? status,
    String? title,
    String? description,
    TaskPriority? priority,
    int? storyPoints,
    int? assignedUserId,
    String? assignedUserName,
  }) {
    return Task(
      id: id,
      sprintId: sprintId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      storyPoints: storyPoints ?? this.storyPoints,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedUserName: assignedUserName ?? this.assignedUserName,
      createdAt: createdAt,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      sprintId: json['sprintId'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatusExtension.fromString(json['status'] as String),
      priority: TaskPriorityExtension.fromString(json['priority'] as String),
      storyPoints: json['storyPoints'] as int? ?? 1,
      assignedUserId: json['assignedUserId'] as int?,
      assignedUserName: json['assignedUserName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sprintId': sprintId,
        'title': title,
        'description': description,
        'status': status.name,
        'priority': priority.name,
        'storyPoints': storyPoints,
        'assignedUserId': assignedUserId,
        'assignedUserName': assignedUserName,
        'createdAt': createdAt.toIso8601String(),
      };
}
