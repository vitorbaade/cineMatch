import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/movie.dart';

class RouletteProvider extends ChangeNotifier {
  Movie? selectedMovie;
  bool isSpinning = false;
  String? errorMessage;

  final Set<String> favoriteGenres = {};
  final Random _random = Random();

  void toggleGenre(String genre) {
    if (favoriteGenres.contains(genre)) {
      favoriteGenres.remove(genre);
    } else {
      favoriteGenres.add(genre);
    }
    notifyListeners();
  }

  void clearGenres() {
    favoriteGenres.clear();
    notifyListeners();
  }

  Future<Movie?> drawRandomMovie(List<Movie> pool) async {
    if (pool.isEmpty) {
      errorMessage = 'Nenhum filme disponível para sorteio no momento.';
      notifyListeners();
      return null;
    }

    isSpinning = true;
    errorMessage = null;
    selectedMovie = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    List<Movie> candidates = pool;
    if (favoriteGenres.isNotEmpty) {
      candidates = pool.where((m) => m.genres.any(favoriteGenres.contains)).toList();
    }
    if (candidates.isEmpty) {
      candidates = pool;
    }

    selectedMovie = candidates[_random.nextInt(candidates.length)];
    isSpinning = false;
    notifyListeners();
    return selectedMovie;
  }

  void reset() {
    selectedMovie = null;
    errorMessage = null;
    notifyListeners();
  }
}
