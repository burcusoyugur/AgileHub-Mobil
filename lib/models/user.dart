class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['ad'] as String,
      lastName: json['soyad'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'ad': firstName,
        'soyad': lastName,
      };
}
