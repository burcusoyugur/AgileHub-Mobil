class Comment {
  final int id;
  final int taskId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      taskId: json['gorevId'] as int,
      userId: json['yazanKullaniciId'] as String,
      userName: json['yazanKullaniciAdi'] as String,
      content: json['metin'] as String,
      createdAt: DateTime.parse(json['olusturmaTarihi'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'gorevId': taskId,
        'yazanKullaniciId': userId,
        'yazanKullaniciAdi': userName,
        'metin': content,
        'olusturmaTarihi': createdAt.toIso8601String(),
      };
}
