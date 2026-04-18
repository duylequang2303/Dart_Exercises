// =============================================================
// Database Helper: Quan ly SQLite cho ung dung
// Su dung pattern Singleton de dam bao chi co 1 instance duy nhat
// =============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/user_model.dart';

class DatabaseHelper {
  // -----------------------------------------------------------
  // Singleton pattern
  // -----------------------------------------------------------
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Doi tuong Database (lazy init)
  static Database? _database;

  // Ten va phien ban DB
  static const String _dbName = 'multimedia_app.db';
  static const int _dbVersion = 1;

  // Ten bang va cot
  static const String tableUsers = 'users';
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colEmail = 'email';
  static const String colAvatarPath = 'avatar_path';

  // -----------------------------------------------------------
  // Lay instance Database (tao moi neu chua co)
  // -----------------------------------------------------------
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // -----------------------------------------------------------
  // Khoi tao database va tao bang
  // -----------------------------------------------------------
  Future<Database> _initDatabase() async {
    // Lay duong dan thu muc luu DB tren thiet bi
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _dbName);

    return openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  // -----------------------------------------------------------
  // Tao bang users khi DB duoc tao lan dau tien
  // -----------------------------------------------------------
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colName TEXT NOT NULL,
        $colEmail TEXT NOT NULL UNIQUE,
        $colAvatarPath TEXT
      )
    ''');

    // Them 2 user mau de demo
    await db.insert(tableUsers, {
      colName: 'Nguyen Van An',
      colEmail: 'an.nguyen@example.com',
      colAvatarPath: null,
    });
    await db.insert(tableUsers, {
      colName: 'Tran Thi Bich',
      colEmail: 'bich.tran@example.com',
      colAvatarPath: null,
    });
  }

  // -----------------------------------------------------------
  // CRUD: Them user moi
  // -----------------------------------------------------------
  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert(
      tableUsers,
      user.toMap()..remove('id'), // Khong truyen id (SQLite tu sinh)
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // -----------------------------------------------------------
  // CRUD: Doc tat ca user
  // -----------------------------------------------------------
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(tableUsers, orderBy: '$colId ASC');
    return maps.map((m) => User.fromMap(m)).toList();
  }

  // -----------------------------------------------------------
  // CRUD: Doc mot user theo id
  // -----------------------------------------------------------
  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableUsers,
      where: '$colId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // -----------------------------------------------------------
  // CRUD: Cap nhat thong tin user
  // -----------------------------------------------------------
  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update(
      tableUsers,
      user.toMap(),
      where: '$colId = ?',
      whereArgs: [user.id],
    );
  }

  // -----------------------------------------------------------
  // CRUD: Xoa user theo id
  // -----------------------------------------------------------
  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete(
      tableUsers,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // -----------------------------------------------------------
  // Dong ket noi DB
  // -----------------------------------------------------------
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
