import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';

import '../entity/app_parameter.dart';
import '../entity/tv_show.dart';

class AppState {
  final List<AppParameter> appParameters;
  final List<TvShow> tvShows;
  final List<int> watchedEpisodeIds;
  final bool isLoadingShows;
  final bool isSyncingShows;

  AppState({
    required this.appParameters,
    required this.tvShows,
    required this.watchedEpisodeIds,
    this.isLoadingShows = false,
    this.isSyncingShows = false,
  });

  static AppState initialState() => AppState(
        appParameters: [],
        tvShows: [],
        watchedEpisodeIds: [],
        isLoadingShows: true,
        isSyncingShows: false,
      );

  AppState copyWith({
    List<AppParameter>? appParameters,
    List<TvShow>? tvShows,
    List<int>? watchedEpisodeIds,
    bool? isLoadingShows,
    bool? isSyncingShows,
  }) {
    return AppState(
      appParameters: appParameters ?? this.appParameters,
      tvShows: tvShows ?? this.tvShows,
      watchedEpisodeIds: watchedEpisodeIds ?? this.watchedEpisodeIds,
      isLoadingShows: isLoadingShows ?? this.isLoadingShows,
      isSyncingShows: isSyncingShows ?? this.isSyncingShows,
    );
  }
}

extension BuildContextExtension on BuildContext {
  AppState get state => getState<AppState>();
  AppState read() => getRead<AppState>();
  R select<R>(R Function(AppState state) selector) => getSelect<AppState, R>(selector);
  R? event<R>(Evt<R> Function(AppState state) selector) => getEvent<AppState, R>(selector);
}
