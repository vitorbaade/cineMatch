import '../config/tmdb_config.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final List<String> genres;
  final String director;
  final List<String> cast;
  final int durationMinutes;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.genres,
    this.director = '',
    this.cast = const [],
    this.durationMinutes = 0,
  });

  String getFullPosterUrl() =>
      posterPath.isEmpty ? '' : '${TmdbConfig.imageBaseUrl}$posterPath';

  String getFullBackdropUrl() =>
      backdropPath.isEmpty ? getFullPosterUrl() : '${TmdbConfig.backdropBaseUrl}$backdropPath';

  int get releaseYear {
    if (releaseDate.isEmpty) return 0;
    return int.tryParse(releaseDate.split('-').first) ?? 0;
  }

  String get durationLabel {
    if (durationMinutes <= 0) return '—';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}min';
    return '${h}h ${m.toString().padLeft(2, '0')}min';
  }

  String get primaryGenre => genres.isNotEmpty ? genres.first : 'Geral';

  factory Movie.fromJson(Map<String, dynamic> json, {Map<int, String> genreMap = const {}}) {
    final List<String> genreNames;
    if (json['genres'] != null) {
      genreNames = (json['genres'] as List)
          .map((g) => (g as Map<String, dynamic>)['name'] as String)
          .toList();
    } else {
      final ids = List<int>.from((json['genre_ids'] as List?) ?? const []);
      genreNames = ids.map((id) => genreMap[id]).whereType<String>().toList();
    }

    String director = '';
    List<String> cast = const [];
    if (json['credits'] != null) {
      final credits = json['credits'] as Map<String, dynamic>;
      final crew = List<Map<String, dynamic>>.from((credits['crew'] as List?) ?? const []);
      final directorEntry = crew.firstWhere(
        (c) => c['job'] == 'Director',
        orElse: () => const {},
      );
      director = directorEntry['name'] as String? ?? '';

      final castList = List<Map<String, dynamic>>.from((credits['cast'] as List?) ?? const []);
      cast = castList.take(5).map((c) => c['name'] as String).toList();
    }

    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['original_title'] ?? 'Sem título') as String,
      overview: (json['overview'] as String?)?.trim().isNotEmpty == true
          ? json['overview'] as String
          : 'Sinopse não disponível.',
      posterPath: json['poster_path'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genres: genreNames,
      director: director,
      cast: cast,
      durationMinutes: json['runtime'] as int? ?? 0,
    );
  }

  factory Movie.fromSavedSnapshot(Map<String, dynamic> map) {
    return Movie(
      id: map['tmdbId'] as int,
      title: map['title'] as String,
      overview: map['overview'] as String? ?? '',
      posterPath: map['posterPath'] as String? ?? '',
      backdropPath: '',
      releaseDate: map['releaseDate'] as String? ?? '',
      voteAverage: (map['voteAverage'] as num?)?.toDouble() ?? 0,
      genres: ((map['genres'] as String?) ?? '')
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toList(),
      director: map['director'] as String? ?? '',
      cast: ((map['cast'] as String?) ?? '')
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList(),
      durationMinutes: map['durationMinutes'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) => other is Movie && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
