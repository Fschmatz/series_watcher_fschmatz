import 'package:animations/animations.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../pages/archive_page.dart';
import '../pages/search_page.dart';
import '../redux/app_state.dart';
import '../redux/selectors.dart';
import '../util/app_constants.dart';
import '../widget/tv_show_card_home.dart';
import 'settings.dart';
import 'tv_show_details.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, (List<TvShow>, bool)>(
      converter: (store) => (
        selectActiveTvShows(),
        store.state.isLoadingShows,
      ),
      builder: (context, viewData) {
        final (tvShows, isLoading) = viewData;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppConstants.appNameHomePage),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.archive_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ArchivePage()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()));
                },
              ),
            ],
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
                : tvShows.isEmpty
                    ? const Center(key: ValueKey('empty'), child: Text('No series saved yet'))
                    : ListView.builder(
                        key: const ValueKey('list'),
                        itemCount: tvShows.length,
                        itemBuilder: (context, index) {
                          final tvShow = tvShows[index];
                          return TvShowCardHome(
                            key: ValueKey(tvShow.id),
                            tvShow: tvShow,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowDetails(tvShowId: tvShow.id!)));
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
