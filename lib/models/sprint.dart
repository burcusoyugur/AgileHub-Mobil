enum SprintStatus { planned, active, completed, cancelled }

extension SprintStatusExtension on SprintStatus {
  String get label {
    switch (this) {
      case SprintStatus.planned:
        return 'Planlanıyor';
      case SprintStatus.active:
        return 'Aktif';
      case SprintStatus.completed:
        return 'Tamamlandı';
      case SprintStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  /// API'deki SprintDurumu enum değeri.
  String get apiValue {
    switch (this) {
      case SprintStatus.planned:
        return 'Planlanıyor';
      case SprintStatus.active:
        return 'Aktif';
      case SprintStatus.completed:
        return 'Tamamlandı';
      case SprintStatus.cancelled:
        return 'İptalEdildi';
    }
  }

  static SprintStatus fromString(String value) {
    switch (value) {
      case 'Aktif':
        return SprintStatus.active;
      case 'Tamamlandı':
        return SprintStatus.completed;
      case 'İptalEdildi':
        return SprintStatus.cancelled;
      default:
        return SprintStatus.planned;
    }
  }
}

class Sprint {
  final int id;
  final int projectId;
  final String name;
  final String? goal;
  final DateTime startDate;
  final DateTime endDate;
  final SprintStatus status;
  final int totalStoryPoints;
  final int completedStoryPoints;

  const Sprint({
    required this.id,
    required this.projectId,
    required this.name,
    this.goal,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalStoryPoints,
    required this.completedStoryPoints,
  });

  bool get isActive => status == SprintStatus.active;

  factory Sprint.fromJson(Map<String, dynamic> json) {
    return Sprint(
      id: json['id'] as int,
      projectId: json['projeId'] as int,
      name: json['ad'] as String,
      goal: json['hedef'] as String?,
      startDate: DateTime.parse(json['baslangicTarihi'] as String),
      endDate: DateTime.parse(json['bitisTarihi'] as String),
      status: SprintStatusExtension.fromString(json['durum'] as String),
      totalStoryPoints: json['toplamStoryPoint'] as int? ?? 0,
      completedStoryPoints: json['tamamlananStoryPoint'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projeId': projectId,
        'ad': name,
        'hedef': goal,
        'baslangicTarihi': startDate.toIso8601String(),
        'bitisTarihi': endDate.toIso8601String(),
        'durum': status.apiValue,
        'toplamStoryPoint': totalStoryPoints,
        'tamamlananStoryPoint': completedStoryPoints,
      };
}
