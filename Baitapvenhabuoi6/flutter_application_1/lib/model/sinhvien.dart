class SinhVien {
  final int? id;
  final String name;
  final String email;

  SinhVien({this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory SinhVien.fromMap(Map<String, dynamic> map) {
    return SinhVien(
      // Trên web Hive trả về 'num' không phải 'int'
      // nên phải ép kiểu như này
      id: (map['id'] as num?)?.toInt(),
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
    );
  }
}