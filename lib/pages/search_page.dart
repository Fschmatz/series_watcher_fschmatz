import 'package:animations/animations.dart';
import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../service/tv_service.dart';
import '../widget/tv_show_card_search.dart';
import 'tv_show_details_search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<TvShow> _results = [];
  List<TvShow> _trending = [];
  bool _isLoading = false;
  bool _isTrendingLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTrending();
    _searchController.addListener(() {
      setState(() {
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTrending() async {
    try {
      final trending = await TvService().getTrendingTvShows();
      if (mounted) {
        setState(() {
          _trending = trending;
          _isTrendingLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTrendingLoading = false);
      }
    }
  }

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await TvService().searchTvShows(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, (List<TvShow>, void Function(TvShow))>(
      converter: (store) => (store.state.tvShows, (show) => store.dispatch(SaveTvShowAction(show))),
      builder: (context, viewData) {
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search series...',
                border: InputBorder.none,
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: _search,
            ),
            actions: [IconButton(icon: const Icon(Icons.search), onPressed: () => _search(_searchController.text))],
          ),
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation, secondaryAnimation) {
              return FadeThroughTransition(
                fillColor: Colors.transparent,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: _isSearching
                ? _isLoading
                      ? const Center(key: ValueKey('loading_search'), child: CircularProgressIndicator())
                      : _results.isEmpty
                      ? const Center(key: ValueKey('no_results'), child: Text('No results found'))
                      : ListView.builder(
                          key: const ValueKey('results_list'),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final tvShow = _results[index];
                            return TvShowCardSearch(
                              key: ValueKey(tvShow.id),
                              tvShow: tvShow,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowDetailsSearch(tvShowId: tvShow.id!)));
                              },
                            );
                          },
                        )
                : _isTrendingLoading
                ? const Center(key: ValueKey('loading_trending'), child: CircularProgressIndicator())
                : Column(
                    key: const ValueKey('trending_view'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text('Trending', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: _trending.isEmpty
                            ? const Center(child: Text('Could not load trending shows'))
                            : ListView.builder(
                                key: const ValueKey('trending_list'),
                                itemCount: _trending.length,
                                itemBuilder: (context, index) {
                                  final tvShow = _trending[index];
                                  return TvShowCardSearch(
                                    key: ValueKey(tvShow.id),
                                    tvShow: tvShow,
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowDetailsSearch(tvShowId: tvShow.id!)));
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
