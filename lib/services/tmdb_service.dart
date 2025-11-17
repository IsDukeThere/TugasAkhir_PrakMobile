import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_akhir/model/movie_detail.dart';
import 'package:project_akhir/model/movie_list.dart';

class TmdbService {
  final String baseApiUrl = "https://api.themoviedb.org/3/movie/popular";
  final String apiKey = "4c931d475ddef54fa1c5269e06b069bb";

  Future<List<MovieList>> getMovieData({int page = 1}) async {
    final url = "$baseApiUrl?api_key=$apiKey&language=en-US&page=$page";
    final response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      final List movies = data['results'];
      return movies.map(
        (json) => MovieList.fromJson(json)
        ).toList();
    } else {
      throw Exception("Gagal Mengambil Data");
    }
  }

  Future<String> getLanguageCodeByCountry(String countryName) async {
    final lowerCountry = countryName.toLowerCase();

    final Map<String, String> countryToLangMap = {
      "indonesia": "id",
      "malaysia": "ms",
      "japan": "ja",
      "china": "zh",
      "united states": "en",
      "united kingdom": "en",
      "france": "fr",
      "germany": "de",
      "spain": "es",
      "korea": "ko",
      "thailand": "th",
    };

    for (final entry in countryToLangMap.entries) {
      final countryKey = entry.key;
      final langCode = entry.value;

      if (lowerCountry.contains(countryKey)) { 
        print("Mendeteksi '$countryKey' di '$lowerCountry'. Menggunakan kode: $langCode");
        return langCode;
      }
    }

    print("Tidak ada kecocokan negara. Menggunakan default 'id'.");
  	return "id";
  }

  Future<List<MovieList>> fetchMoviesByLanguage(String languageCode, {int page = 1}) async {

    final urlString = 
        'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey'
        '&with_original_language=$languageCode'
        '&sort_by=release_date.desc'
        '&include_adult=false'
        '&include_video=false'
        '&page=$page';

    final url = Uri.parse(urlString);

    print("Fetching URL (Sortir Rilis Terbaru): $url");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List movies = data['results'];
      return movies.map((json) => MovieList.fromJson(json)).toList();
    } else {
      throw Exception("Gagal memuat film berdasarkan bahasa $languageCode");
    }
  }

  Future<MovieDetail> getMovieDetail(int movieId) async {
    final String detailApi = "https://api.themoviedb.org/3/movie/$movieId?api_key=4c931d475ddef54fa1c5269e06b069bb&language=en-US&page=1";
    final response = await http.get(Uri.parse(detailApi));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MovieDetail.fromJson(data);
    } else {
      throw Exception("Gagal mengambil detail film dengan ID $movieId");
    }
  }

  Future<List<MovieList>> searchMovie(String query, {int page = 1}) async { // TAMBAHKAN {int page = 1}
    final search = "https://api.themoviedb.org/3/search/movie?api_key=$apiKey&language=en-US&query=$query&page=$page&include_adult=false"; // UBAH 'page=1' menjadi 'page=$page'
    final response =  await http.get(Uri.parse(search));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List movies = data['results'];
      return movies.map((json) => MovieList.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mencari film");
      }
  }
}