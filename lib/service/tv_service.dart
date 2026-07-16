import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:series_watcher_fschmatz/service/store_service.dart';

import '../entity/episode.dart';
import '../entity/season.dart';
import '../entity/tv_show.dart';
import '../util/api_configs.dart';

class TvService extends StoreService {
  static final TvService _instance = TvService._internal();

  factory TvService() => _instance;

  TvService._internal();

  Future<List<TvShow>> searchTvShows(String query) async {
    final response = await http.get(Uri.parse('${ApiConfigs.baseUrl}/search/tv?api_key=${ApiConfigs.apiKey}&query=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((m) => TvShow.fromMap(m)).toList();
    } else {
      throw Exception('Failed to search TV shows');
    }
  }

  Future<List<TvShow>> getTrendingTvShows() async {
    final response = await http.get(Uri.parse('${ApiConfigs.baseUrl}/trending/tv/week?api_key=${ApiConfigs.apiKey}'));
    return _handleTvResponse(response);
  }

  Future<List<TvShow>> getPopularTvShows() async {
    final response = await http.get(Uri.parse('${ApiConfigs.baseUrl}/tv/popular?api_key=${ApiConfigs.apiKey}'));
    return _handleTvResponse(response);
  }

  Future<List<TvShow>> getTopRatedTvShows() async {
    final response = await http.get(Uri.parse('${ApiConfigs.baseUrl}/tv/top_rated?api_key=${ApiConfigs.apiKey}'));
    return _handleTvResponse(response);
  }

  Future<List<TvShow>> getOnTheAirTvShows() async {
    final response = await http.get(Uri.parse('${ApiConfigs.baseUrl}/tv/on_the_air?api_key=${ApiConfigs.apiKey}'));
    return _handleTvResponse(response);
  }

  List<TvShow> _handleTvResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((m) => TvShow.fromMap(m)).toList();
    } else {
      throw Exception('Failed to fetch TV shows');
    }
  }

  Future<TvShow> getTvShowDetails(int id) async {
    final response = await http.get(Uri.parse('${ApiConfigs.baseUrl}/tv/$id?api_key=${ApiConfigs.apiKey}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return TvShow.fromMap(data);
    } else {
      throw Exception('Failed to get TV show details');
    }
  }

  Future<List<Season>> getTvShowSeasons(int tvShowId, int numberOfSeasons) async {
    // This is just a placeholder, usually we get seasons from TvShowDetails
    // But if we need more details per season, we call this
    return [];
  }

  Future<List<Episode>> getSeasonEpisodes(int tvShowId, int seasonNumber) async {
    final response = await http.get(Uri.parse('${ApiConfigs.baseUrl}/tv/$tvShowId/season/$seasonNumber?api_key=${ApiConfigs.apiKey}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List episodes = data['episodes'];
      return episodes.map((e) {
        final ep = Episode.fromMap(e);
        ep.seasonNumber = seasonNumber; // Inject the known season number
        return ep;
      }).toList();
    } else {
      throw Exception('Failed to get episodes');
    }
  }
}
