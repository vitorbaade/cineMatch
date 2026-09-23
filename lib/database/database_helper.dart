import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/saved_movie.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'cinematch.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE saved_movies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tmdbId INTEGER NOT NULL UNIQUE,
            title TEXT NOT NULL,
            overview TEXT NOT NULL DEFAULT '',
            posterPath TEXT NOT NULL DEFAULT '',
            releaseDate TEXT NOT NULL DEFAULT '',
            voteAverage REAL NOT NULL DEFAULT 0,
            genres TEXT NOT NULL DEFAULT '',
            director TEXT NOT NULL DEFAULT '',
            cast TEXT NOT NULL DEFAULT '',
            durationMinutes INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'Para Assistir',
            userRating REAL,
            userComment TEXT NOT NULL DEFAULT '',
            dateAdded TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertMovie(SavedMovie movie) async {
    final db = await database;
    final data = movie.toMap()..remove('id');
    return db.insert(
      'saved_movies',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SavedMovie>> getSavedMovies() async {
    final db = await database;
    final result = await db.query('saved_movies', orderBy: 'dateAdded DESC');
    return result.map(SavedMovie.fromMap).toList();
  }

  Future<int> updateMovie(SavedMovie movie) async {
    final db = await database;
    final data = movie.toMap()..remove('id');
    return db.update(
      'saved_movies',
      data,
      where: 'tmdbId = ?',
      whereArgs: [movie.tmdbId],
    );
  }

  Future<int> deleteMovie(int tmdbId) async {
    final db = await database;
    return db.delete('saved_movies', where: 'tmdbId = ?', whereArgs: [tmdbId]);
  }

  Future<bool> isSaved(int tmdbId) async {
    final db = await database;
    final result = await db.query(
      'saved_movies',
      where: 'tmdbId = ?',
      whereArgs: [tmdbId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
