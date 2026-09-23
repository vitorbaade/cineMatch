import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../providers/roulette_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/genre_chip.dart';
import '../widgets/movie_card.dart';
import '../widgets/responsive/adaptive_scaffold.dart';
import '../widgets/responsive/breakpoints.dart';
import 'details_screen.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieProvider>();
      if (provider.trendingMovies.isEmpty) provider.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roulette = context.watch<RouletteProvider>();
    final movieProvider = context.watch<MovieProvider>();
    final isDesktop = Breakpoints.isDesktop(context);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.casino_rounded, color: AppColors.primary, size: 46),
        const SizedBox(height: 12),
        const Text(
          'Sem ideia do que assistir?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Escolha seus gêneros favoritos (opcional) e deixe o CineMatch sortear um filme para você, com base nas tendências e melhores avaliados do TMDB.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: movieProvider.genres.map((genre) {
            return GenreChip(
              label: genre.name,
              selected: roulette.favoriteGenres.contains(genre.name),
              onTap: () => roulette.toggleGenre(genre.name),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: isDesktop ? 280 : double.infinity,
          child: ElevatedButton.icon(
            onPressed: roulette.isSpinning || movieProvider.allMovies.isEmpty
                ? null
                : () => roulette.drawRandomMovie(movieProvider.allMovies),
            icon: roulette.isSpinning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.shuffle_rounded),
            label: Text(roulette.isSpinning ? 'Sorteando…' : 'Sortear Filme'),
          ),
        ),
        if (roulette.errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(
            roulette.errorMessage!,
            style: const TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ],
        if (movieProvider.allMovies.isEmpty && !movieProvider.isLoading) ...[
          const SizedBox(height: 14),
          const Text(
            'Carregue o catálogo na Home primeiro (ou verifique sua conexão) para poder sortear.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ],
    );

    return AdaptiveScaffold(
      currentRoute: '/roulette',
      title: 'Cine Match',
      body: isDesktop
          ? Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: header),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 5,
                    child: roulette.selectedMovie != null
                        ? _ResultCard(movie: roulette.selectedMovie!)
                        : const _EmptyResultHint(),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                header,
                const SizedBox(height: 30),
                if (roulette.selectedMovie != null) _ResultCard(movie: roulette.selectedMovie!),
              ],
            ),
    );
  }
}

class _EmptyResultHint extends StatelessWidget {
  const _EmptyResultHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_filter_outlined, color: AppColors.textSecondary, size: 40),
          SizedBox(height: 12),
          Text('Sua recomendação vai aparecer aqui', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Movie movie;
  const _ResultCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Sua recomendação é…', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 14),
        SizedBox(
          height: 320,
          child: MovieCard(
            movie: movie,
            onTap: () => Navigator.of(context).pushNamed(DetailsScreen.routeName, arguments: movie),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(DetailsScreen.routeName, arguments: movie),
            icon: const Icon(Icons.info_outline_rounded),
            label: const Text('Ver Detalhes Completos'),
          ),
        ),
      ],
    );
  }
}
