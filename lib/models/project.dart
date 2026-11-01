class Project {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String createdByUserId;
  final String? createdByUserName;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.createdByUserId,
    this.createdByUserName,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['ad'] as String,
      description: json['aciklama'] as String?,
      createdAt: DateTime.parse(json['olusturmaTarihi'] as String),
      createdByUserId: json['olusturanKullaniciId'] as String,
      createdByUserName: json['olusturanKullaniciAdi'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad': name,
        'aciklama': description,
        'olusturmaTarihi': createdAt.toIso8601String(),
        'olusturanKullaniciId': createdByUserId,
        'olusturanKullaniciAdi': createdByUserName,
      };
}
