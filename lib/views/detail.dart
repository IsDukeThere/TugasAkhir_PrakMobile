import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_akhir/controllers/detail_controller.dart';
import 'package:project_akhir/controllers/uang_controller.dart';
import 'package:project_akhir/controllers/waktu_controller.dart';
import 'package:project_akhir/model/movie_detail.dart';
import 'package:project_akhir/model/movie_list.dart';
import 'package:project_akhir/model/waktu_tayang.dart';
import 'package:project_akhir/services/tmdb_service.dart';
import 'package:project_akhir/services/notifikasi.dart';

class Detail extends StatefulWidget {
  final MovieList movie;
    final int id;
  final String username;
  const Detail({
    super.key, 
    required this.id,
    required this.movie,
    required this.username
    });

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late DetailController controller;
  late ShowtimeController showtimeController;
  late Future<MovieDetail> _movieDetailFuture;
  late UangController uangController;
  String selectedCurrency = "IDR";
  String hargaTiket = "...";
  

  Box<MovieList>? watchlistBox;
  bool isSaved = false;
  bool boxReady = false;

  String selectedZone = "WIB";
  String convertedTime = "";

   late WaktuTayang waktuTayang;

   void _changeCurrency(String currency) {
    setState(() {
      selectedCurrency = currency;
      hargaTiket = uangController.convert(50000, currency); // misal harga dasar Rp 50.000
    });
  }

  @override
  void initState() {
    super.initState();
    controller = DetailController(tmdbService: TmdbService());
    showtimeController = ShowtimeController();
    _movieDetailFuture = controller.getMovieDetail(widget.id);

    uangController = UangController();
    uangController.intiRates();


    _openUserBox();

    waktuTayang = WaktuTayang(
      movieTitle: widget.movie.title,
      showTimeUtc: DateTime.utc(2025, 10, 31, 12, 30),
    );

    _movieDetailFuture = controller.getMovieDetail(widget.id);

    convertedTime =
        showtimeController.getConvertedShowtime(waktuTayang, selectedZone);

        _initUang();
  }

    Future<void> _openUserBox() async {
    watchlistBox =
        await Hive.openBox<MovieList>('watchlist_${widget.username}');
    _checkIfSaved();
    setState(() {});
    }

    void _checkIfSaved() {
    setState(() {
      isSaved = watchlistBox!.containsKey(widget.movie.id);
    });
  }

  void _toggleWatchlist() async {
    if (isSaved) {
      watchlistBox!.delete(widget.movie.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${widget.movie.title} dihapus dari Watchlist")),
      );
    } else {
      watchlistBox!.put(widget.movie.id, widget.movie);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("${widget.movie.title} ditambahkan ke Watchlist")),
      );

      await showNotification(widget.movie.title);
    }

    _checkIfSaved();
  }

  Future<void> _initUang() async {
    await uangController.intiRates();
    setState(() {
      hargaTiket = uangController.convert(50000, selectedCurrency);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
        "Detail Film",
        style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<MovieDetail>(
        future: _movieDetailFuture,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final movie = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Image.network("https://image.tmdb.org/t/p/w500${movie.posterPath}",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 400,
                    ),
                  Container(
                    height: 300,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                  Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(movie.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 15),
                            SizedBox(width: 5,),
                            Text(
                              movie.rating.toStringAsFixed(1),
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(width: 5,),
                          ],
                        ),
                      ),
                      Text(
                        "${movie.runtime.toString()} menit",
                        style: TextStyle(color: Colors.white),
                        ),
                      Text(
                        "Bahasa : ${movie.language.join(', ')}",
                        style: TextStyle(color: Colors.white),
                        ),
                      Text(
                        "Genre: ${movie.genres.join(', ')}",
                        style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                SizedBox(height: 25,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        movie.overview,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                  ),
                  SizedBox(height: 15,),
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jadwal Tayang:",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ["WIB", "WITA", "WIT", "London"].map((zone) {
                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedZone = zone;
                                convertedTime =
                                    showtimeController.getConvertedShowtime(waktuTayang, zone);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedZone == zone
                                  ? Colors.amber
                                  : Colors.grey.shade800,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(zone),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Jam tayang: $convertedTime $selectedZone",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Harga Tiket:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: uangController.availableCurrencies.map((currency) {
                          return ElevatedButton(
                            onPressed: () => _changeCurrency(currency),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedCurrency == currency
                                  ? Colors.amber
                                  : Colors.grey.shade800,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(currency),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Harga: $hargaTiket",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
        ),
        floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleWatchlist,
        label: Text(isSaved ? "Hapus dari Watchlist" : "Tambah ke Watchlist"),
        icon: Icon(isSaved ? Icons.check : Icons.add),
      ),
    );
  }
}