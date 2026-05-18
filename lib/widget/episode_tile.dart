import 'package:flutter/material.dart';

import '../entity/episode.dart';
import '../util/utils_functions.dart';

class EpisodeTile extends StatelessWidget {
  final Episode episode;
  final bool isWatched;
  final VoidCallback onTap;

  const EpisodeTile({super.key, required this.episode, required this.isWatched, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('${episode.episodeNumber}. ${episode.name}'),
              content: SingleChildScrollView(child: Text(episode.overview ?? 'No overview available')),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
            );
          },
        );
      },
      title: Text(
        '${episode.episodeNumber}. ${episode.name}',
        style: TextStyle(fontWeight: FontWeight.bold, color: isWatched ? Colors.grey : null),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (episode.airDate != null) Text('Air Date: ${UtilsFunctions.formatDate(episode.airDate)}', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            episode.overview ?? 'No overview available',
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
