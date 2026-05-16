import 'package:animations/animations.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../entity/episode.dart';
import '../entity/season.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../util/utils_functions.dart';

class SeasonDetailsPage extends StatelessWidget {
  final int tvShowId;
  final Season season;

  const SeasonDetailsPage({super.key, required this.tvShowId, required this.season});

  @override
  Widget build(BuildContext context) {
    final episodes = season.episodes ?? [];

    return StoreConnector<AppState, (List<int>, void Function(Episode, bool), void Function())>(
      converter: (store) => (
        store.state.watchedEpisodeIds,
        (episode, watched) => store.dispatch(ToggleEpisodeWatchedAction(tvShowId, episode, watched)),
        () => store.dispatch(MarkSeasonAsWatchedAction(tvShowId, episodes)),
      ),
      builder: (context, viewData) {
        final (watchedIds, onToggleWatched, onMarkAllWatched) = viewData;

        return Scaffold(
          appBar: AppBar(
            title: Text(season.name ?? 'Season ${season.seasonNumber}'),
            actions: [
              if (episodes.isNotEmpty)
                IconButton(icon: const Icon(Icons.done_all_outlined), tooltip: 'Mark all as watched', onPressed: onMarkAllWatched),
            ],
          ),
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation, secondaryAnimation) {
              return FadeThroughTransition(animation: animation, secondaryAnimation: secondaryAnimation, child: child);
            },
            child: episodes.isEmpty
                ? const Center(key: ValueKey('empty'), child: Text('No episodes found'))
                : ListView.separated(
                    key: const ValueKey('list'),
                    padding: const EdgeInsets.all(16),
                    itemCount: episodes.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final episode = episodes[index];
                      final isWatched = watchedIds.contains(episode.id);

                      return ListTile(
                        key: ValueKey(episode.id),
                        contentPadding: EdgeInsets.zero,
                        onTap: () => onToggleWatched(episode, !isWatched),
                        leading: Icon(isWatched ? Icons.check_circle : Icons.radio_button_unchecked),
                        title: Text(
                          '${episode.episodeNumber}. ${episode.name}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isWatched ? Colors.grey : null),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (episode.airDate != null)
                              Text('Air Date: ${UtilsFunctions.formatDate(episode.airDate)}', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(episode.overview ?? 'No overview available', style: TextStyle(color: isWatched ? Colors.grey : null)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
