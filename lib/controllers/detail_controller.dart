import 'package:project_akhir/model/movie_detail.dart';
import 'package:project_akhir/services/tmdb_service.dart';

class DetailController {
  final TmdbService tmdbService;

  DetailController({required this.tmdbService});

  Future<MovieDetail> getMovieDetail(int id) async {
    return await tmdbService.getMovieDetail(id);
  }
}