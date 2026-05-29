import 'package:hive_flutter/hive_flutter.dart';
import '../model/chitieu.dart';

class ChiTieuDbHelper {
  static final ChiTieuDbHelper _instance = ChiTieuDbHelper._internal();
  factory ChiTieuDbHelper() => _instance;
  ChiTieuDbHelper._internal();

  static const String boxName = 'chitieus';

  Future<void> initDB() async {
    if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
  }

  Box get box => Hive.box(boxName);
  int _nextId() => box.isEmpty ? 1 : box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;

  Future<void> insert(ChiTieu ct) async {
    final id = _nextId();
    await box.put(id, {'id': id, 'noiDung': ct.noiDung, 'soTien': ct.soTien, 'ghiChu': ct.ghiChu});
  }

  Future<List<ChiTieu>> getAll() async =>
      box.values.map((e) => ChiTieu.fromMap(Map<String, dynamic>.from(e))).toList();

  Future<void> delete(int id) async => await box.delete(id);
}