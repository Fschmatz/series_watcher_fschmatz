import 'package:flutter/material.dart';
import '../entity/season.dart';

class SeasonTile extends StatelessWidget {
  final Season season;

  const SeasonTile({super.key, required this.season});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(season.name ?? 'Season ${season.seasonNumber}'),
      subtitle: Text('${season.episodeCount ?? 0} Episodes'),
    );
  }
}
