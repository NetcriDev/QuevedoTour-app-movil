import 'dart:convert';
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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE favorites(id TEXT PRIMARY KEY)');
        await _createReviewsTable(db);
        await _createCoreTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createReviewsTable(db);
        }
        if (oldVersion < 3) {
          await _createCoreTables(db);
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

  Future<void> _createCoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE establishments(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        address TEXT,
        location TEXT,
        rating REAL,
        images TEXT,
        id_category TEXT,
        id_sub_category TEXT,
        phone TEXT,
        website TEXT,
        price REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT,
        icon TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE sub_categories(
        id TEXT PRIMARY KEY,
        name TEXT,
        id_category TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE banners(
        id TEXT PRIMARY KEY,
        image TEXT,
        title TEXT
      )
    ''');
  }

  // --- Core Data Methods ---

  Future<void> saveEstablishments(List<Map<String, dynamic>> list) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var item in list) {
        final map = Map<String, dynamic>.from(item);
        if (map['images'] is List) {
          map['images'] = jsonEncode(map['images']);
        }
        await txn.insert('establishments', map, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getEstablishments() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('establishments');
    return result.map((item) {
      final map = Map<String, dynamic>.from(item);
      if (map['images'] != null && map['images'] is String) {
        try {
          map['images'] = jsonDecode(map['images']);
        } catch (_) {}
      }
      return map;
    }).toList();
  }

  Future<void> saveCategories(List<Map<String, dynamic>> list) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var item in list) {
        await txn.insert('categories', item, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<void> saveSubCategories(List<Map<String, dynamic>> list) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var item in list) {
        await txn.insert('sub_categories', item, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getSubCategories() async {
    final db = await database;
    return await db.query('sub_categories');
  }

  Future<void> saveBanners(List<Map<String, dynamic>> list) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var item in list) {
        await txn.insert('banners', item, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getBanners() async {
    final db = await database;
    return await db.query('banners');
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
