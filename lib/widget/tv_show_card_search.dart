import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../util/app_constants.dart';
import '../util/utils_functions.dart';
import 'tv_show_poster.dart';

class TvShowCardSearch extends StatelessWidget {
  final TvShow tvShow;
  final VoidCallback? onTap;

  const TvShowCardSearch({super.key, required this.tvShow, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppConstants.marginSeriesCards,
      clipBehavior: Clip.antiAlias,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Start: ${UtilsFunctions.formatDate(tvShow.firstAirDate)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          tvShow.voteAverage?.toStringAsFixed(1) ?? '0.0',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
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
