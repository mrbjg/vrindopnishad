import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'content_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const int _databaseVersion = 4; // Define database version
  static const String _databaseName = 'sacred_wisdom.db'; // Define database name

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null; // sqflite is not supported on web natively
    if (_database != null) return _database!;
    _database = await _initDB(); // Call _initDB without arguments
    return _database;
  }

  Future<Database?> _initDB() async { // Removed filePath argument
    if (kIsWeb) return null;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName); // Use _databaseName

    return await openDatabase(path, version: _databaseVersion, onCreate: _createDB, onUpgrade: _upgradeDB); // Use _databaseVersion
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sacred_content (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        sanskritText TEXT NOT NULL,
        translation TEXT NOT NULL,
        hindiMeaning TEXT NOT NULL,
        commentary TEXT NOT NULL,
        imageUrl TEXT,
        audioUrl TEXT,
        author TEXT,
        book TEXT,
        section TEXT,
        chapter TEXT,
        heading TEXT,
        tags TEXT,
        audioTags TEXT,
        videoTags TEXT,
        imageTags TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add audioUrl column if upgrading from version 1
      try {
        await db.execute('ALTER TABLE sacred_content ADD COLUMN audioUrl TEXT');
      } catch (e) {
        // Column might already exist
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE sacred_content ADD COLUMN author TEXT');
        await db.execute('ALTER TABLE sacred_content ADD COLUMN tags TEXT');
      } catch (e) {
        // Migration might fail if columns exist
      }
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE sacred_content ADD COLUMN book TEXT');
        await db.execute('ALTER TABLE sacred_content ADD COLUMN section TEXT');
        await db.execute('ALTER TABLE sacred_content ADD COLUMN chapter TEXT');
        await db.execute('ALTER TABLE sacred_content ADD COLUMN heading TEXT');
        await db.execute('ALTER TABLE sacred_content ADD COLUMN audioTags TEXT');
        await db.execute('ALTER TABLE sacred_content ADD COLUMN videoTags TEXT');
        await db.execute('ALTER TABLE sacred_content ADD COLUMN imageTags TEXT');
      } catch (e) {
        // Column might already exist
      }
    }
  }

  Future<void> insertContent(SacredContent content) async {
    final db = await instance.database;
    if (db == null) return;
    await db.insert(
      'sacred_content',
      content.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SacredContent>> fetchAllContent() async {
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('sacred_content');

    return result.map((json) => SacredContent.fromMap(json)).toList();
  }

  Future<void> deleteContent(String id) async {
    final db = await instance.database;
    if (db == null) return;
    await db.delete('sacred_content', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllContent() async {
    final db = await instance.database;
    if (db == null) return;
    await db.delete('sacred_content');
  }
}
