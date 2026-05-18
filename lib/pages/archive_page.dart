import 'package:animations/animations.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../redux/app_state.dart';
import '../redux/selectors.dart';
import '../widget/tv_show_card.dart';
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
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.archive_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Your Archive is Empty',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Archived series will show up here to keep your active watchlist organized.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        key: const ValueKey('list_layout'),
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    archivedShows.length == 1
                                        ? '1 series archived'
                                        : '${archivedShows.length} series archived',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              key: const ValueKey('list'),
                              itemCount: archivedShows.length,
                              padding: const EdgeInsets.only(bottom: 16),
                              itemBuilder: (context, index) {
                                final tvShow = archivedShows[index];
                                return TvShowCard(
                                  key: ValueKey(tvShow.id),
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
                        ],
                      ),
          ),
        );
      },
    );
  }
}
