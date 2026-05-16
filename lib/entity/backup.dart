class Backup {
  List<Map<String, dynamic>> tvShows;
  List<Map<String, dynamic>> seasons;
  List<Map<String, dynamic>> episodes;
  List<Map<String, dynamic>> episodesWatched;
  List<Map<String, dynamic>> appParameters;

  Backup({
    required this.tvShows,
    required this.seasons,
    required this.episodes,
    required this.episodesWatched,
    required this.appParameters,
  });

  factory Backup.fromJson(Map<String, dynamic> json) {
    return Backup(
      tvShows: List<Map<String, dynamic>>.from(json['tvShows'] ?? []),
      seasons: List<Map<String, dynamic>>.from(json['seasons'] ?? []),
      episodes: List<Map<String, dynamic>>.from(json['episodes'] ?? []),
      episodesWatched: List<Map<String, dynamic>>.from(json['episodesWatched'] ?? []),
      appParameters: List<Map<String, dynamic>>.from(json['appParameters'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tvShows': tvShows,
      'seasons': seasons,
      'episodes': episodes,
      'episodesWatched': episodesWatched,
      'appParameters': appParameters,
    };
  }
}
