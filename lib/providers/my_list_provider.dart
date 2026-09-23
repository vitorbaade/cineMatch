import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/movie.dart';
import '../models/saved_movie.dart';

class MyListProvider extends ChangeNotifier {
  MyListProvider({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  List<SavedMovie> savedMovies = [];
  bool isLoading = false;

  List<SavedMovie> get toWatch =>
      savedMovies.where((m) => m.status == MovieStatus.toWatch).toList();

  List<SavedMovie> get watched =>
      savedMovies.where((m) => m.status == MovieStatus.watched).toList();

  // carrega a biblioteca salva do banco local
  Future<void> loadSavedMovies() async {
    isLoading = true;
    notifyListeners();
    savedMovies = await _db.getSavedMovies();
    isLoading = false;
    notifyListeners();
  }

  bool isMovieSaved(int tmdbId) => savedMovies.any((m) => m.tmdbId == tmdbId);

  SavedMovie? entryFor(int tmdbId) {
    try {
      return savedMovies.firstWhere((m) => m.tmdbId == tmdbId);
    } catch (_) {
      return null;
    }
  }

  Future<void> addMovieToList(Movie movie, {String status = MovieStatus.toWatch}) async {
    final saved = SavedMovie.fromMovie(movie, status: status);
    await _db.insertMovie(saved);
    savedMovies.removeWhere((m) => m.tmdbId == movie.id);
    savedMovies.insert(0, saved);
    notifyListeners();
  }

  Future<void> removeMovieFromList(int tmdbId) async {
    await _db.deleteMovie(tmdbId);
    savedMovies.removeWhere((m) => m.tmdbId == tmdbId);
    notifyListeners();
  }

  Future<void> rateMovie(Movie movie, double rating, String comment) async {
    final existing = entryFor(movie.id) ?? SavedMovie.fromMovie(movie);
    final updated = existing.copyWith(
      status: MovieStatus.watched,
      userRating: rating.clamp(0, 5),
      userComment: comment,
    );
    await _db.insertMovie(updated); 
    savedMovies.removeWhere((m) => m.tmdbId == movie.id);
    savedMovies.insert(0, updated);
    notifyListeners();
  }
}
