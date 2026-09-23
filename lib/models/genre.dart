// Par 'id'/'nome' de gênero, como retornado por '/genre/movie/list' do TMDB. Usado nos chips de filtro da Home e nos favoritos.
class Genre {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  @override
  bool operator ==(Object other) => other is Genre && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
