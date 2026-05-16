import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entity/season.dart';
import '../entity/tv_show.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../service/tv_service.dart';
import '../service/tv_show_local_service.dart';
import '../util/utils_functions.dart';
import '../widget/season_list_tile.dart';
import '../widget/tv_show_poster.dart';

class TvShowDetails extends StatefulWidget {
  final int tvShowId;

  const TvShowDetails({super.key, required this.tvShowId});

  @override
  State<TvShowDetails> createState() => _TvShowDetailsState();
}

class _TvShowDetailsState extends State<TvShowDetails> {
  TvShow? _tvShow;
  List<Season> _seasons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadDetails();
  }

  void _loadDetails() async {
    try {
      // 1. Try local DB first (Offline mode)
      final localDetails = await TvShowLocalService().getFullTvShow(widget.tvShowId);

      if (localDetails != null && localDetails.seasons != null && localDetails.seasons!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _tvShow = localDetails;
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Fallback to online API if not saved or incomplete
      final details = await TvService().getTvShowDetails(widget.tvShowId);
      if (mounted) {
        setState(() {
          _tvShow = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      Fluttertoast.showToast(msg: "Error loading details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, (List<TvShow>, void Function(TvShow), void Function(int), void Function(int, bool))>(
      converter: (store) => (
        store.state.tvShows,
        (show) => store.dispatch(SaveTvShowAction(show)),
        (id) => store.dispatch(RemoveTvShowAction(id)),
        (id, archive) => store.dispatch(ToggleArchiveTvShowAction(id, archive)),
      ),
      builder: (context, viewData) {
        final (savedShows, onSaveShow, onRemoveShow, onToggleArchive) = viewData;

        final tvShowLocal = savedShows.where((s) => s.id == widget.tvShowId).firstOrNull;
        final isSaved = tvShowLocal != null;
        final isArchived = tvShowLocal?.isArchived ?? false;

        return Scaffold(
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: const Text('Series Details'),
                      pinned: true,
                      actions: [
                        if (isSaved) ...[
                          IconButton(
                            icon: Icon(isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                            onPressed: () {
                              onToggleArchive(widget.tvShowId, !isArchived);
                              Fluttertoast.showToast(msg: isArchived ? "Restored from archive" : "Added to archive");
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remove Series'),
                                  content: const Text('Are you sure you want to remove this series from your watchlist? All progress will be lost.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close dialog
                                        onRemoveShow(widget.tvShowId);
                                        Navigator.pop(this.context); // Exit details page
                                        Fluttertoast.showToast(msg: "Removed from watchlist");
                                      },
                                      child: const Text('REMOVE', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_tvShow?.name ?? '', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: TvShowPoster(tvShow: _tvShow, width: 120),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Rating: ${_tvShow?.voteAverage?.toStringAsFixed(1)}', style: Theme.of(context).textTheme.titleMedium),
                                      Text('Status: ${_tvShow?.status ?? ''}'),
                                      Text('First Air: ${UtilsFunctions.formatDate(_tvShow?.firstAirDate)}'),
                                      Text('Seasons: ${_tvShow?.numberOfSeasons ?? ''}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text('Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(_tvShow?.overview ?? 'No overview available'),
                            const SizedBox(height: 24),
                            if (_tvShow?.seasons != null && _tvShow!.seasons!.isNotEmpty) ...[
                              Text('Seasons', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Column(
                                children: _tvShow!.seasons!.where((s) => s.seasonNumber != 0).map((season) {
                                  return SeasonListTile(tvShowId: widget.tvShowId, season: season);
                                }).toList(),
                              ),
                              if (_tvShow!.seasons!.any((s) => s.seasonNumber == 0)) ...[
                                const SizedBox(height: 24),
                                Text('Specials', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Column(
                                  children: _tvShow!.seasons!.where((s) => s.seasonNumber == 0).map((season) {
                                    return SeasonListTile(tvShowId: widget.tvShowId, season: season);
                                  }).toList(),
                                ),
                              ],
                            ] else if (!_isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: Text("No seasons found.")),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
