import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/my_list_provider.dart';
import '../theme/app_theme.dart';
import 'movie_card.dart';
import 'responsive/breakpoints.dart';

/// Lista de filmes reutilizada na Home, na busca e nos resultados
/// filtrados por gênero.
///
/// Responsiva: no celular vira um **carrossel horizontal** (arrasta pro
/// lado, como Netflix/Prime Video); em tablet/desktop vira uma **grade**
/// (`SliverGridDelegateWithMaxCrossAxisExtent`, que já ajusta o número de
/// colunas conforme a largura disponível).
class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final ValueChanged<Movie> onTapMovie;
  final String emptyMessage;

  const MovieGrid({
    super.key,
    required this.movies,
    required this.onTapMovie,
    this.emptyMessage = 'Nenhum filme encontrado.',
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.movie_filter_outlined, color: AppColors.textSecondary, size: 40),
              const SizedBox(height: 12),
              Text(emptyMessage, style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final myList = context.watch<MyListProvider>();
    final isMobile = !Breakpoints.isTablet(context);

    if (isMobile) {
      return SizedBox(
        height: 260,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: movies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final movie = movies[index];
            return SizedBox(
              width: 150,
              child: MovieCard(
                movie: movie,
                isSaved: myList.isMovieSaved(movie.id),
                onTap: () => onTapMovie(movie),
              ),
            );
          },
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 175,
        mainAxisSpacing: 18,
        crossAxisSpacing: 14,
        childAspectRatio: 0.52,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(
          movie: movie,
          isSaved: myList.isMovieSaved(movie.id),
          onTap: () => onTapMovie(movie),
        );
      },
    );
  }
}