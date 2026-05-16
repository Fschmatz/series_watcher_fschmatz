class HistoryItem {
  final String tvShowName;
  final String episodeName;
  final int seasonNumber;
  final int episodeNumber;
  final String watchDate;

  HistoryItem({
    required this.tvShowName,
    required this.episodeName,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.watchDate,
  });

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      tvShowName: map['tv_show_name'] as String,
      episodeName: map['episode_name'] as String,
      seasonNumber: map['season_number'] as int,
      episodeNumber: map['episode_number'] as int,
      watchDate: map['watch_date'] as String,
    );
  }
}
