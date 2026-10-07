import 'package:flutter/foundation.dart';

import '../models/genre.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieProvider extends ChangeNotifier {
  MovieProvider({TmdbService? service}) : _service = service ?? TmdbService();

  final TmdbService _service;

  List<Movie> trendingMovies = [];
  List<Movie> topRatedMovies = [];
  List<Movie> searchResults = [];
  List<Movie> genreResults = [];
  List<Genre> genres = [];

  bool isLoading = false;
  bool isSearchLoading = false;
  String? errorMessage;

  String searchQuery = '';
  Genre? selectedGenre;

  bool get isSearching => searchQuery.trim().isNotEmpty;
  bool get isFilteringByGenre => selectedGenre != null;

  Movie? get movieOfTheDay => trendingMovies.isNotEmpty
      ? trendingMovies[DateTime.now().day % trendingMovies.length]
      : null;

  List<Movie> get allMovies {
    final seen = <int>{};
    final combined = <Movie>[];
    for (final m in [...trendingMovies, ...topRatedMovies]) {
      if (seen.add(m.id)) combined.add(m);
    }
    return combined;
  }

  List<Movie> get visibleMovies {
    if (isSearching) return searchResults;
    if (isFilteringByGenre) return genreResults;
    return trendingMovies;
  }

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      genres = (await _service.getGenres())
          .entries
          .map((e) => Genre(id: e.key, name: e.value))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      await Future.wait([fetchTrending(notify: false), fetchTopRated(notify: false)]);
    } on TmdbException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Não foi possível carregar o catálogo. Tente novamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // carrega o carrossel
  Future<void> fetchTrending({bool notify = true}) async {
    try {
      trendingMovies = await _service.getTrendingMovies();
      errorMessage = null;
    } on TmdbException catch (e) {
      errorMessage = e.message;
    } finally {
      if (notify) notifyListeners();
    }
  }

  // carrega o carrossel.
  Future<void> fetchTopRated({bool notify = true}) async {
    try {
      topRatedMovies = await _service.getTopRatedMovies();
      errorMessage = null;
    } on TmdbException catch (e) {
      errorMessage = e.message;
    } finally {
      if (notify) notifyListeners();
    }
  }

  Future<void> search(String query) async {
    searchQuery = query;
    if (query.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }
    isSearchLoading = true;
    notifyListeners();
    try {
      searchResults = await _service.searchMovies(query);
      errorMessage = null;
    } on TmdbException catch (e) {
      errorMessage = e.message;
    } finally {
      isSearchLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectGenre(Genre? genre) async {
    selectedGenre = genre;
    if (genre == null) {
      genreResults = [];
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      genreResults = await _service.getMoviesByGenre(genre.id);
      errorMessage = null;
    } on TmdbException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    searchQuery = '';
    searchResults = [];
    notifyListeners();
  }
}
