import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        avatar BLOB
      )
    ''');
  }

  Future<int> insertContact(Map<String, dynamic> contact) async {
    Database db = await database;
    return await db.insert('contacts', contact);
  }

  Future<List<Map<String, dynamic>>> getContacts({String? query}) async {
    Database db = await database;
    if (query != null && query.isNotEmpty) {
      return await db.query(
        'contacts',
        where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
    } else {
      return await db.query('contacts', orderBy: 'name ASC');
    }
  }

  Future<int> updateContact(Map<String, dynamic> contact) async {
    Database db = await database;
    return await db.update(
      'contacts',
      contact,
      where: 'id = ?',
      whereArgs: [contact['id']],
    );
  }

  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
