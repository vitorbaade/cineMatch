import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../models/saved_movie.dart';
import '../providers/my_list_provider.dart';
import '../services/tmdb_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_stars.dart';
import '../widgets/responsive/breakpoints.dart';

class DetailsScreen extends StatefulWidget {
  static const routeName = '/details';

  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TmdbService _service = TmdbService();
  final TextEditingController _commentController = TextEditingController();

  Movie? _movie;
  bool _loadingDetails = false;
  bool _argsInitialized = false;
  double _pendingRating = 0;
  bool _ratingInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsInitialized) return;
    _argsInitialized = true;

    final initial = ModalRoute.of(context)!.settings.arguments as Movie;
    _movie = initial;

    if (initial.director.isEmpty || initial.durationMinutes == 0) {
      _fetchFullDetails(initial.id);
    }
  }

  Future<void> _fetchFullDetails(int id) async {
    setState(() => _loadingDetails = true);
    try {
      final full = await _service.getMovieDetails(id);
      if (full != null && mounted) {
        setState(() => _movie = full);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _syncFromSaved(SavedMovie? saved) {
    if (_ratingInitialized || saved == null) return;
    _pendingRating = saved.userRating ?? 0;
    _commentController.text = saved.userComment;
    _ratingInitialized = true;
  }

  Future<void> _confirmRemove(BuildContext context, Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover da Minha Lista?'),
        content: Text(
          'Isso vai remover "${movie.title}" e sua avaliação pessoal (nota e comentário) da sua biblioteca. Essa ação não pode ser desfeita.',
        ),
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
      await context.read<MyListProvider>().removeMovieFromList(movie.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${movie.title}" removido da Minha Lista.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movie!;
    final myList = context.watch<MyListProvider>();
    final isSaved = myList.isMovieSaved(movie.id);
    final saved = myList.entryFor(movie.id);
    _syncFromSaved(saved);

    final isDesktop = Breakpoints.isDesktop(context);

    return Scaffold(
      body: isDesktop
          ? _WideDetails(
              movie: movie,
              isSaved: isSaved,
              saved: saved,
              loadingDetails: _loadingDetails,
              pendingRating: _pendingRating,
              commentController: _commentController,
              onRatingChanged: (r) => setState(() => _pendingRating = r),
              onConfirmRemove: () => _confirmRemove(context, movie),
            )
          : _NarrowDetails(
              movie: movie,
              isSaved: isSaved,
              saved: saved,
              loadingDetails: _loadingDetails,
              pendingRating: _pendingRating,
              commentController: _commentController,
              onRatingChanged: (r) => setState(() => _pendingRating = r),
              onConfirmRemove: () => _confirmRemove(context, movie),
            ),
    );
  }
}

// layout para celular/tablet
class _NarrowDetails extends StatelessWidget {
  final Movie movie;
  final bool isSaved;
  final SavedMovie? saved;
  final bool loadingDetails;
  final double pendingRating;
  final TextEditingController commentController;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onConfirmRemove;

  const _NarrowDetails({
    required this.movie,
    required this.isSaved,
    required this.saved,
    required this.loadingDetails,
    required this.pendingRating,
    required this.commentController,
    required this.onRatingChanged,
    required this.onConfirmRemove,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 340,
          backgroundColor: AppColors.background,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'poster-${movie.id}',
                  child: Image.network(
                    movie.getFullBackdropUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceElevated),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.55),
                        AppColors.background,
                      ],
                      stops: const [0.3, 0.75, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: _DetailsBody(
              movie: movie,
              isSaved: isSaved,
              saved: saved,
              loadingDetails: loadingDetails,
              pendingRating: pendingRating,
              commentController: commentController,
              onRatingChanged: onRatingChanged,
              onConfirmRemove: onConfirmRemove,
            ),
          ),
        ),
      ],
    );
  }
}

