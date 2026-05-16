import 'episode.dart';

class Season {
  int? id;
  int? idTvShow;
  String? airDate;
  int? episodeCount;
  String? name;
  String? overview;
  String? posterPath;
  String? posterImage;
  int? seasonNumber;
  List<Episode>? episodes;

  Season({
    this.id,
    this.idTvShow,
    this.airDate,
    this.episodeCount,
    this.name,
    this.overview,
    this.posterPath,
    this.posterImage,
    this.seasonNumber,
    this.episodes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_tv_show': idTvShow,
      'air_date': airDate,
      'episode_count': episodeCount,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'poster_image': posterImage,
      'season_number': seasonNumber,
    };
  }

  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      id: map['id'],
      idTvShow: map['id_tv_show'] ?? map['idTvShow'],
      airDate: map['air_date'] ?? map['airDate'],
      episodeCount: map['episode_count'] ?? map['episodeCount'],
      name: map['name'],
      overview: map['overview'],
      posterPath: map['poster_path'] ?? map['posterPath'],
      posterImage: map['poster_image'] ?? map['posterImage'],
      seasonNumber: map['season_number'] ?? map['seasonNumber'],
      episodes: map['episodes'] != null ? (map['episodes'] as List).map((e) => Episode.fromMap(e)).toList() : null,
    );
  }
}
