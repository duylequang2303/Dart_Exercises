import 'package:hive_flutter/hive_flutter.dart';
import '../model/sinhvien.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String boxName = 'sinhviens';

  Future<void> initDB() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  Box get box => Hive.box(boxName);

  Future<int> insertSinhVien(SinhVien sv) async {
    // Dùng autoIncrement thay vì millisecondsSinceEpoch
    final id = box.isEmpty ? 1 : (box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1);
    await box.put(id, {'id': id, 'name': sv.name, 'email': sv.email});
    return id;
  }

  Future<List<SinhVien>> getSinhViens() async {
    return box.values
        .map((e) => SinhVien.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> updateSinhVien(SinhVien sv) async {
    await box.put(sv.id, {'id': sv.id, 'name': sv.name, 'email': sv.email});
  }

  Future<void> deleteSinhVien(int id) async {
    await box.delete(id);
  }
}