import 'package:animations/animations.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../entity/episode.dart';
import '../entity/season.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../widget/episode_tile.dart';
import '../widget/watching_progress_card.dart';

class SeasonDetailsPage extends StatefulWidget {
  final int tvShowId;
  final Season season;

  const SeasonDetailsPage({super.key, required this.tvShowId, required this.season});

  @override
  State<SeasonDetailsPage> createState() => _SeasonDetailsPageState();
}

class _SeasonDetailsPageState extends State<SeasonDetailsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final episodes = widget.season.episodes ?? [];

    return StoreConnector<AppState, (List<int>, Future<void> Function(Episode, bool), Future<void> Function())>(
      converter: (store) => (
        store.state.watchedEpisodeIds,
        (episode, watched) => store.dispatchAndWait(ToggleEpisodeWatchedAction(widget.tvShowId, episode, watched)),
        () => store.dispatchAndWait(MarkSeasonAsWatchedAction(widget.tvShowId, episodes)),
      ),
      builder: (context, viewData) {
        final (watchedIds, onToggleWatched, onMarkAllWatched) = viewData;

        final watchedCount = episodes.where((e) => watchedIds.contains(e.id)).length;
        final totalCount = episodes.length;
        final progress = totalCount > 0 ? watchedCount / totalCount : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.season.name ?? 'Season ${widget.season.seasonNumber}'),
            actions: [
              if (episodes.isNotEmpty && !_isLoading)
                IconButton(
                  icon: const Icon(Icons.done_all_outlined),
                  tooltip: 'Mark all as watched',
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await onMarkAllWatched();
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                ),
            ],
          ),
          body: Stack(
            children: [
              PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation, secondaryAnimation) {
                  return FadeThroughTransition(animation: animation, secondaryAnimation: secondaryAnimation, child: child);
                },
                child: episodes.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLow, shape: BoxShape.circle),
                                child: Icon(Icons.movie_filter_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No Episodes Found',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        key: const ValueKey('list_layout'),
                        child: Column(
                          children: [
                            WatchingProgressCard(watchedCount: watchedCount, totalCount: totalCount, progress: progress),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              clipBehavior: Clip.antiAlias,
                              child: ListView.separated(
                                key: const ValueKey('list'),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: episodes.length,
                                separatorBuilder: (context, index) => Divider(color: Theme.of(context).colorScheme.surfaceContainerLow, height: 1),
                                itemBuilder: (context, index) {
                                  final episode = episodes[index];
                                  final isWatched = watchedIds.contains(episode.id);

                                  return EpisodeTile(
                                    key: ValueKey(episode.id),
                                    episode: episode,
                                    isWatched: isWatched,
                                    onTap: _isLoading
                                        ? () {}
                                        : () async {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            try {
                                              await onToggleWatched(episode, !isWatched);
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              }
                                            }
                                          },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              if (_isLoading)
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}
