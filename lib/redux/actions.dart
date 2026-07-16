import '../dao/episode_dao.dart';
import '../entity/app_parameter.dart';
import '../entity/episode.dart';
import '../entity/episode_watched.dart';
import '../entity/tv_show.dart';
import '../enum/sync_mode.dart';
import '../service/app_parameter_service.dart';
import '../service/tv_show_local_service.dart';
import '../service/widget_service.dart';
import '../util/app_constants.dart';
import '../util/toast_utils.dart';
import 'app_state.dart';
import 'helper/app_action.dart';

class LoadAppParametersAction extends AppAction {
  @override
  Future<AppState?> reduce() async {
    List<AppParameter> parameters = await AppParameterService().getAll();

    return state.copyWith(appParameters: parameters);
  }
}

class SaveAppParameterAction extends AppAction {
  final AppParameter appParameter;

  SaveAppParameterAction(this.appParameter);

  @override
  Future<AppState?> reduce() async {
    await AppParameterService().saveParameter(appParameter);

    return null;
  }
}

class LoadTvShowsAction extends AppAction {
  final bool showLoading;

  LoadTvShowsAction({this.showLoading = true});

  @override
  void before() {
    if (showLoading) {
      dispatch(_SetLoadingShowsAction(true));
    }
  }

  @override
  Future<AppState?> reduce() async {
    List<TvShow> tvShows = await TvShowLocalService().getAllTvShows();
    WidgetService.updateNextEpisodeWidget(tvShows);
    return state.copyWith(tvShows: tvShows, isLoadingShows: false);
  }
}

class _SetLoadingShowsAction extends AppAction {
  final bool loading;

  _SetLoadingShowsAction(this.loading);

  @override
  Future<AppState?> reduce() async => state.copyWith(isLoadingShows: loading);
}

class LoadWatchedEpisodesAction extends AppAction {
  @override
  Future<AppState?> reduce() async {
    List<int> watchedIds = await TvShowLocalService().getAllWatchedEpisodeIds();

    return state.copyWith(watchedEpisodeIds: watchedIds);
  }
}

class SaveTvShowAction extends AppAction {
  final TvShow tvShow;

  SaveTvShowAction(this.tvShow);

