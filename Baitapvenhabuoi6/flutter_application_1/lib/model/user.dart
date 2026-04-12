class User {
  final int? id;
  final String email;
  final String password;

  User({this.id, required this.email, required this.password});

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: (map['id'] as num?)?.toInt(),
    email: map['email']?.toString() ?? '',
    password: map['password']?.toString() ?? '',
  );
}