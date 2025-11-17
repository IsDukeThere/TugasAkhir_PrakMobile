import 'package:project_akhir/model/movie_list.dart';
import 'package:project_akhir/services/lokasi_service.dart';
import 'package:project_akhir/services/tmdb_service.dart';

class MovieController {
  final TmdbService tmdbService;
  
  MovieController({
    required this.tmdbService
  });

  Future<List<MovieList>> getMovies({int page = 1}) async {
    final movies = await tmdbService.getMovieData(page: page);
    return movies.map((movies) {
      return MovieList(
        id: movies.id, 
        title: movies.title, 
        overview:  movies.overview, 
        posterPath:  movies.posterPath, 
        releaseDate:  movies.releaseDate, 
        rating:  movies.rating,
        languageCode: movies.languageCode
        );
    }).toList();
  }

  Future<List<MovieList>> getMoviesSortedByUserLanguage({int page = 1}) async {
    final location = await LokasiService.getUserLocation();
    final String country = location['country'] ?? 'Unknown';

    final String languageCode = await tmdbService.getLanguageCodeByCountry(country);

    print("Negara: $country | Kode Bahasa: $languageCode | Halaman: $page");

    final filteredMovies = await tmdbService.fetchMoviesByLanguage(languageCode, page: page); 

    return filteredMovies;
  }

  Future<List<MovieList>> searchMovies(String query, {int page = 1}) async {
    return await tmdbService.searchMovie(query, page: page);
  }
}