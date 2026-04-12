import 'package:hive_flutter/hive_flutter.dart';
import '../model/sanpham.dart';

class SanPhamDbHelper {
  static final SanPhamDbHelper _instance = SanPhamDbHelper._internal();
  factory SanPhamDbHelper() => _instance;
  SanPhamDbHelper._internal();

  static const String boxName = 'sanphams';

  Future<void> initDB() async {
    if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
  }

  Box get box => Hive.box(boxName);

  int _nextId() => box.isEmpty ? 1 : box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;

  Future<void> insert(SanPham sp) async {
    final id = _nextId();
    await box.put(id, {'id': id, 'ten': sp.ten, 'gia': sp.gia, 'giamGia': sp.giamGia});
  }

  Future<List<SanPham>> getAll() async =>
      box.values.map((e) => SanPham.fromMap(Map<String, dynamic>.from(e))).toList();

  Future<void> update(SanPham sp) async =>
      await box.put(sp.id, {'id': sp.id, 'ten': sp.ten, 'gia': sp.gia, 'giamGia': sp.giamGia});

  Future<void> delete(int id) async => await box.delete(id);
}