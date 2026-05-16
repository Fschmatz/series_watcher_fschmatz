import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../util/app_constants.dart';
import 'tv_show_poster.dart';

class TvShowCardHome extends StatelessWidget {
  final TvShow tvShow;
  final VoidCallback? onTap;

  const TvShowCardHome({super.key, required this.tvShow, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppConstants.marginSeriesCards,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    if (tvShow.nextEpisodeInfo != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${tvShow.nextEpisodeInfo}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (tvShow.remainingEpisodes != null && tvShow.remainingEpisodes! > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          '${tvShow.remainingEpisodes} remaining',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
