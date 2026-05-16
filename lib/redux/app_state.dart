import '../entity/app_parameter.dart';
import '../entity/tv_show.dart';

class AppState {
  final List<AppParameter> appParameters;
  final List<TvShow> tvShows;
  final List<int> watchedEpisodeIds;
  final bool isLoadingShows;

  AppState({
    required this.appParameters,
    required this.tvShows,
    required this.watchedEpisodeIds,
    this.isLoadingShows = false,
  });

  static AppState initialState() => AppState(
        appParameters: [],
        tvShows: [],
        watchedEpisodeIds: [],
        isLoadingShows: true,
      );

  AppState copyWith({
    List<AppParameter>? appParameters,
    List<TvShow>? tvShows,
    List<int>? watchedEpisodeIds,
    bool? isLoadingShows,
  }) {
    return AppState(
      appParameters: appParameters ?? this.appParameters,
      tvShows: tvShows ?? this.tvShows,
      watchedEpisodeIds: watchedEpisodeIds ?? this.watchedEpisodeIds,
      isLoadingShows: isLoadingShows ?? this.isLoadingShows,
    );
  }
}
