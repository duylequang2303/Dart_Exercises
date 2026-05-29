class SanPham {
  final int? id;
  final String ten;
  final double gia;
  final double giamGia;

  SanPham({this.id, required this.ten, required this.gia, this.giamGia = 0});

  double tinhThueNhapKhau() => gia * 0.1;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'ten': ten,
    'gia': gia,
    'giamGia': giamGia,
  };

  factory SanPham.fromMap(Map<String, dynamic> map) => SanPham(
    id: (map['id'] as num?)?.toInt(),
    ten: map['ten']?.toString() ?? '',
    gia: (map['gia'] as num?)?.toDouble() ?? 0,
    giamGia: (map['giamGia'] as num?)?.toDouble() ?? 0,
  );
}