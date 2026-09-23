import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_movie.dart';
import '../providers/my_list_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_stars.dart';
import '../widgets/responsive/adaptive_scaffold.dart';
import 'details_screen.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyListProvider>().loadSavedMovies();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyListProvider>();

    return AdaptiveScaffold(
      currentRoute: '/my-list',
      title: 'Minha Lista',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Para Assistir (${provider.toWatch.length})'),
              Tab(text: 'Já Assisti (${provider.watched.length})'),
            ],
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _MovieListSection(
                        entries: provider.toWatch,
                        emptyText:
                            'Sua lista "Para Assistir" está vazia.\nAdicione filmes pelos detalhes de qualquer título.',
                      ),
                      _MovieListSection(
                        entries: provider.watched,
                        emptyText: 'Você ainda não marcou nenhum filme como assistido.',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _MovieListSection extends StatelessWidget {
  final List<SavedMovie> entries;
  final String emptyText;

  const _MovieListSection({required this.entries, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.movie_filter_outlined, color: AppColors.textSecondary, size: 42),
              const SizedBox(height: 14),
              Text(
                emptyText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 480).floor().clamp(1, 3);
        if (columns == 1) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _SavedMovieTile(entry: entries[index]),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          itemCount: entries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 14,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, index) => _SavedMovieTile(entry: entries[index]),
        );
      },
    );
  }
}

class _SavedMovieTile extends StatelessWidget {
  final SavedMovie entry;
  const _SavedMovieTile({required this.entry});

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover da Minha Lista?'),
        content: Text('"${entry.title}" e sua avaliação serão removidos permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<MyListProvider>().removeMovieFromList(entry.tmdbId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = entry.toMovie();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed(DetailsScreen.routeName, arguments: movie),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.getFullPosterUrl(),
                  width: 64,
                  height: 92,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 92,
                    color: AppColors.surfaceElevated,
                    child: const Icon(Icons.movie_outlined, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.primaryGenre} • ${movie.releaseYear}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 8),
                    if (entry.isWatched())
                      RatingStars(rating: entry.userRating ?? 0, size: 16)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Para Assistir',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ),
                    if (entry.userComment.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        entry.userComment,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
                onPressed: () => _confirmRemove(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
