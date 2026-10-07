import 'movie.dart';

class MovieStatus {
  MovieStatus._();
  static const String toWatch = 'Para Assistir';
  static const String watched = 'Já Assisti';

  static const values = [toWatch, watched];
}

class SavedMovie {
  final int? id;
  final int tmdbId;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;
  final String genres;
  final String director;
  final String cast;
  final int durationMinutes;
  final String status;
  final double? userRating;
  final String userComment;
  final String dateAdded;

  const SavedMovie({
    this.id,
    required this.tmdbId,
    required this.title,
    this.overview = '',
    this.posterPath = '',
    this.releaseDate = '',
    this.voteAverage = 0,
    this.genres = '',
    this.director = '',
    this.cast = '',
    this.durationMinutes = 0,
    this.status = MovieStatus.toWatch,
    this.userRating,
    this.userComment = '',
    required this.dateAdded,
  });

  bool isWatched() => status == MovieStatus.watched;

  factory SavedMovie.fromMovie(Movie movie, {String status = MovieStatus.toWatch}) {
    return SavedMovie(
      tmdbId: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      releaseDate: movie.releaseDate,
      voteAverage: movie.voteAverage,
      genres: movie.genres.join(', '),
      director: movie.director,
      cast: movie.cast.join(', '),
      durationMinutes: movie.durationMinutes,
      status: status,
      dateAdded: DateTime.now().toIso8601String(),
    );
  }

  SavedMovie copyWith({
    String? status,
    double? userRating,
    String? userComment,
  }) {
    return SavedMovie(
      id: id,
      tmdbId: tmdbId,
      title: title,
      overview: overview,
      posterPath: posterPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      genres: genres,
      director: director,
      cast: cast,
      durationMinutes: durationMinutes,
      status: status ?? this.status,
      userRating: userRating ?? this.userRating,
      userComment: userComment ?? this.userComment,
      dateAdded: dateAdded,
    );
  }

  Movie toMovie() => Movie.fromSavedSnapshot(toMap());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tmdbId': tmdbId,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'genres': genres,
      'director': director,
      'cast': cast,
      'durationMinutes': durationMinutes,
      'status': status,
      'userRating': userRating,
      'userComment': userComment,
      'dateAdded': dateAdded,
    };
  }

  factory SavedMovie.fromMap(Map<String, dynamic> map) {
    return SavedMovie(
      id: map['id'] as int?,
      tmdbId: map['tmdbId'] as int,
      title: map['title'] as String,
      overview: map['overview'] as String? ?? '',
      posterPath: map['posterPath'] as String? ?? '',
      releaseDate: map['releaseDate'] as String? ?? '',
      voteAverage: (map['voteAverage'] as num?)?.toDouble() ?? 0,
      genres: map['genres'] as String? ?? '',
      director: map['director'] as String? ?? '',
      cast: map['cast'] as String? ?? '',
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      status: map['status'] as String? ?? MovieStatus.toWatch,
      userRating: map['userRating'] != null ? (map['userRating'] as num).toDouble() : null,
      userComment: map['userComment'] as String? ?? '',
      dateAdded: map['dateAdded'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
