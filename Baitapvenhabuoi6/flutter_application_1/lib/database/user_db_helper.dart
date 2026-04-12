import 'package:hive_flutter/hive_flutter.dart';
import '../model/user.dart';

class UserDbHelper {
  static final UserDbHelper _instance = UserDbHelper._internal();
  factory UserDbHelper() => _instance;
  UserDbHelper._internal();

  static const String boxName = 'users';

  Future<void> initDB() async {
    if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
  }

  Box get box => Hive.box(boxName);
  int _nextId() => box.isEmpty ? 1 : box.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1;

  Future<bool> register(String email, String password) async {
    // Kiểm tra email đã tồn tại chưa
    final exists = box.values.any((e) => Map<String, dynamic>.from(e)['email'] == email);
    if (exists) return false;
    final id = _nextId();
    await box.put(id, {'id': id, 'email': email, 'password': password});
    return true;
  }

  Future<User?> login(String email, String password) async {
    try {
      final map = box.values.firstWhere(
        (e) => Map<String, dynamic>.from(e)['email'] == email &&
               Map<String, dynamic>.from(e)['password'] == password,
      );
      return User.fromMap(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }
}