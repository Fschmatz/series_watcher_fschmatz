import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import 'tv_show_poster.dart';

class TvShowCardArchive extends StatelessWidget {
  final TvShow tvShow;
  final VoidCallback? onTap;

  const TvShowCardArchive({super.key, required this.tvShow, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            TvShowPoster(tvShow: tvShow, width: 90, height: 130),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tvShow.name ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Archived',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
