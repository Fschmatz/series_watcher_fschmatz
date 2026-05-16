class EpisodeWatched {
  int? idEpisode;
  int? idTvShow;
  int? seasonNumber;
  int? episodeNumber;
  String? watchDate;

  EpisodeWatched({
    this.idEpisode,
    this.idTvShow,
    this.seasonNumber,
    this.episodeNumber,
    this.watchDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_episode': idEpisode,
      'id_tv_show': idTvShow,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'watch_date': watchDate,
    };
  }

  factory EpisodeWatched.fromMap(Map<String, dynamic> map) {
    return EpisodeWatched(
      idEpisode: map['id_episode'],
      idTvShow: map['id_tv_show'],
      seasonNumber: map['season_number'],
      episodeNumber: map['episode_number'],
      watchDate: map['watch_date'],
    );
  }
}
