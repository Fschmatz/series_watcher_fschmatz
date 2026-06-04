import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entity/episode.dart';
import '../entity/tv_show.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../service/tv_service.dart';
import '../service/tv_show_local_service.dart';
import '../util/utils_functions.dart';
import '../widget/metadata_badge.dart';
import '../widget/season_list_tile.dart';
import '../widget/tv_show_poster.dart';
import '../widget/watching_progress_card.dart';

class TvShowDetails extends StatefulWidget {
  final int tvShowId;

  const TvShowDetails({super.key, required this.tvShowId});

  @override
  State<TvShowDetails> createState() => _TvShowDetailsState();
}

class _TvShowDetailsState extends State<TvShowDetails> {
  TvShow? _tvShow;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadDetails();
  }

  void _loadDetails() async {
    try {
      final localDetails = await TvShowLocalService().getFullTvShow(widget.tvShowId);

      if (localDetails != null && localDetails.seasons != null && localDetails.seasons!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _tvShow = localDetails;
            _isLoading = false;
          });
        }
        return;
      }

      final details = await TvService().getTvShowDetails(widget.tvShowId);
      if (mounted) {
        setState(() {
          _tvShow = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      Fluttertoast.showToast(msg: "Error loading details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<
      AppState,
      (
        List<TvShow>,
        List<int>,
        void Function(TvShow),
        void Function(int),
        void Function(int, bool),
        void Function(Episode, bool),
        void Function(int, bool),
      )
    >(
      converter: (store) => (
        store.state.tvShows,
        store.state.watchedEpisodeIds,
        (show) => store.dispatch(SaveTvShowAction(show)),
        (id) => store.dispatch(RemoveTvShowAction(id)),
        (id, archive) => store.dispatch(ToggleArchiveTvShowAction(id, archive)),
        (episode, watched) => store.dispatch(ToggleEpisodeWatchedAction(widget.tvShowId, episode, watched)),
        (id, showInWidget) => store.dispatch(ToggleShowInWidgetAction(id, showInWidget)),
      ),
      builder: (context, viewData) {
        final (savedShows, watchedIds, onSaveShow, onRemoveShow, onToggleArchive, onToggleEpisodeWatched, onToggleWidget) = viewData;

        final tvShowLocal = savedShows.where((s) => s.id == widget.tvShowId).firstOrNull;
        final isSaved = tvShowLocal != null;
        final isArchived = tvShowLocal?.isArchived ?? false;

        final seasons = _tvShow?.seasons?.where((s) => s.seasonNumber != 0).toList() ?? [];
        final specials = _tvShow?.seasons?.where((s) => s.seasonNumber == 0).toList() ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Details'),
            actions: [
              if (isSaved) ...[
                if (!isArchived)
                  IconButton(
                    icon: Icon(tvShowLocal.showInWidget == true ? Icons.dashboard_customize : Icons.dashboard_customize_outlined),
                    tooltip: tvShowLocal.showInWidget == true ? 'Remove from Widget' : 'Add to Widget',
                    onPressed: () {
                      final newValue = !(tvShowLocal.showInWidget);
                      onToggleWidget(widget.tvShowId, newValue);
                      Fluttertoast.showToast(msg: newValue ? "Added to Widget" : "Removed from Widget");
                    },
                  ),
                IconButton(
                  icon: Icon(isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                  onPressed: () {
                    onToggleArchive(widget.tvShowId, !isArchived);
                    Fluttertoast.showToast(msg: isArchived ? "Restored from archive" : "Added to archive");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove Series'),
                        content: const Text('Are you sure you want to remove this series from your watchlist? All progress will be lost.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onRemoveShow(widget.tvShowId);
                              Navigator.pop(this.context);
                              Fluttertoast.showToast(msg: "Removed from watchlist");
                            },
                            child: const Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tvShow?.name ?? '',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: TvShowPoster(tvShow: _tvShow, width: 110, height: 165),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 165,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  MetadataBadge(
                                    icon: Icons.star_rounded,
                                    label: 'Rating',
                                    value: _tvShow?.voteAverage != null ? '${_tvShow!.voteAverage!.toStringAsFixed(1)} / 10' : 'N/A',
                                  ),
                                  MetadataBadge(icon: Icons.info_outline, label: 'Status', value: _tvShow?.status ?? 'Unknown'),
                                  MetadataBadge(
                                    icon: Icons.calendar_today_outlined,
                                    label: 'First Air',
                                    value: UtilsFunctions.formatDate(_tvShow?.firstAirDate),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.subject_rounded, size: 20, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Overview',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tvShow?.overview ?? 'No overview available',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.percent_outlined, size: 20, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Progress',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ],
                      ),
                      if (isSaved && _tvShow?.seasons != null && _tvShow!.seasons!.isNotEmpty) ...[
                        (() {
                          final nonSpecialsSeasons = _tvShow!.seasons!.where((s) => s.seasonNumber != 0).toList();
                          final allEpisodes = nonSpecialsSeasons.expand((s) => s.episodes ?? <Episode>[]).toList();
                          final watchedCount = allEpisodes.where((e) => watchedIds.contains(e.id)).length;
                          final totalCount = allEpisodes.length;
                          final progress = totalCount > 0 ? watchedCount / totalCount : 0.0;

                          if (totalCount == 0) return const SizedBox.shrink();

                          Episode? nextEpisode;
                          nonSpecialsSeasons.sort((a, b) => (a.seasonNumber ?? 0).compareTo(b.seasonNumber ?? 0));
                          for (var season in nonSpecialsSeasons) {
                            if (season.episodes == null) continue;
                            final sortedEpisodes = List<Episode>.from(season.episodes!);
                            sortedEpisodes.sort((a, b) => (a.episodeNumber ?? 0).compareTo(b.episodeNumber ?? 0));
                            for (var episode in sortedEpisodes) {
                              if (!watchedIds.contains(episode.id)) {
                                nextEpisode = episode;
                                break;
                              }
                            }
                            if (nextEpisode != null) break;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              WatchingProgressCard(watchedCount: watchedCount, totalCount: totalCount, progress: progress, margin: EdgeInsets.zero),
                              if (nextEpisode != null) ...[
                                const SizedBox(height: 16),
                                Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Next to Watch',
                                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'S${nextEpisode.seasonNumber.toString().padLeft(2, '0')}E${nextEpisode.episodeNumber.toString().padLeft(2, '0')} - ${nextEpisode.name}',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  if (nextEpisode.runtime != null && nextEpisode.runtime! > 0) ...[
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.access_time_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${nextEpisode.runtime} min',
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: Theme.of(context).colorScheme.primary,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  if (nextEpisode.overview != null && nextEpisode.overview!.isNotEmpty) ...[
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      nextEpisode.overview!,
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton.tonalIcon(
                                            style: FilledButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            onPressed: () {
                                              onToggleEpisodeWatched(nextEpisode!, true);
                                              Fluttertoast.showToast(
                                                msg: "Marked S${nextEpisode.seasonNumber}E${nextEpisode.episodeNumber} as watched",
                                              );
                                            },
                                            icon: const Icon(Icons.check_outlined, size: 18),
                                            label: const Text('Mark as Watched'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                            ],
                          );
                        })(),
                      ],
                      if (seasons.isNotEmpty) ...[
                        if (!isSaved) const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(Icons.tv_outlined, size: 20, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              'Seasons',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (int i = 0; i < seasons.length; i++) ...[
                                if (i > 0) Divider(),
                                SeasonListTile(
                                  key: ValueKey(seasons[i].id ?? seasons[i].seasonNumber),
                                  tvShowId: widget.tvShowId,
                                  season: seasons[i],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (specials.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(Icons.stars_outlined, size: 20, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              'Specials',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (int i = 0; i < specials.length; i++) ...[
                                if (i > 0) Divider(),
                                SeasonListTile(
                                  key: ValueKey(specials[i].id ?? specials[i].seasonNumber),
                                  tvShowId: widget.tvShowId,
                                  season: specials[i],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (_tvShow != null && seasons.isEmpty && specials.isEmpty && !_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text("No seasons found.", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
