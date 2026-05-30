import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';
import '../models/media_item.dart';

/// DatabaseHelper - singleton để quản lý SQLite database cho app
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // Lấy instance database (mở nếu chưa mở)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Khởi tạo database và tạo bảng nếu cần
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'image_video_manager.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Nếu nâng cấp từ version 1 -> 2, tạo bảng media
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE media (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              media_id TEXT NOT NULL UNIQUE,
              url TEXT NOT NULL,
              type TEXT NOT NULL,
              thumbnail TEXT,
              created_at INTEGER NOT NULL
            )
          ''');
        }
      },
    );
  }

  // Tạo bảng notes
  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        media_id TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Tạo thêm bảng media
    await db.execute('''
      CREATE TABLE media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        media_id TEXT NOT NULL UNIQUE,
        url TEXT NOT NULL,
        type TEXT NOT NULL,
        thumbnail TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Seed một vài media mẫu (6 ảnh từ picsum)
    final now = DateTime.now().millisecondsSinceEpoch;
    final medias = [
      {'media_id': 'img1', 'url': 'https://picsum.photos/id/1015/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1015/600/400', 'created_at': now},
      {'media_id': 'img2', 'url': 'https://picsum.photos/id/1025/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1025/600/400', 'created_at': now},
      {'media_id': 'img3', 'url': 'https://picsum.photos/id/1035/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1035/600/400', 'created_at': now},
      {'media_id': 'img4', 'url': 'https://picsum.photos/id/1045/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1045/600/400', 'created_at': now},
      {'media_id': 'img5', 'url': 'https://picsum.photos/id/1055/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1055/600/400', 'created_at': now},
      {'media_id': 'img6', 'url': 'https://picsum.photos/id/1065/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1065/600/400', 'created_at': now},
    ];

    for (final m in medias) {
      await db.insert('media', m);
    }
  }

  /// Thêm media mới vào bảng `media`.
  Future<int> insertMedia(MediaItemModel media) async {
    final db = await database;
    return await db.insert('media', media.toMap());
  }

  /// Lấy tất cả media, sắp xếp theo `created_at` giảm dần.
  Future<List<MediaItemModel>> getAllMedia() async {
    final db = await database;
    final maps = await db.query('media', orderBy: 'created_at DESC');
    return maps.map((m) => MediaItemModel.fromMap(m)).toList();
  }

  /// Lấy media theo mediaId
  Future<MediaItemModel?> getMediaByMediaId(String mediaId) async {
    final db = await database;
    final maps = await db.query('media', where: 'media_id = ?', whereArgs: [mediaId]);
    if (maps.isEmpty) return null;
    return MediaItemModel.fromMap(maps.first);
  }

  /// Cập nhật media (media.id phải khác null)
  Future<int> updateMedia(MediaItemModel media) async {
    if (media.id == null) throw ArgumentError('Media id is null, cannot update');
    final db = await database;
    return await db.update('media', media.toMap(), where: 'id = ?', whereArgs: [media.id]);
  }

  /// Xóa media theo id
  Future<int> deleteMediaById(int id) async {
    final db = await database;
    return await db.delete('media', where: 'id = ?', whereArgs: [id]);
  }

  /// Thêm một ghi chú mới vào bảng `notes`.
  /// Trả về id của hàng vừa được insert.
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  /// Lấy tất cả ghi chú, sắp xếp theo `created_at` giảm dần.
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'created_at DESC');
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  /// Lấy ghi chú theo `mediaId` (ảnh/video)
  Future<List<Note>> getNotesByMediaId(String mediaId) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'media_id = ?',
      whereArgs: [mediaId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  /// Tìm kiếm ghi chú theo tiêu đề (LIKE %query%)
  Future<List<Note>> searchNotesByTitle(String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  /// Cập nhật ghi chú (note.id phải khác null)
  Future<int> updateNote(Note note) async {
    if (note.id == null) throw ArgumentError('Note id is null, cannot update');
    final db = await database;
    return await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  /// Xóa ghi chú theo id
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Seed sample media nếu database rỗng (dùng lần đầu)
  Future<void> ensureSampleDataExists() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM media')) ?? 0;
    if (count == 0) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final medias = [
        {'media_id': 'img1', 'url': 'https://picsum.photos/id/1015/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1015/600/400', 'created_at': now},
        {'media_id': 'img2', 'url': 'https://picsum.photos/id/1025/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1025/600/400', 'created_at': now},
        {'media_id': 'img3', 'url': 'https://picsum.photos/id/1035/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1035/600/400', 'created_at': now},
        {'media_id': 'img4', 'url': 'https://picsum.photos/id/1045/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1045/600/400', 'created_at': now},
        {'media_id': 'img5', 'url': 'https://picsum.photos/id/1055/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1055/600/400', 'created_at': now},
        {'media_id': 'img6', 'url': 'https://picsum.photos/id/1065/600/400', 'type': 'image', 'thumbnail': 'https://picsum.photos/id/1065/600/400', 'created_at': now},
      ];
      for (final m in medias) {
        await db.insert('media', m, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
  }

  /// Đóng database (nếu cần)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
