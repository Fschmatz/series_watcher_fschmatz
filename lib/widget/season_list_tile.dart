import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../entity/season.dart';
import '../pages/season_details_page.dart';
import '../redux/app_state.dart';

class SeasonListTile extends StatelessWidget {
  final int tvShowId;
  final Season season;

  const SeasonListTile({super.key, required this.tvShowId, required this.season});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<int>>(
      converter: (store) => store.state.watchedEpisodeIds,
      builder: (context, watchedIds) {
        final episodes = season.episodes ?? [];
        final watchedCount = episodes.where((e) => watchedIds.contains(e.id)).length;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(season.name ?? 'Season ${season.seasonNumber}'),
          subtitle: Text('Watched: $watchedCount / ${season.episodeCount ?? 0}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeasonDetailsPage(tvShowId: tvShowId, season: season),
              ),
            );
          },
        );
      },
    );
  }
}
