import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entity/tv_show.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../service/tv_service.dart';
import '../util/utils_functions.dart';
import '../widget/season_tile.dart';
import '../widget/tv_show_poster.dart';

class TvShowDetailsSearch extends StatefulWidget {
  final int tvShowId;

  const TvShowDetailsSearch({super.key, required this.tvShowId});

  @override
  State<TvShowDetailsSearch> createState() => _TvShowDetailsSearchState();
}

class _TvShowDetailsSearchState extends State<TvShowDetailsSearch> {
  TvShow? _tvShow;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    try {
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
    return StoreConnector<AppState, (List<TvShow>, Future<void> Function(TvShow))>(
      converter: (store) => (
        store.state.tvShows,
        (show) => store.dispatchAndWait(SaveTvShowAction(show)),
      ),
      builder: (context, viewData) {
        final (savedShows, onSaveShow) = viewData;
        final isSaved = savedShows.any((s) => s.id == widget.tvShowId);

        return Scaffold(
          appBar: AppBar(title: const Text('Preview')),
          floatingActionButton: (!isSaved && _tvShow != null && !_isSaving)
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    setState(() {
                      _isSaving = true;
                    });
                    try {
                      await onSaveShow(_tvShow!);
                      Fluttertoast.showToast(msg: "Added to watchlist!");
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      Fluttertoast.showToast(msg: "Error saving show: $e");
                      if (mounted) {
                        setState(() {
                          _isSaving = false;
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Save Show"),
                )
              : null,
          body: (_isLoading || _isSaving)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      if (_isSaving) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Saving show details...',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ],
                  ),
                )
              : SingleChildScrollView(
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
                        Column(children: _tvShow!.seasons!.where((s) => s.seasonNumber != 0).map((season) => SeasonTile(season: season)).toList()),
                        if (_tvShow!.seasons!.any((s) => s.seasonNumber == 0)) ...[
                          const SizedBox(height: 24),
                          Text('Specials', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Column(children: _tvShow!.seasons!.where((s) => s.seasonNumber == 0).map((season) => SeasonTile(season: season)).toList()),
                        ],
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}
