class TmdbConfig {
  TmdbConfig._();

  static const String apiKey = 'COLOQUE_SUA_CHAVE_DE_API_AQUI';

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/w780';

  static const String language = 'pt-BR';

  static bool get isConfigured => apiKey.isNotEmpty && apiKey != 'YOUR_TMDB_API_KEY_HERE';
}
