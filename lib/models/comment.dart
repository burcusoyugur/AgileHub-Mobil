class Comment {
  final int id;
  final int taskId;
  final int userId;
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
      taskId: json['taskId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'userId': userId,
        'userName': userName,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };
}
