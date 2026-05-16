import 'dart:convert';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:series_watcher_fschmatz/service/store_service.dart';

import '../dao/episode_dao.dart';
import '../dao/episode_watched_dao.dart';
import '../dao/season_dao.dart';
import '../dao/tv_show_dao.dart';
import '../entity/episode_watched.dart';
import '../entity/tv_show.dart';
import '../util/api_configs.dart';
import 'tv_service.dart';

class TvShowLocalService extends StoreService {
  static final TvShowLocalService _instance = TvShowLocalService._internal();

  factory TvShowLocalService() => _instance;

  TvShowLocalService._internal();

  final _tvShowDao = TvShowDAO.instance;
  final _episodeWatchedDao = EpisodeWatchedDAO.instance;
  final _seasonDao = SeasonDAO.instance;
  final _episodeDao = EpisodeDAO.instance;

  Future<List<TvShow>> getAllTvShows() async {
    final shows = await _tvShowDao.getAllTvShows();
    for (var show in shows) {
      if (show.id != null) {
        final nextEp = await _episodeDao.getNextEpisodeToWatch(show.id!);
        if (nextEp != null) {
          final seasonNum = (nextEp.seasonNumber ?? 0).toString().padLeft(2, '0');
          final epNum = (nextEp.episodeNumber ?? 0).toString().padLeft(2, '0');
          show.nextEpisodeInfo = 'S${seasonNum}E$epNum - ${nextEp.name}';
        }
      }
    }
    return shows;
  }

  Future<void> saveTvShow(TvShow tvShow) async {
    await _tvShowDao.insertTvShow(tvShow);
  }

  Future<TvShow?> getFullTvShow(int idTvShow) async {
    final tvShow = await _tvShowDao.getTvShowById(idTvShow);
    if (tvShow == null) return null;

    final seasons = await _seasonDao.getSeasonsByTvShow(idTvShow);
    for (var season in seasons) {
      if (season.id != null) {
        season.episodes = await _episodeDao.getEpisodesBySeason(season.id!);
      }
    }
    tvShow.seasons = seasons;
    return tvShow;
  }

  Future<void> saveFullTvShowHierarchy(TvShow tvShow) async {
    await _tvShowDao.insertTvShow(tvShow);

    if (tvShow.seasons != null) {
      for (var season in tvShow.seasons!) {
        season.idTvShow = tvShow.id;
        await _seasonDao.insertSeason(season);

        if (season.episodes != null) {
          for (var episode in season.episodes!) {
            episode.idSeason = season.id;
            await _episodeDao.insertEpisode(episode);
          }
        }
      }
    }
  }

  Future<void> downloadAndSaveTvShow(int id) async {
    // 1. Get Details
    TvShow tvShow = await TvService().getTvShowDetails(id);

    // Download Series Poster
    if (tvShow.posterPath != null) {
      tvShow.posterImage = await _downloadImageAsBase64(tvShow.posterPath!);
    }

    // 2. For each season, get episodes
    if (tvShow.seasons != null) {
      for (var season in tvShow.seasons!) {
        if (season.seasonNumber != null) {
          season.episodes = await TvService().getSeasonEpisodes(id, season.seasonNumber!);
        }
      }
    }

    // 3. Save to DB
    await saveFullTvShowHierarchy(tvShow);
  }

  Future<String?> _downloadImageAsBase64(String path) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfigs.imageBaseUrl}$path'));

      if (response.statusCode == 200) {
        final compressedBytes = await FlutterImageCompress.compressWithList(response.bodyBytes, minHeight: 250, minWidth: 220, quality: 90);
        return base64Encode(compressedBytes);
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  Future<void> syncAllSavedTvShows() async {
    List<TvShow> savedShows = await getAllTvShows();
    for (var show in savedShows) {
      if (show.id != null) {
        await downloadAndSaveTvShow(show.id!);
      }
    }
  }

  Future<void> removeTvShow(int id) async {
    await _tvShowDao.deleteTvShow(id);
    await _episodeWatchedDao.deleteAllByTvShow(id);
  }

  Future<void> markEpisodeAsWatched(EpisodeWatched episode) async {
    await _episodeWatchedDao.insertEpisodeWatched(episode);
  }

  Future<void> unmarkEpisodeAsWatched(int idEpisode) async {
    await _episodeWatchedDao.deleteEpisodeWatched(idEpisode);
  }

  Future<List<EpisodeWatched>> getWatchedEpisodes(int idTvShow) async {
    return await _episodeWatchedDao.getWatchedEpisodesByTvShow(idTvShow);
  }

  Future<bool> isEpisodeWatched(int idEpisode) async {
    return await _episodeWatchedDao.isEpisodeWatched(idEpisode);
  }

  Future<List<int>> getAllWatchedEpisodeIds() async {
    return await _episodeWatchedDao.getAllWatchedEpisodeIds();
  }

  Future<void> archiveTvShow(int id, bool archive) async {
    await _tvShowDao.archiveTvShow(id, archive);
  }
}