  @override
  Future<AppState?> reduce() async {
    try {
      await TvShowLocalService().saveTvShow(tvShow);

      if (tvShow.id != null) {
        await TvShowLocalService().downloadAndSaveTvShow(tvShow.id!);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void after() {
    dispatch(LoadTvShowsAction());
    ToastUtils.show("Sync completed!");
  }
}

class SyncTvShowsAction extends AppAction {
  final SyncMode mode;

  SyncTvShowsAction({this.mode = SyncMode.all});

  @override
  void before() => dispatch(_SetSyncingShowsAction(true));

  @override
  Future<AppState?> reduce() async {
    await TvShowLocalService().syncTvShows(mode: mode);

    String paramKey = AppConstants.lastSyncDateAppParameter;

    if (mode == SyncMode.watchlist) {
      paramKey = AppConstants.lastSyncWatchlistDateAppParameter;
    } else if (mode == SyncMode.active) {
      paramKey = AppConstants.lastSyncActiveDateAppParameter;
    }

    await AppParameterService().saveLastSyncDate(paramKey);
    dispatch(LoadAppParametersAction());

    return state.copyWith(isSyncingShows: false);
  }

  @override
  void after() {
    dispatch(LoadTvShowsAction());
    ToastUtils.show("Sync completed!");
  }
}

class _SetSyncingShowsAction extends AppAction {
  final bool isSyncing;

  _SetSyncingShowsAction(this.isSyncing);

  @override
  AppState? reduce() => state.copyWith(isSyncingShows: isSyncing);
}

class RemoveTvShowAction extends AppAction {
  final int id;

  RemoveTvShowAction(this.id);

  @override
  Future<AppState?> reduce() async {
    await TvShowLocalService().removeTvShow(id);

    return null;
  }

  @override
  void after() {
    dispatch(LoadTvShowsAction(showLoading: false));
    dispatch(LoadWatchedEpisodesAction());
  }
}

class ToggleArchiveTvShowAction extends AppAction {
  final int id;
  final bool archive;

  ToggleArchiveTvShowAction(this.id, this.archive);

  @override
  Future<AppState?> reduce() async {
    await TvShowLocalService().archiveTvShow(id, archive);

    return null;
  }

  @override
  void after() {
    dispatch(LoadTvShowsAction(showLoading: false));
    ToastUtils.show("Update completed!");
  }
}

class ToggleShowInWidgetAction extends AppAction {
  final int id;
  final bool showInWidget;

  ToggleShowInWidgetAction(this.id, this.showInWidget);

  @override
  Future<AppState?> reduce() async {
    await TvShowLocalService().toggleShowInWidget(id, showInWidget);

    return null;
  }

  @override
  void after() {
    dispatch(LoadTvShowsAction(showLoading: false));
    ToastUtils.show("Update completed!");
  }
}

class ToggleEpisodeWatchedAction extends AppAction {
  final int tvShowId;
  final Episode episode;
  final bool watched;

  ToggleEpisodeWatchedAction(this.tvShowId, this.episode, this.watched);

  @override
  Future<AppState?> reduce() async {
    if (watched) {
      await TvShowLocalService().markEpisodeAsWatched(
        EpisodeWatched(
          idEpisode: episode.id,
          idTvShow: tvShowId,
          seasonNumber: episode.seasonNumber,
          episodeNumber: episode.episodeNumber,
          watchDate: DateTime.now().toString(),
        ),
      );
    } else {
      await TvShowLocalService().unmarkEpisodeAsWatched(episode.id!);
    }

    return null;
  }

  @override
  void after() {
    dispatch(LoadWatchedEpisodesAction());
    dispatch(LoadTvShowsAction(showLoading: false));
  }
}

class MarkSeasonAsWatchedAction extends AppAction {
  final int tvShowId;
  final List<Episode> episodes;

  MarkSeasonAsWatchedAction(this.tvShowId, this.episodes);

  @override
  Future<AppState?> reduce() async {
    for (var episode in episodes) {
      await TvShowLocalService().markEpisodeAsWatched(
        EpisodeWatched(
          idEpisode: episode.id,
          idTvShow: tvShowId,
          seasonNumber: episode.seasonNumber,
          episodeNumber: episode.episodeNumber,
          watchDate: DateTime.now().toString(),
        ),
      );
    }

    return null;
  }

  @override
  void after() {
    dispatch(LoadWatchedEpisodesAction());
    dispatch(LoadTvShowsAction(showLoading: false));
  }
}

class MarkNextEpisodeAsWatchedAction extends AppAction {
  final int tvShowId;

  MarkNextEpisodeAsWatchedAction(this.tvShowId);

  @override
  Future<AppState?> reduce() async {
    final nextEp = await EpisodeDAO.instance.getNextEpisodeToWatch(tvShowId);
    if (nextEp != null) {
      await TvShowLocalService().markEpisodeAsWatched(
        EpisodeWatched(
          idEpisode: nextEp.id,
          idTvShow: tvShowId,
          seasonNumber: nextEp.seasonNumber,
          episodeNumber: nextEp.episodeNumber,
          watchDate: DateTime.now().toString(),
        ),
      );
    }

    return null;
  }

  @override
  void after() {
    dispatch(LoadWatchedEpisodesAction());
    dispatch(LoadTvShowsAction(showLoading: false));
  }
}

class SyncSingleTvShowAction extends AppAction {
  final int tvShowId;

  SyncSingleTvShowAction(this.tvShowId);

  @override
  Future<AppState?> reduce() async {
    await TvShowLocalService().downloadAndSaveTvShow(tvShowId);
    return null;
  }

  @override
  void after() {
    dispatch(LoadTvShowsAction(showLoading: false));
    ToastUtils.show("Update completed!");
  }
}
