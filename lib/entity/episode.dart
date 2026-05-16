class Episode {
  int? id;
  int? idSeason;
  String? airDate;
  int? episodeNumber;
  int? seasonNumber;
  String? name;
  String? overview;
  String? stillPath;
  String? stillImage; // Base64
  double? voteAverage;
  int? runtime;

  Episode({
    this.id,
    this.idSeason,
    this.airDate,
    this.episodeNumber,
    this.seasonNumber,
    this.name,
    this.overview,
    this.stillPath,
    this.stillImage,
    this.voteAverage,
    this.runtime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_season': idSeason,
      'air_date': airDate,
      'episode_number': episodeNumber,
      'name': name,
      'overview': overview,
      'still_path': stillPath,
      'still_image': stillImage,
      'vote_average': voteAverage,
      'runtime': runtime,
    };
  }

  factory Episode.fromMap(Map<String, dynamic> map) {
    return Episode(
      id: map['id'],
      idSeason: map['id_season'] ?? map['idSeason'],
      airDate: map['air_date'] ?? map['airDate'],
      episodeNumber: map['episode_number'] ?? map['episodeNumber'],
      seasonNumber: map['season_number'] ?? map['seasonNumber'],
      name: map['name'],
      overview: map['overview'],
      stillPath: map['still_path'] ?? map['stillPath'],
      stillImage: map['still_image'] ?? map['stillImage'],
      voteAverage: (map['vote_average'] ?? map['voteAverage'])?.toDouble(),
      runtime: map['runtime'],
    );
  }
}
