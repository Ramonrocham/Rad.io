import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RadioDatabaseService {
  static Database? _db;

  // Singleton para garantir uma única instância do banco
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
        // Tabela de Favoritos
        await db.execute('''
          CREATE TABLE favorites (
            stationuuid TEXT PRIMARY KEY,
            name TEXT,
            state TEXT,
            countrycode TEXT,
            favicon TEXT
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
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  // --- MÉTODOS PARA FAVORITOS ---

  static Future<void> addFavorite(Map<String, dynamic> radio) async {
    final db = await database;
    await db.insert('favorites', radio, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  static Future<void> removeFavorite(String stationuuid) async {
    final db = await database;
    await db.delete('favorites', where: 'stationuuid = ?', whereArgs: [stationuuid]);
  }

  // --- MÉTODOS PARA RECENTES ---

  static Future<void> addRecent(Map<String, dynamic> radio) async {
    final db = await database;
    // Ao adicionar, usamos o REPLACE para atualizar o timestamp se a rádio já existir
    await db.insert('recent', radio, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getRecent() async {
    final db = await database;
    // Retorna ordenado pela data para mostrar as mais novas primeiro
    return await db.query('recent', orderBy: 'timestamp DESC', limit: 20);
  }

  static Future<void> removeRecent(String stationuuid) async {
    final db = await database;
    await db.delete('recent', where: 'stationuuid = ?', whereArgs: [stationuuid]);
  }

  static Future<void> clearRecent() async {
    final db = await database;
    await db.delete('recent');
  }
}