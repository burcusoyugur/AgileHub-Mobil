class User {
  final int id;
  final String email;
  final String fullName;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'avatarUrl': avatarUrl,
      };
}
