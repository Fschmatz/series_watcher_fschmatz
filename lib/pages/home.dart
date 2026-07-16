import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../pages/archive_page.dart';
import '../pages/search_page.dart';
import '../redux/app_state.dart';
import '../redux/selectors.dart';
import '../util/app_constants.dart';
import '../widget/tv_show_card.dart';
import 'history_page.dart';
import 'settings.dart';
import 'tv_show_details.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final tvShows = context.select(selectActiveTvShows);
    final isLoading = context.select((state) => state.isLoadingShows);
    final showNextEpisodeInfo = context.select((state) => selectParameterValueByKeyAsBoolean(state, AppConstants.showNextEpisodeNameAppParameter));
    final showNextEpisodeDuration = context.select(
      (state) => selectParameterValueByKeyAsBoolean(state, AppConstants.showNextEpisodeDurationAppParameter),
    );
    final showRemainingEpisodes = context.select(
      (state) => selectParameterValueByKeyAsBoolean(state, AppConstants.showRemainingEpisodesAppParameter),
    );
    final showSeriesStatus = context.select(
      (state) => selectParameterValueByKeyAsBoolean(state, AppConstants.showSeriesStatusAppParameter, defaultValue: false),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appNameHomePage),
        actions: [
          /*  IconButton(
                icon: const Icon(Icons.search_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                },
              ), */
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert_outlined),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              PopupMenuItem<int>(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.add_outlined, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    const Text('Add'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    const Text('Archive'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    const Text('History'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    const Text('Settings'),
                  ],
                ),
              ),
            ],
            onSelected: (int value) {
              switch (value) {
                case 0:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ArchivePage()));
                  break;
                case 1:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
                  break;
                case 2:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()));
                  break;
                case 3:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                  break;
              }
            },
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(fillColor: Colors.transparent, animation: animation, secondaryAnimation: secondaryAnimation, child: child);
        },
        child: isLoading
            ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
            : tvShows.isEmpty
            ? const Center(key: ValueKey('empty'), child: Text('No series saved yet'))
            : ListView.builder(
                key: const ValueKey('list'),
                itemCount: tvShows.length,
                itemBuilder: (context, index) {
                  final tvShow = tvShows[index];

                  return TvShowCard(
                    key: ValueKey(tvShow.id),
                    tvShow: tvShow,
                    showNextEpisodeInfo: showNextEpisodeInfo,
                    showNextEpisodeDuration: showNextEpisodeDuration,
                    showRemainingEpisodes: showRemainingEpisodes,
                    showSeriesStatus: showSeriesStatus,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowDetails(tvShowId: tvShow.id!)));
                    },
                  );
                },
              ),
      ),
    );
  }
}
