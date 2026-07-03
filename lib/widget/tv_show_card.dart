import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../redux/actions.dart';
import '../util/app_constants.dart';
import '../util/toast_utils.dart';
import 'tv_show_poster.dart';

class TvShowCard extends StatefulWidget {
  final TvShow tvShow;
  final VoidCallback? onTap;
  final bool isFromArchive;
  final bool showNextEpisodeInfo;
  final bool showNextEpisodeDuration;
  final bool showRemainingEpisodes;
  final bool showSeriesStatus;

  const TvShowCard({
    super.key,
    required this.tvShow,
    this.onTap,
    this.isFromArchive = false,
    this.showNextEpisodeInfo = false,
    this.showNextEpisodeDuration = false,
    this.showRemainingEpisodes = false,
    this.showSeriesStatus = false,
  });

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
    final showNextEpisodeInfo = widget.showNextEpisodeInfo;
    final showNextEpisodeDuration = widget.showNextEpisodeDuration;
    final showRemainingEpisodes = widget.showRemainingEpisodes;
    final showSeriesStatus = widget.showSeriesStatus;

    int activeOptionsCount = 0;
    if (!widget.isFromArchive) {
      if (showNextEpisodeInfo) activeOptionsCount++;
      if (showNextEpisodeDuration) activeOptionsCount++;
      if (showRemainingEpisodes) activeOptionsCount++;
      if (showSeriesStatus) activeOptionsCount++;
    }

    double posterWidth = 95;
    double posterHeight = 135;

    if (widget.isFromArchive) {
      posterWidth = 68;
      posterHeight = 102;
    } else {
      if (activeOptionsCount == 0) {
        posterWidth = 68;
        posterHeight = 102;
      } else if (activeOptionsCount == 1) {
        posterWidth = 77;
        posterHeight = 113;
      } else if (activeOptionsCount == 2) {
        posterWidth = 86;
        posterHeight = 124;
      } else if (activeOptionsCount == 3) {
        posterWidth = 95;
        posterHeight = 135;
      } else {
        posterWidth = 105;
        posterHeight = 155;
      }
    }

    return Card(
      margin: AppConstants.marginSeriesCards,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showBottomSheet(context, tvShow),
        child: Row(
          children: [
            TvShowPoster(tvShow: tvShow, width: posterWidth, height: posterHeight),
            const SizedBox(width: 12),
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
                    if ((widget.isFromArchive || showSeriesStatus) && tvShow.status != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        tvShow.status!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (showNextEpisodeInfo && !widget.isFromArchive && tvShow.nextEpisodeInfo != null) ...[
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
                    if (showNextEpisodeDuration && !widget.isFromArchive && tvShow.nextEpisodeRuntime != null && tvShow.nextEpisodeRuntime! > 0) ...[
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
                    if (showRemainingEpisodes && tvShow.remainingEpisodes != null && tvShow.remainingEpisodes! > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.play_circle_outline_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${tvShow.remainingEpisodes} remaining',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
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
      showDragHandle: true,
      builder: (context) {
        final hasNextEpisode = tvShow.nextEpisodeInfo != null;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.check_outlined),
                          title: const Text('Mark next as watched'),
                          enabled: hasNextEpisode,
                          onTap: () {
                            if (tvShow.id != null) {
                              ToastUtils.show('Marked next episode as watched');
                              Navigator.pop(context);
                              context.dispatch(MarkNextEpisodeAsWatchedAction(tvShow.id!));
                            }
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(tvShow.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                          title: Text(tvShow.isArchived ? 'Unarchive series' : 'Archive series'),
                          onTap: () {
                            if (tvShow.id != null) {
                              final msg = tvShow.isArchived ? 'Series unarchived' : 'Series archived';
                              ToastUtils.show(msg);
                              Navigator.pop(context);
                              context.dispatch(ToggleArchiveTvShowAction(tvShow.id!, !tvShow.isArchived));
                            }
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.sync_rounded),
                          title: const Text('Sync series'),
                          onTap: () async {
                            Navigator.pop(context);
                            if (tvShow.id != null) {
                              ToastUtils.show('Syncing ${tvShow.name}...');

                              var status = await context.dispatchAndWait(SyncSingleTvShowAction(tvShow.id!));

                              if (status.isCompletedOk) {
                                ToastUtils.show('Sync completed');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
