import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entity/tv_show.dart';
import '../redux/actions.dart';
import '../util/app_constants.dart';
import 'tv_show_poster.dart';

class TvShowCard extends StatefulWidget {
  final TvShow tvShow;
  final VoidCallback? onTap;
  final bool isFromArchive;

  const TvShowCard({super.key, required this.tvShow, this.onTap, this.isFromArchive = false});

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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showBottomSheet(context, tvShow),
        child: Row(
          children: [
            TvShowPoster(tvShow: tvShow, width: widget.isFromArchive ? 68 : 95, height: widget.isFromArchive ? 102 : 135),
            const SizedBox(width: 10),
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
                    if (widget.isFromArchive && tvShow.status != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        tvShow.status!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (!widget.isFromArchive && tvShow.nextEpisodeInfo != null) ...[
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
                    if (!widget.isFromArchive && tvShow.nextEpisodeRuntime != null && tvShow.nextEpisodeRuntime! > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${tvShow.nextEpisodeRuntime} min',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                    if (tvShow.remainingEpisodes != null && tvShow.remainingEpisodes! > 0) ...[
                      const SizedBox(height: 8),
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

  void _showBottomSheet(BuildContext context, TvShow tvShow) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      builder: (context) {
        final hasNextEpisode = tvShow.nextEpisodeInfo != null;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(tvShow.name ?? 'Series Options', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                if (hasNextEpisode) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Next: ${tvShow.nextEpisodeInfo}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline_rounded),
                  title: const Text('Mark next as watched'),
                  enabled: hasNextEpisode,
                  onTap: () {
                    Navigator.pop(context);
                    if (tvShow.id != null) {
                      StoreProvider.dispatch(context, MarkNextEpisodeAsWatchedAction(tvShow.id!));
                      Fluttertoast.showToast(msg: "Marked next episode as watched");
                    }
                  },
                ),
                ListTile(
                  leading: Icon(tvShow.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                  title: Text(tvShow.isArchived ? 'Unarchive series' : 'Archive series'),
                  onTap: () {
                    Navigator.pop(context);
                    if (tvShow.id != null) {
                      StoreProvider.dispatch(context, ToggleArchiveTvShowAction(tvShow.id!, !tvShow.isArchived));
                      Fluttertoast.showToast(msg: tvShow.isArchived ? "Series unarchived" : "Series archived");
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sync_rounded),
                  title: const Text('Sync series'),
                  onTap: () {
                    Navigator.pop(context);
                    if (tvShow.id != null) {
                      Fluttertoast.showToast(msg: "Syncing ${tvShow.name}...");
                      StoreProvider.dispatch(context, SyncSingleTvShowAction(tvShow.id!));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
