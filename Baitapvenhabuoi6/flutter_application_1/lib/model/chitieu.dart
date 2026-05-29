class ChiTieu {
  final int? id;
  final String noiDung;
  final double soTien;
  final String ghiChu;

  ChiTieu({this.id, required this.noiDung, required this.soTien, this.ghiChu = ''});

  factory ChiTieu.fromMap(Map<String, dynamic> map) => ChiTieu(
    id: (map['id'] as num?)?.toInt(),
    noiDung: map['noiDung']?.toString() ?? '',
    soTien: (map['soTien'] as num?)?.toDouble() ?? 0,
    ghiChu: map['ghiChu']?.toString() ?? '',
  );
}