// layout para desktop/web
class _WideDetails extends StatelessWidget {
  final Movie movie;
  final bool isSaved;
  final SavedMovie? saved;
  final bool loadingDetails;
  final double pendingRating;
  final TextEditingController commentController;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onConfirmRemove;

  const _WideDetails({
    required this.movie,
    required this.isSaved,
    required this.saved,
    required this.loadingDetails,
    required this.pendingRating,
    required this.commentController,
    required this.onRatingChanged,
    required this.onConfirmRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Hero(
                    tag: 'poster-${movie.id}',
                    child: Image.network(
                      movie.getFullPosterUrl(),
                      width: 320,
                      height: 480,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 320,
                        height: 480,
                        color: AppColors.surfaceElevated,
                        child: const Icon(Icons.movie_outlined, size: 48, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 36),
                Expanded(
                  child: SingleChildScrollView(
                    child: _DetailsBody(
                      movie: movie,
                      isSaved: isSaved,
                      saved: saved,
                      loadingDetails: loadingDetails,
                      pendingRating: pendingRating,
                      commentController: commentController,
                      onRatingChanged: onRatingChanged,
                      onConfirmRemove: onConfirmRemove,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final Movie movie;
  final bool isSaved;
  final SavedMovie? saved;
  final bool loadingDetails;
  final double pendingRating;
  final TextEditingController commentController;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onConfirmRemove;

  const _DetailsBody({
    required this.movie,
    required this.isSaved,
    required this.saved,
    required this.loadingDetails,
    required this.pendingRating,
    required this.commentController,
    required this.onRatingChanged,
    required this.onConfirmRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(movie.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _MetaChip(icon: Icons.star_rounded, label: movie.voteAverage.toStringAsFixed(1)),
            _MetaChip(icon: Icons.calendar_today_rounded, label: '${movie.releaseYear}'),
            _MetaChip(
              icon: Icons.timer_outlined,
              label: loadingDetails ? '…' : movie.durationLabel,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: movie.genres
              .map((g) => Chip(label: Text(g), visualDensity: VisualDensity.compact))
              .toList(),
        ),
        const SizedBox(height: 22),
        _AddToListButton(movie: movie, isSaved: isSaved),
        const SizedBox(height: 26),
        const Text('Sinopse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(movie.overview, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 22),
        const Text('Direção', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          loadingDetails
              ? 'Carregando…'
              : (movie.director.isEmpty ? 'Não informado' : movie.director),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        const Text('Elenco', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          loadingDetails
              ? 'Carregando…'
              : (movie.cast.isEmpty ? 'Não informado' : movie.cast.join(', ')),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        if (isSaved) ...[
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sua Avaliação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: onConfirmRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.primary),
                label: const Text('Remover', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Status atual: ${saved?.status ?? MovieStatus.toWatch}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          RatingStars(rating: pendingRating, size: 30, onChanged: onRatingChanged),
          const SizedBox(height: 14),
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Escreva um comentário pessoal…'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: pendingRating == 0
                  ? null
                  : () async {
                      await context.read<MyListProvider>().rateMovie(
                            movie,
                            pendingRating,
                            commentController.text.trim(),
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Avaliação salva! Status: Já Assisti.')),
                        );
                      }
                    },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Salvar Avaliação'),
            ),
          ),
        ],
      ],
    );
  }
}

class _AddToListButton extends StatelessWidget {
  final Movie movie;
  final bool isSaved;

  const _AddToListButton({required this.movie, required this.isSaved});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isSaved
          ? OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.bookmark_added_rounded, color: AppColors.success),
              label: const Text('Na Minha Lista', style: TextStyle(color: AppColors.success)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.success),
                disabledForegroundColor: AppColors.success,
              ),
            )
          : ElevatedButton.icon(
              onPressed: () async {
                await context.read<MyListProvider>().addMovieToList(movie);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${movie.title}" adicionado à Minha Lista.')),
                  );
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Adicionar à Minha Lista'),
            ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12.5)),
        ],
      ),
    );
  }
}
