import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/tmdb_config.dart';
import '../models/movie.dart';

class TmdbException implements Exception {
  final String message;
  TmdbException(this.message);

  @override
  String toString() => message;
}

class TmdbService {
  final String baseUrl = TmdbConfig.baseUrl;
  final String apiKey = TmdbConfig.apiKey;

  Map<int, String> _genreCache = {};

  Uri _buildUri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: {
      'api_key': apiKey,
      'language': TmdbConfig.language,
      ...?query,
    });
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    if (!TmdbConfig.isConfigured) {
      throw TmdbException(
        'Configure sua chave da API do TMDB em lib/config/tmdb_config.dart para carregar dados reais.',
      );
    }
    http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 12));
    } catch (_) {
      throw TmdbException('Falha de conexão. Verifique sua internet e tente novamente.');
    }

    if (response.statusCode == 401) {
      throw TmdbException('Chave de API do TMDB inválida.');
    }
    if (response.statusCode != 200) {
      throw TmdbException('O TMDB retornou um erro (${response.statusCode}). Tente novamente.');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  Future<Map<int, String>> getGenres() async {
    if (_genreCache.isNotEmpty) return _genreCache;
    final json = await _get(_buildUri('/genre/movie/list'));
    final list = List<Map<String, dynamic>>.from(json['genres'] as List);
    _genreCache = {for (final g in list) g['id'] as int: g['name'] as String};
    return _genreCache;
  }

  List<Movie> _parseResults(Map<String, dynamic> json, Map<int, String> genreMap) {
    final results = List<Map<String, dynamic>>.from((json['results'] as List?) ?? const []);
    return results.map((m) => Movie.fromJson(m, genreMap: genreMap)).toList();
  }

  Future<List<Movie>> getTrendingMovies() async {
    final genreMap = await getGenres();
    final json = await _get(_buildUri('/trending/movie/day'));
    return _parseResults(json, genreMap);
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final genreMap = await getGenres();
    final json = await _get(_buildUri('/movie/top_rated'));
    return _parseResults(json, genreMap);
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final genreMap = await getGenres();
    final json = await _get(_buildUri('/search/movie', {'query': query, 'include_adult': 'false'}));
    return _parseResults(json, genreMap);
  }

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    final genreMap = await getGenres();
    final json = await _get(_buildUri('/discover/movie', {
      'with_genres': '$genreId',
      'sort_by': 'popularity.desc',
    }));
    return _parseResults(json, genreMap);
  }

  Future<Movie?> getMovieDetails(int id) async {
    final genreMap = await getGenres();
    try {
      final json = await _get(_buildUri('/movie/$id', {'append_to_response': 'credits'}));
      return Movie.fromJson(json, genreMap: genreMap);
    } on TmdbException {
      rethrow;
    } catch (_) {
      return null;
    }
  }
}
