import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entity/tv_show.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../service/tv_service.dart';
import '../util/utils_functions.dart';
import '../widget/metadata_badge.dart';
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
      converter: (store) => (store.state.tvShows, (show) => store.dispatchAndWait(SaveTvShowAction(show))),
      builder: (context, viewData) {
        final (savedShows, onSaveShow) = viewData;
        final isSaved = savedShows.any((s) => s.id == widget.tvShowId);

        final seasons = _tvShow?.seasons?.where((s) => s.seasonNumber != 0).toList() ?? [];
        final specials = _tvShow?.seasons?.where((s) => s.seasonNumber == 0).toList() ?? [];

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
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tvShow?.name ?? '',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                clipBehavior: Clip.antiAlias,
                                child: TvShowPoster(tvShow: _tvShow, width: 110, height: 165),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 165,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      MetadataBadge(
                                        icon: Icons.star_rounded,
                                        label: 'Rating',
                                        value: _tvShow?.voteAverage != null ? '${_tvShow!.voteAverage!.toStringAsFixed(1)} / 10' : 'N/A',
                                      ),
                                      MetadataBadge(icon: Icons.info_outline, label: 'Status', value: _tvShow?.status ?? 'Unknown'),
                                      MetadataBadge(
                                        icon: Icons.calendar_today_outlined,
                                        label: 'First Air',
                                        value: UtilsFunctions.formatDate(_tvShow?.firstAirDate),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Icon(Icons.subject_rounded, size: 20, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(
                                'Overview',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tvShow?.overview ?? 'No overview available',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (seasons.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.tv_outlined, size: 20, color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 8),
                                Text(
                                  'Seasons',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  for (int i = 0; i < seasons.length; i++) ...[
                                    if (i > 0) Divider(),
                                    Padding(
                                      key: ValueKey(seasons[i].id ?? seasons[i].seasonNumber),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: SeasonTile(season: seasons[i]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          if (specials.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Icon(Icons.stars_outlined, size: 20, color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 8),
                                Text(
                                  'Specials',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  for (int i = 0; i < specials.length; i++) ...[
                                    if (i > 0) Divider(),
                                    Padding(
                                      key: ValueKey(specials[i].id ?? specials[i].seasonNumber),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: SeasonTile(season: specials[i]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 72),
                        ],
                      ),
                    ),
                    if (_isSaving)
                      Container(
                        color: Theme.of(context).colorScheme.surfaceContainerLowest.withValues(alpha: 0.5),
                        child: Center(
                          child: Card(
                            margin: const EdgeInsets.all(32),
                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text('Saving...', style: Theme.of(context).textTheme.titleMedium),
                                ],
                              ),
                            ),
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
