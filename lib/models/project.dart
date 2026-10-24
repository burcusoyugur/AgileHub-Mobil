class Project {
  final int id;
  final String name;
  final String? description;
  final String status;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}
