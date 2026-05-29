class UserEntity {
  final String uid;
  final String email;
  final String tenHienThi;
  final String? anhDaiDien;
  final DateTime ngayTao;
  final int caloMucTieu;
  final int nuocMucTieu;
  final double? canNang;
  final double? chieuCao;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.tenHienThi,
    this.anhDaiDien,
    required this.ngayTao,
    this.caloMucTieu = 2000,
    this.nuocMucTieu = 8,
    this.canNang,
    this.chieuCao,
  });

  double? get bmiHienTai {
    if (canNang == null || chieuCao == null || chieuCao == 0) return null;
    final chieuCaoMet = chieuCao! / 100;
    return canNang! / (chieuCaoMet * chieuCaoMet);
  }

  UserEntity copyWith({
    String? uid,
    String? email,
    String? tenHienThi,
    String? anhDaiDien,
    DateTime? ngayTao,
    int? caloMucTieu,
    int? nuocMucTieu,
    double? canNang,
    double? chieuCao,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      tenHienThi: tenHienThi ?? this.tenHienThi,
      anhDaiDien: anhDaiDien ?? this.anhDaiDien,
      ngayTao: ngayTao ?? this.ngayTao,
      caloMucTieu: caloMucTieu ?? this.caloMucTieu,
      nuocMucTieu: nuocMucTieu ?? this.nuocMucTieu,
      canNang: canNang ?? this.canNang,
      chieuCao: chieuCao ?? this.chieuCao,
    );
  }
}
