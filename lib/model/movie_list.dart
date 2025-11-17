import 'package:hive/hive.dart';

part "movie_list.g.dart";

@HiveType(typeId: 0)
class MovieList {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterPath;

  @HiveField(3)
  final String overview;

  @HiveField(4)
  final String releaseDate;

  @HiveField(5)
  final double rating;

  @HiveField(6)
  String languageCode;

  MovieList({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.rating,
    required this.languageCode
  });

  factory MovieList.fromJson(Map<String, dynamic> json) {
    return MovieList(
      id: json['id'], 
      title: json['title'] ?? '', 
      overview: json['overview'] ?? '', 
      posterPath: json['poster_path'] ?? '', 
      releaseDate: json['release_date'] ?? '', 
      rating: (json['vote_average'] ?? 0).toDouble(),
      languageCode: (json['original_language'] ?? '')
      );
  }

  static Future? getMovieData() async {}
}