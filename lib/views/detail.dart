import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_akhir/controllers/detail_controller.dart';
import 'package:project_akhir/controllers/uang_controller.dart';
import 'package:project_akhir/controllers/waktu_controller.dart';
import 'package:project_akhir/model/movie_detail.dart';
import 'package:project_akhir/model/movie_list.dart';
import 'package:project_akhir/model/waktu_tayang.dart';
import 'package:project_akhir/services/tmdb_service.dart';
import 'package:project_akhir/services/notifikasi.dart';
import 'package:project_akhir/model/cinema.dart';
import 'package:project_akhir/services/cinema_data.dart';
import 'package:url_launcher/url_launcher.dart';

class Detail extends StatefulWidget {
  final MovieList movie;
  final int id;
  final String username;
  const Detail({
    super.key,
    required this.id,
    required this.movie,
    required this.username,
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

  List<Cinema> nearbyCinemas = [];
  bool isLoadingCinemas = true;

  Box<MovieList>? watchlistBox;
  bool isSaved = false;
  bool boxReady = false;

  String selectedZone = "WIB";
  String convertedTime = "";

  late WaktuTayang waktuTayang;

  void _changeCurrency(String currency) {
    setState(() {
      selectedCurrency = currency;
      hargaTiket = uangController.convert(
        50000,
        currency,
      ); // misal harga dasar Rp 50.000
    });
  }

  Future<void> _fetchNearbyCinemas() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Cinema> tempList = List.from(CinemaData.jogjaCinemas);

      for (var cinema in tempList) {
        double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          cinema.lat,
          cinema.lng,
        );
        cinema.distanceData = distanceInMeters / 1000;
      }

      tempList.sort((a, b) => a.distanceData!.compareTo(b.distanceData!));

      setState(() {
        nearbyCinemas = tempList;
        isLoadingCinemas = false;
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() => isLoadingCinemas = false);
    }
  }

  Future<void> _openMap(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tidak dapat membuka Google Maps: $e")),
      );
    }
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

    convertedTime = showtimeController.getConvertedShowtime(
      waktuTayang,
      selectedZone,
    );

    _initUang();
    _fetchNearbyCinemas();
  }

  Future<void> _openUserBox() async {
    String safeUsername = widget.username.isNotEmpty
        ? widget.username
        : "default";
    watchlistBox = await Hive.openBox<MovieList>('watchlist_$safeUsername');
    _checkIfSaved();
    setState(() {});
  }

  void _checkIfSaved() {
    if (watchlistBox != null && watchlistBox!.isOpen) {
      setState(() {
        isSaved = watchlistBox!.containsKey(widget.movie.id);
      });
    }
  }

  void _toggleWatchlist() async {
    if (watchlistBox == null || !watchlistBox!.isOpen) {
      print("ERROR: Database belum siap/terbuka saat tombol ditekan.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Database sedang memuat, coba sesaat lagi..."),
        ),
      );
      _openUserBox();
      return;
    }

    try {
      if (isSaved) {
        await watchlistBox!.delete(widget.movie.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${widget.movie.title} dihapus dari Watchlist"),
            ),
          );
        }
      } else {
        await watchlistBox!.put(widget.movie.id, widget.movie);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${widget.movie.title} ditambahkan ke Watchlist"),
            ),
          );
        }

        try {
          await showNotification(widget.movie.title);
        } catch (e) {
          print("Warning: Gagal memunculkan notifikasi: $e");
        }
      }

      _checkIfSaved();
    } catch (e) {
      print("ERROR saat menekan tombol: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data: $e")));
      }
    }
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
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Detail Film", style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<MovieDetail>(
        future: _movieDetailFuture,
        builder: (context, snapshot) {
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
                    Image.network(
                      "https://image.tmdb.org/t/p/w500${movie.posterPath}",
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
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3,
                                        horizontal: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 15,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            movie.rating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Info Lainnya
                                    Text(
                                      "${movie.runtime} menit",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      "Bahasa: ${movie.language.join(', ')}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      "Genre: ${movie.genres.join(', ')}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  bottom: 5,
                                  left: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: _toggleWatchlist,
                                  iconSize: 30,
                                  icon: Icon(
                                    isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isSaved
                                        ? Color.fromARGB(255, 37, 216, 101)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    movie.overview,
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 15),
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
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ["WIB", "WITA", "WIT", "London"].map((zone) {
                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedZone = zone;
                                convertedTime = showtimeController
                                    .getConvertedShowtime(waktuTayang, zone);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedZone == zone
                                  ? Color.fromARGB(255, 37, 216, 101)
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
                          color: Color.fromARGB(255, 37, 216, 101),
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
                        children: uangController.availableCurrencies.map((
                          currency,
                        ) {
                          return ElevatedButton(
                            onPressed: () => _changeCurrency(currency),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedCurrency == currency
                                  ? Color.fromARGB(255, 37, 216, 101)
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
                            color: Color.fromARGB(255, 37, 216, 101),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Text(
                        "Bioskop Terdekat:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (isLoadingCinemas)
                      const Center(child: CircularProgressIndicator())
                    else if (nearbyCinemas.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Lokasi tidak ditemukan",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: nearbyCinemas.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 15),
                          itemBuilder: (context, index) {
                            final cinema = nearbyCinemas[index];
                            return Container(
                              width: 280,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _openMap(cinema.lat, cinema.lng),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Ikon Bioskop
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              37,
                                              216,
                                              101,
                                            ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const FaIcon(
                                            FontAwesomeIcons.film,
                                            color: Color.fromARGB(
                                              255,
                                              37,
                                              216,
                                              101,
                                            ),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Info Bioskop
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                cinema.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    size: 12,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${cinema.distanceData?.toStringAsFixed(1)} km",
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.star,
                                                    size: 12,
                                                    color: Colors.amber,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    cinema.rating.toString(),
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      //   floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _toggleWatchlist,
      //   label: Text(isSaved ? "Hapus dari Watchlist" : "Tambah ke Watchlist"),
      //   icon: Icon(isSaved ? Icons.check : Icons.add),
      // ),
    );
  }
}
