import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quevedotour.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE favorites(id TEXT PRIMARY KEY)');
        await _createReviewsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createReviewsTable(db);
        }
      },
    );
  }

  Future<void> _createReviewsTable(Database db) async {
    await db.execute('''
      CREATE TABLE reviews(
        id TEXT PRIMARY KEY,
        id_establishment TEXT,
        id_user TEXT,
        user_name TEXT,
        user_email TEXT,
        user_image TEXT,
        rating REAL,
        comment TEXT,
        created_at TEXT,
        images TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');
  }

  // --- Favorites Methods ---

  Future<void> addFavorite(String id) async {
    final db = await database;
    await db.insert('favorites', {'id': id}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) => maps[i]['id'] as String);
  }

  // --- Reviews Methods ---

  Future<void> saveReview(Map<String, dynamic> reviewJson) async {
    final db = await database;
    await db.insert('reviews', reviewJson, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getReviewsByEstablishment(String establishmentId) async {
    final db = await database;
    return await db.query(
      'reviews', 
      where: 'id_establishment = ?', 
      whereArgs: [establishmentId],
      orderBy: 'created_at DESC'
    );
  }

  Future<void> deleteReview(String id) async {
    final db = await database;
    await db.delete('reviews', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedReviews() async {
    final db = await database;
    return await db.query('reviews', where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<void> markReviewAsSynced(String id) async {
    final db = await database;
    await db.update('reviews', {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
