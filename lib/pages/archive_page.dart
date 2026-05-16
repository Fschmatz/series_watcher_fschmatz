import 'package:animations/animations.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../redux/app_state.dart';
import '../redux/selectors.dart';
import '../widget/tv_show_card_archive.dart';
import 'tv_show_details.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, (List<TvShow>, bool)>(
      converter: (store) => (
        selectArchivedTvShows(),
        store.state.isLoadingShows,
      ),
      builder: (context, viewData) {
        final (archivedShows, isLoading) = viewData;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Archive'),
          ),
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: isLoading
                ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
                : archivedShows.isEmpty
                    ? const Center(key: ValueKey('empty'), child: Text('No archived series'))
                    : ListView.builder(
                        key: const ValueKey('list'),
                        itemCount: archivedShows.length,
                        itemBuilder: (context, index) {
                          final tvShow = archivedShows[index];
                          return TvShowCardArchive(
                            tvShow: tvShow,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TvShowDetails(tvShowId: tvShow.id!),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}
