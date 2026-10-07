import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../providers/my_list_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/genre_chip.dart';
import '../widgets/movie_grid.dart';
import '../widgets/responsive/adaptive_scaffold.dart';
import '../widgets/responsive/breakpoints.dart';
import '../widgets/section_header.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieProvider>();
      if (provider.trendingMovies.isEmpty) provider.init();
      context.read<MyListProvider>().loadSavedMovies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(Movie movie) {
    Navigator.of(context).pushNamed(DetailsScreen.routeName, arguments: movie);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    final isDesktop = Breakpoints.isDesktop(context);

    return AdaptiveScaffold(
      currentRoute: '/',
      title: 'Cine Match',
      actions: [
        IconButton(
          icon: const Icon(Icons.casino_rounded),
          tooltip: 'Cine Match — sortear filme',
          onPressed: () => Navigator.of(context).pushReplacementNamed('/roulette'),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => Future.wait([provider.fetchTrending(), provider.fetchTopRated()]),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            _SearchBar(controller: _searchController),
            const SizedBox(height: 20),

            if (provider.errorMessage != null && !provider.isSearching) ...[
              _ErrorBanner(
                message: provider.errorMessage!,
                onRetry: () => provider.init(),
              ),
              const SizedBox(height: 20),
            ],

            if (!provider.isSearching) ...[
              if (provider.movieOfTheDay != null)
                isDesktop
                    ? _MovieOfTheDayBannerWide(
                        movie: provider.movieOfTheDay!,
                        onDetails: () => _openDetails(provider.movieOfTheDay!),
                      )
                    : _MovieOfTheDayBanner(
                        movie: provider.movieOfTheDay!,
                        onDetails: () => _openDetails(provider.movieOfTheDay!),
                      ),
              const SizedBox(height: 24),
              _GenreChips(),
              const SizedBox(height: 22),
            ],

            if (provider.isSearching) ...[
              SectionHeader(
                title: 'Resultados para "${provider.searchQuery}"',
                icon: Icons.search_rounded,
              ),
              provider.isSearchLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : provider.searchResults.isEmpty
                      ? const _SearchEmptyState()
                      : MovieGrid(movies: provider.searchResults, onTapMovie: _openDetails),
            ] else if (provider.isFilteringByGenre) ...[
              SectionHeader(title: provider.selectedGenre!.name, icon: Icons.filter_list_rounded),
              provider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : MovieGrid(movies: provider.genreResults, onTapMovie: _openDetails),
            ] else if (provider.isLoading) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else ...[
              const SectionHeader(title: 'Em Alta', icon: Icons.local_fire_department_rounded),
              MovieGrid(movies: provider.trendingMovies, onTapMovie: _openDetails),
              const SizedBox(height: 28),
              const SectionHeader(title: 'Melhores Avaliados', icon: Icons.star_rounded),
              MovieGrid(movies: provider.topRatedMovies, onTapMovie: _openDetails),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MovieProvider>();
    return TextField(
      controller: controller,
      onChanged: provider.search, // busca em tempo real.
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por título…',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () {
                  controller.clear();
                  provider.clearSearch();
                },
              ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          'Nenhum filme encontrado com esse termo.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}

class _GenreChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    if (provider.genres.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.genres.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GenreChip(
              label: 'Todos',
              selected: provider.selectedGenre == null,
              onTap: () => provider.selectGenre(null),
            );
          }
          final genre = provider.genres[index - 1];
          return GenreChip(
            label: genre.name,
            selected: provider.selectedGenre?.id == genre.id,
            onTap: () => provider.selectGenre(genre),
          );
        },
      ),
    );
  }
}

class _MovieOfTheDayBanner extends StatelessWidget {
  final Movie movie;
  final VoidCallback onDetails;

  const _MovieOfTheDayBanner({required this.movie, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.network(
              movie.getFullBackdropUrl(),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceElevated),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.88)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: _BannerContent(movie: movie, onDetails: onDetails),
          ),
        ],
      ),
    );
  }
}

class _MovieOfTheDayBannerWide extends StatelessWidget {
  final Movie movie;
  final VoidCallback onDetails;

  const _MovieOfTheDayBannerWide({required this.movie, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 320,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              movie.getFullBackdropUrl(),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceElevated),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.92)],
                  stops: const [0.35, 1],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: 460,
                  child: _BannerContent(movie: movie, onDetails: onDetails, wide: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final Movie movie;
  final VoidCallback onDetails;
  final bool wide;

  const _BannerContent({required this.movie, required this.onDetails, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'FILME DO DIA',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.6),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          movie.title,
          maxLines: wide ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: wide ? 28 : 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${movie.primaryGenre} • ${movie.releaseYear} • ⭐ ${movie.voteAverage.toStringAsFixed(1)}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        if (wide) ...[
          const SizedBox(height: 12),
          Text(
            movie.overview,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: onDetails,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Ver Detalhes'),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/roulette'),
              icon: const Icon(Icons.casino_rounded, size: 18),
              label: const Text('Match'),
            ),
          ],
        ),
      ],
    );
  }
}
