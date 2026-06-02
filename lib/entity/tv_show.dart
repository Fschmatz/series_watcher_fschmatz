import 'dart:convert';
import 'dart:typed_data';

import 'genre.dart';
import 'season.dart';

class TvShow {
  int? id;
  String? name;
  String? originalName;
  String? overview;
  String? posterPath;
  String? backdropPath;
  String? firstAirDate;
  double? voteAverage;
  int? numberOfSeasons;
  int? numberOfEpisodes;
  String? status;
  double? popularity;
  bool isArchived;
  List<Genre>? genres;
  List<Season>? seasons;
  String? nextEpisodeInfo;
  int? nextEpisodeRuntime;
  int? remainingEpisodes;
  String? _posterImage;
  Uint8List? _posterBytes;

  TvShow({
    this.id,
    this.name,
    this.originalName,
    this.overview,
    this.posterPath,
    String? posterImage,
    this.backdropPath,
    this.firstAirDate,
    this.voteAverage,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.status,
    this.popularity,
    this.isArchived = false,
    this.genres,
    this.seasons,
    this.nextEpisodeInfo,
    this.nextEpisodeRuntime,
    this.remainingEpisodes,
  }) : _posterImage = posterImage;

  String? get posterImage => _posterImage;

  Uint8List? get posterBytes {
    if (_posterBytes == null && _posterImage != null) {
      try {
        _posterBytes = base64Decode(_posterImage!);
      } catch (_) {}
    }

    return _posterBytes;
  }

  set posterImage(String? value) {
    if (_posterImage != value) {
      _posterImage = value;
      _posterBytes = null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'overview': overview,
      'poster_path': posterPath,
      'poster_image': posterImage,
      'backdrop_path': backdropPath,
      'first_air_date': firstAirDate,
      'vote_average': voteAverage,
      'number_of_seasons': numberOfSeasons,
      'number_of_episodes': numberOfEpisodes,
      'status': status,
      'popularity': popularity,
      'archived': isArchived ? 1 : 0,
    };
  }

  factory TvShow.fromMap(Map<String, dynamic> map) {
    return TvShow(
      id: map['id'],
      name: map['name'],
      originalName: map['original_name'] ?? map['originalName'],
      overview: map['overview'],
      posterPath: map['poster_path'] ?? map['posterPath'],
      posterImage: map['poster_image'] ?? map['posterImage'],
      backdropPath: map['backdrop_path'] ?? map['backdropPath'],
      firstAirDate: map['first_air_date'] ?? map['firstAirDate'],
      voteAverage: (map['vote_average'] ?? map['voteAverage'])?.toDouble(),
      numberOfSeasons: map['number_of_seasons'] ?? map['numberOfSeasons'],
      numberOfEpisodes: map['number_of_episodes'] ?? map['numberOfEpisodes'],
      status: map['status'],
      popularity: (map['popularity'])?.toDouble(),
      isArchived: (map['archived'] ?? 0) == 1,
      genres: map['genres'] != null ? (map['genres'] as List).map((g) => Genre.fromMap(g)).toList() : null,
      seasons: map['seasons'] != null ? (map['seasons'] as List).map((s) => Season.fromMap(s)).toList() : null,
    );
  }
}
