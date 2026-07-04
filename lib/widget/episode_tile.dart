import 'package:flutter/material.dart';

import '../entity/episode.dart';
import '../util/utils_functions.dart';

class EpisodeTile extends StatelessWidget {
  final Episode episode;
  final bool isWatched;
  final VoidCallback onTap;

  const EpisodeTile({super.key, required this.episode, required this.isWatched, required this.onTap});

  void _showEpisodeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${episode.episodeNumber}. ${episode.name}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (episode.airDate != null || (episode.runtime != null && episode.runtime! > 0)) ...[
                  Row(
                    children: [
                      if (episode.airDate != null) ...[
                        Icon(Icons.calendar_today_outlined, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          UtilsFunctions.formatDate(episode.airDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        if (episode.runtime != null && episode.runtime! > 0) const SizedBox(width: 12),
                      ],
                      if (episode.runtime != null && episode.runtime! > 0) ...[
                        Icon(Icons.access_time_outlined, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          '${episode.runtime} min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Text(episode.overview!),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      onTap: () {
        if (episode.overview != null && episode.overview!.isNotEmpty) {
          _showEpisodeDetails(context);
        }
      },
      title: Text(
        '${episode.episodeNumber}. ${episode.name}',
        style: TextStyle(fontWeight: FontWeight.bold, color: isWatched ? Colors.grey : null),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (episode.airDate != null || (episode.runtime != null && episode.runtime! > 0)) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (episode.airDate != null) ...[
                  Icon(Icons.calendar_today_outlined, size: 14, color: isWatched ? Colors.grey : Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    UtilsFunctions.formatDate(episode.airDate),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: isWatched ? Colors.grey : Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (episode.runtime != null && episode.runtime! > 0) const SizedBox(width: 12),
                ],
                if (episode.runtime != null && episode.runtime! > 0) ...[
                  Icon(Icons.access_time_outlined, size: 14, color: isWatched ? Colors.grey : Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    '${episode.runtime} min',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: isWatched ? Colors.grey : Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(
            (episode.overview == null || episode.overview!.isEmpty) ? 'No overview available' : episode.overview!,
            style: TextStyle(color: isWatched ? Colors.grey : null),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          isWatched ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isWatched ? Colors.grey : Theme.of(context).colorScheme.primary,
        ),
        onPressed: onTap,
      ),
    );
  }
}
