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
