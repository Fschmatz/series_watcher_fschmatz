import 'package:flutter/material.dart';
import '../entity/season.dart';
import '../pages/season_details_page.dart';

class SeasonListTile extends StatelessWidget {
  final int tvShowId;
  final Season season;

  const SeasonListTile({
    super.key,
    required this.tvShowId,
    required this.season,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(season.name ?? 'Season ${season.seasonNumber}'),
      subtitle: Text('${season.episodeCount ?? 0} Episodes'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeasonDetailsPage(
              tvShowId: tvShowId,
              season: season,
            ),
          ),
        );
      },
    );
  }
}
