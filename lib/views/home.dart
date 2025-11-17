import 'package:flutter/material.dart';
import 'package:project_akhir/controllers/movie_controller.dart';
import 'package:project_akhir/model/movie_list.dart';
import 'package:project_akhir/services/lokasi_service.dart';
import 'package:project_akhir/services/tmdb_service.dart';
import 'package:project_akhir/views/detail.dart';
import 'package:intl/intl.dart';
import 'package:project_akhir/views/login.dart';

String formatDate(String dateString) {
  if (dateString.isEmpty) return "-";
  final date = DateTime.parse(dateString);
  return DateFormat("dd MMM yyyy").format(date);
}

enum MovieViewMode { popular, byLanguage, search }

class Home extends StatefulWidget {
  final String username;
  const Home({super.key, required this.username});

  @override
  State<Home> createState() => _MovieListViewState();
}

class _MovieListViewState extends State<Home> {
  late MovieController controller;
  List<MovieList> movies = [];
  int currentPage = 1;
  bool isLoadingMore = false;
  bool isSearching = false;

  String? userCountry;
  bool isRegionLoading = false;

  final TextEditingController searchController = TextEditingController();

  MovieViewMode _currentMode = MovieViewMode.popular;

  @override
  void initState() {
    super.initState();
    controller = MovieController(tmdbService: TmdbService());
    _movie();
    _getUserCountry();
  }

  Future<void> _movie() async {
    setState(() {
      isRegionLoading = true;
      _currentMode = MovieViewMode.popular;
      currentPage = 1;
    });

    final data = await controller.getMovies(page: currentPage);
    setState(() {
      movies = data;
      isRegionLoading = false;
    });
  }

  Future<void> _getUserCountry() async {
    try {
      final location = await LokasiService.getUserLocation();
      setState(() {
        userCountry = location['country'];
      });
    } catch (e) {
      setState(() {
        userCountry = 'Unknown';
      });
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore) return;
    setState(() => isLoadingMore = true);

    currentPage++;
    List<MovieList> data = [];

    try {
      if (_currentMode == MovieViewMode.popular) {
        data = await controller.getMovies(page: currentPage);

      } else if (_currentMode == MovieViewMode.byLanguage) {
        data = await controller.getMoviesSortedByUserLanguage(page: currentPage);

      } else if (_currentMode == MovieViewMode.search) {
        data = await controller.searchMovies(searchController.text, page: currentPage);
      }
    } catch (e) {
      print("Error loading more data: $e");
    }

    setState(() {
      movies.addAll(data);
      isLoadingMore = false;
    });
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() => isSearching = false);
      await _movie();
      return;
    }

    setState(() {
      isSearching = true;
      isRegionLoading = true;
      _currentMode = MovieViewMode.search;
      currentPage = 1;
    });

    try {
      final results = await controller.searchMovies(query, page: currentPage);
      setState(() {
        movies = results;
        isRegionLoading = false;
      });
    } catch (e) {
      print("Error search: $e");
      setState(() => isRegionLoading = false);
    }
  }

  Future<void> _loadMoviesByRegion() async {
    setState(() {
      isRegionLoading = true;
      _currentMode = MovieViewMode.byLanguage;
      currentPage = 1;
      searchController.clear();
      isSearching = false;
    });

    try {
      final data = await controller.getMoviesSortedByUserLanguage(page: currentPage);
      setState(() {
        movies = data;
        isRegionLoading = false;
      });
    } catch (e) {
      print("Error loading movies by region: $e");
      setState(() => isRegionLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "Halo, ${widget.username}",
              style: TextStyle(fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: Colors.white
              ),
            ),
            SizedBox(width: 18),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: TextField(
                  controller: searchController,
                  onChanged: searchMovies,
                  decoration: InputDecoration(
                    hintText: "Cari...",
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(35),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )
              ),
              ),
              SizedBox(width: 5),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginPage();
                      }
                      ),
                    );
                },
                icon: Icon(Icons.logout, color: Colors.white),
              ),
              ],
            ),
        ),

      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if(!isLoadingMore &&
          scrollInfo.metrics.pixels ==
          scrollInfo.metrics.maxScrollExtent) {
            _loadMore();
          }
          return false;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => isRegionLoading = true);
                      await _movie();
                      setState(() => isRegionLoading = false);
                    },
                    child: Text("Semua Film"),
                  ),
                  SizedBox(width:15,),
                  ElevatedButton.icon(
                    onPressed: _loadMoviesByRegion,
                    label: Text(userCountry == null
                        ? "Berdasarkan Lokasi..."
                        : "Film dari $userCountry"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isRegionLoading
                  ? Center(child: CircularProgressIndicator())
                  : movies.isEmpty
                      ? Center(
                        child: Text(
                            "Tidak ada film ditemukan",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                      : GridView.builder(
                          padding: EdgeInsets.all(15),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final m = movies[index];
                            return MovieCard(
                              title: m.title,
                              posterPath: m.posterPath,
                              rating: m.rating,
                              release: m.releaseDate,
                              id: m.id,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Detail(
                                      id: m.id,
                                      movie: m,
                                      username: widget.username,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
            if (isLoadingMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              SizedBox(height: 10),
          ],
        ),
        ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final int id;
  final String title;
  final String posterPath;
  final double rating;
  final String release;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.id,
    required this.title,
    required this.posterPath,
    required this.rating,
    required this.release,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.hardEdge,
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              "https://image.tmdb.org/t/p/w500$posterPath",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 280,
                  color: Colors.grey.shade800,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, StackTrace) => Container(
                height: 280,
                color: Colors.grey.shade700,
                child: const Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 15),
                      SizedBox(width: 5),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Text(
                        formatDate(release),
                        style: TextStyle(color: Colors.white),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}