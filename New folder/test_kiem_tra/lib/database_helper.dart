import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE User (
        id TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        fullName TEXT,
        gender TEXT,
        illustration TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE DanhMuc (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryName TEXT NOT NULL,
        parentCategoryId INTEGER DEFAULT 0,
        categoryType TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE GiaoDich (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        description TEXT,
        category TEXT,
        illustration TEXT,
        user_id TEXT
      )
    ''');

    // User mau
    await db.insert('User', {
      'id': 'admin',
      'password': '123',
      'fullName': 'Nguyen Van A',
      'gender': 'Nam',
      'illustration': ''
    });

    // Danh muc Chi
    for (final name in ['Thuc pham', 'Di chuyen', 'Giai tri', 'Hoa don']) {
      await db.insert('DanhMuc', {
        'categoryName': name,
        'parentCategoryId': 0,
        'categoryType': 'chi'
      });
    }

    // Danh muc Thu
    for (final name in ['Luong', 'Thuong', 'Dau tu', 'Khac']) {
      await db.insert('DanhMuc', {
        'categoryName': name,
        'parentCategoryId': 0,
        'categoryType': 'thu'
      });
    }
  }

  // Lay tat ca du lieu 1 bang
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  // Lay co dieu kien
  Future<List<Map<String, dynamic>>> queryWhere(
      String table, String where, List<dynamic> args) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: args);
  }

  // Them moi
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  // Tinh tong thu hoac chi
  Future<double> sumGiaoDich(String userId, String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(totalAmount) as total FROM GiaoDich WHERE user_id = ? AND type = ?',
      [userId, type],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}