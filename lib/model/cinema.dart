class Cinema {
  final String name;
  final String address;
  final double rating;
  final double lat;
  final double lng;
  double? distanceData;

  Cinema({
    required this.name,
    required this.address,
    required this.rating,
    required this.lat,
    required this.lng,
    this.distanceData,
  });
}