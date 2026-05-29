// =============================================================
// Model: User - Dai dien cho mot nguoi dung trong SQLite
// =============================================================

class User {
  final int? id;          // Primary key (tu dong tang)
  final String name;      // Ten nguoi dung
  final String email;     // Email nguoi dung
  final String? avatarPath; // Duong dan toi anh avatar (nullable)

  const User({
    this.id,
    required this.name,
    required this.email,
    this.avatarPath,
  });

  // Chuyen User thanh Map de luu vao SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_path': avatarPath,
    };
  }

  // Tao User tu Map doc tu SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      avatarPath: map['avatar_path'] as String?,
    );
  }

  // Tao ban sao User voi mot so truong duoc cap nhat
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarPath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
