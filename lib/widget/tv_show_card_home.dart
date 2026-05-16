import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import 'tv_show_poster.dart';

class TvShowCardHome extends StatelessWidget {
  final TvShow tvShow;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TvShowCardHome({super.key, required this.tvShow, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      clipBehavior: Clip.antiAlias, // Important for the poster to respect card radius
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            TvShowPoster(
              tvShow: tvShow,
              width: 90,
              height: 130, // Increased size slightly to look better touching borders
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 12), // Padding only for text
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tvShow.name ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tvShow.nextEpisodeInfo != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${tvShow.nextEpisodeInfo}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
