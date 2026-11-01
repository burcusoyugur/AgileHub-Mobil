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

  /// API'deki GorevDurumu enum değeri.
  String get apiValue {
    switch (this) {
      case TaskStatus.todo:
        return 'Yapilacak';
      case TaskStatus.inProgress:
        return 'Yapiliyor';
      case TaskStatus.testing:
        return 'Test';
      case TaskStatus.done:
        return 'Bitti';
    }
  }

  static TaskStatus fromString(String value) {
    switch (value) {
      case 'Yapiliyor':
        return TaskStatus.inProgress;
      case 'Test':
        return TaskStatus.testing;
      case 'Bitti':
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

  /// API'deki GorevOnceligi enum değeri.
  String get apiValue {
    switch (this) {
      case TaskPriority.low:
        return 'Dusuk';
      case TaskPriority.medium:
        return 'Orta';
      case TaskPriority.high:
        return 'Yuksek';
      case TaskPriority.critical:
        return 'Kritik';
    }
  }

  static TaskPriority fromString(String value) {
    switch (value) {
      case 'Dusuk':
        return TaskPriority.low;
      case 'Yuksek':
        return TaskPriority.high;
      case 'Kritik':
        return TaskPriority.critical;
      default:
        return TaskPriority.medium;
    }
  }
}

class Task {
  final int id;
  final int projectId;
  final int? sprintId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final int? storyPoints;
  final String? assignedUserId;
  final String? assignedUserName;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.projectId,
    this.sprintId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.storyPoints,
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
    String? assignedUserId,
    String? assignedUserName,
  }) {
    return Task(
      id: id,
      projectId: projectId,
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
      projectId: json['projeId'] as int,
      sprintId: json['sprintId'] as int?,
      title: json['baslik'] as String,
      description: json['aciklama'] as String?,
      status: TaskStatusExtension.fromString(json['durum'] as String),
      priority: TaskPriorityExtension.fromString(json['oncelik'] as String),
      storyPoints: json['storyPoint'] as int?,
      assignedUserId: json['atananKullaniciId'] as String?,
      assignedUserName: json['atananKullaniciAdi'] as String?,
      createdAt: DateTime.parse(json['olusturmaTarihi'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projeId': projectId,
        'sprintId': sprintId,
        'baslik': title,
        'aciklama': description,
        'durum': status.apiValue,
        'oncelik': priority.apiValue,
        'storyPoint': storyPoints,
        'atananKullaniciId': assignedUserId,
        'atananKullaniciAdi': assignedUserName,
        'olusturmaTarihi': createdAt.toIso8601String(),
      };
}
