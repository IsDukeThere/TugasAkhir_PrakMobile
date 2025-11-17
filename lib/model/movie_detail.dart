class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double rating;
  final int runtime;
  final List<String> genres;
  final List<String> language;

  MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.language,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'],
      title: json['title'],
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      rating: (json['vote_average'] ?? 0).toDouble(),
      runtime: json['runtime'] ?? 0,
      genres: (json['genres'] as List?)
              ?.map((g) => g['name'].toString())
              .toList() ??
          [],
      language: (json['spoken_languages'] as List<dynamic>?)
      ?.map((lang) =>  lang['english_name'] as String)
      .toList() ?? [],
    );
  }
}