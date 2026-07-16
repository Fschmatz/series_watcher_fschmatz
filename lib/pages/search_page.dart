import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../entity/tv_show.dart';
import '../redux/app_state.dart';
import '../service/tv_service.dart';
import '../util/toast_utils.dart';
import '../widget/tv_show_card_search.dart';
import 'tv_show_details_search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<TvShow> _results = [];
  bool _isLoading = false;
  bool _isSearching = false;

  late TabController _tabController;
  List<TvShow> _trending = [];
  List<TvShow> _onTheAir = [];
  List<TvShow> _popular = [];
  List<TvShow> _topRated = [];
  bool _isTrendingLoading = true;
  bool _isOnTheAirLoading = true;
  bool _isPopularLoading = true;
  bool _isTopRatedLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDiscoveryData();
    _searchController.addListener(() {
      setState(() {
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadDiscoveryData() async {
    try {
      final trending = await TvService().getTrendingTvShows();
      if (mounted) {
        setState(() {
          _trending = trending;
          _isTrendingLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isTrendingLoading = false);
    }

    try {
      final onTheAir = await TvService().getOnTheAirTvShows();
      if (mounted) {
        setState(() {
          _onTheAir = onTheAir;
          _isOnTheAirLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isOnTheAirLoading = false);
    }

    try {
      final popular = await TvService().getPopularTvShows();
      if (mounted) {
        setState(() {
          _popular = popular;
          _isPopularLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isPopularLoading = false);
    }

    try {
      final topRated = await TvService().getTopRatedTvShows();
      if (mounted) {
        setState(() {
          _topRated = topRated;
          _isTopRatedLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isTopRatedLoading = false);
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
      ToastUtils.showErrorMessage('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedTvShows = context.select((AppState state) => state.tvShows);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SearchBar(
                controller: _searchController,
                autoFocus: false,
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                hintText: 'Search series...',
                onSubmitted: _search,
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHigh),
                trailing: [
                  if (_isSearching)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _results = [];
                          _isSearching = false;
                        });
                      },
                    )
                  else
                    IconButton(icon: const Icon(Icons.search), onPressed: () => _search(_searchController.text)),
                ],
              ),
            ),
            Expanded(
              child: PageTransitionSwitcher(
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
                                  isSaved: savedTvShows.any((savedShow) => savedShow.id == tvShow.id),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowDetailsSearch(tvShowId: tvShow.id!)));
                                  },
                                );
                              },
                            )
                    : Column(
                        key: const ValueKey('discovery_view'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            dividerColor: Colors.transparent,
                            onTap: (index) {
                              setState(() {});
                            },
                            tabs: const [
                              Tab(text: "Trending"),
                              Tab(text: "On The Air"),
                              Tab(text: "Popular"),
                              Tab(text: "Top Rated"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                List<TvShow> currentList;
                                bool isLoading;

                                if (_tabController.index == 0) {
                                  currentList = _trending;
                                  isLoading = _isTrendingLoading;
                                } else if (_tabController.index == 1) {
                                  currentList = _onTheAir;
                                  isLoading = _isOnTheAirLoading;
                                } else if (_tabController.index == 2) {
                                  currentList = _popular;
                                  isLoading = _isPopularLoading;
                                } else {
                                  currentList = _topRated;
                                  isLoading = _isTopRatedLoading;
                                }

                                if (isLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (currentList.isEmpty) {
                                  return const Center(child: Text('Could not load series'));
                                }

                                return ListView.builder(
                                  itemCount: currentList.length,
                                  itemBuilder: (context, index) {
                                    final tvShow = currentList[index];
                                    return TvShowCardSearch(
                                      key: ValueKey(tvShow.id),
                                      tvShow: tvShow,
                                      isSaved: savedTvShows.any((savedShow) => savedShow.id == tvShow.id),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowDetailsSearch(tvShowId: tvShow.id!)));
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
