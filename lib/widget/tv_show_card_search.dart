import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../util/utils_functions.dart';
import 'tv_show_poster.dart';

class TvShowCardSearch extends StatelessWidget {
  final TvShow tvShow;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TvShowCardSearch({super.key, required this.tvShow, this.onTap, this.trailing});

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
            TvShowPoster(tvShow: tvShow, width: 90, height: 135),
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
                    const SizedBox(height: 4),
                    Text(
                      'Start: ${UtilsFunctions.formatDate(tvShow.firstAirDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          tvShow.voteAverage?.toStringAsFixed(1) ?? '0.0',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
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
