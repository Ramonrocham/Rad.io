import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RadioDatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'radio_database.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabela de Favoritos (Adicionei 'url' para você conseguir tocar depois)
        await db.execute('''
          CREATE TABLE favorites (
            stationuuid TEXT PRIMARY KEY,
            name TEXT,
            state TEXT,
            countrycode TEXT,
            favicon TEXT,
            url TEXT,
            tags TEXT,     
            bitrate INTEGER
          )
        ''');
        // Tabela de Recentes
        await db.execute('''
          CREATE TABLE recent (
            stationuuid TEXT PRIMARY KEY,
            name TEXT,
            state TEXT,
            countrycode TEXT,
            favicon TEXT,
            url TEXT,
            tags TEXT,
            bitrate INTEGER,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  // --- MÉTODOS PARA FAVORITOS ---

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  // Método unificado para favoritar/desfavoritar
  static Future<bool> toggleFavorite(Map<String, dynamic> radio) async {
    final db = await database;
    
    // Verificamos se já existe pelo stationuuid
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'stationuuid = ?',
      whereArgs: [radio['stationuuid']],
    );

    if (maps.isNotEmpty) {
      await db.delete(
        'favorites',
        where: 'stationuuid = ?',
        whereArgs: [radio['stationuuid']],
      );
      return false; // Foi removido
    } else {
      await db.insert('favorites', {
        'stationuuid': radio['stationuuid'],
        'name': radio['name'],
        'favicon': radio['favicon'],
        'url': radio['url'] ?? radio['url_resolved'], // Garante que a URL seja salva
        'state': radio['state'],
        'countrycode': radio['countrycode'],
        'tags': radio['tags']?.toString() ?? "",
        'bitrate': radio['bitrate'] ?? 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true; // Foi adicionado
    }
  }

  static Future<bool> isFavorite(String stationuuid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'stationuuid = ?',
      whereArgs: [stationuuid],
    );
    return maps.isNotEmpty;
  }

  // --- MÉTODOS PARA RECENTES ---

  static Future<void> addRecent(Map<String, dynamic> radio) async {
    final db = await database;
    await db.insert('recent', {
      'stationuuid': radio['stationuuid'],
      'name': radio['name'],
      'favicon': radio['favicon'],
      'url': radio['url'] ?? radio['url_resolved'],
      'state': radio['state'],
      'countrycode': radio['countrycode'],
      'tags': radio['tags']?.toString() ?? "",
      'bitrate': radio['bitrate'] ?? 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getRecent() async {
    final db = await database;
    return await db.query('recent', orderBy: 'timestamp DESC', limit: 20);
  }

  static Future<void> clearRecent() async {
    final db = await database;
    await db.delete('recent');
  }
}