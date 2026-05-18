import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../util/app_constants.dart';
import 'tv_show_poster.dart';

class TvShowCard extends StatefulWidget {
  final TvShow tvShow;
  final VoidCallback? onTap;

  const TvShowCard({super.key, required this.tvShow, this.onTap});

  @override
  State<TvShowCard> createState() => _TvShowCardState();
}

class _TvShowCardState extends State<TvShowCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tvShow = widget.tvShow;
    final onTap = widget.onTap;

    return Card(
      margin: AppConstants.marginSeriesCards,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            TvShowPoster(tvShow: tvShow, width: 95, height: 135),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tvShow.name ?? 'Unknown',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (tvShow.voteAverage != null && tvShow.voteAverage! > 0) ...[
                          Icon(Icons.star_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            tvShow.voteAverage!.toStringAsFixed(1),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (tvShow.status != null)
                          Text(
                            tvShow.status!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                    if (tvShow.nextEpisodeInfo != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.upcoming_outlined, size: 14, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tvShow.nextEpisodeInfo!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (tvShow.remainingEpisodes != null && tvShow.remainingEpisodes! > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_outline_rounded, size: 12, color: Theme.of(context).colorScheme.onPrimaryContainer),
                            const SizedBox(width: 6),
                            Text(
                              '${tvShow.remainingEpisodes} remaining',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
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
