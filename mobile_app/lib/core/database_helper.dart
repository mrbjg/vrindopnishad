import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'content_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sacred_wisdom.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
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
        audioUrl TEXT
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
  }

  Future<void> insertContent(SacredContent content) async {
    final db = await instance.database;
    await db.insert(
      'sacred_content',
      content.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SacredContent>> fetchAllContent() async {
    final db = await instance.database;
    final result = await db.query('sacred_content');

    return result.map((json) => SacredContent.fromMap(json)).toList();
  }

  Future<void> deleteContent(String id) async {
    final db = await instance.database;
    await db.delete('sacred_content', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllContent() async {
    final db = await instance.database;
    await db.delete('sacred_content');
  }
}
