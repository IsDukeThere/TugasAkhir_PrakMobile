class MovieHarga {
  final int priceIDR;
  final Map<String, double> rates;

  MovieHarga({
    required this.priceIDR,
    required this.rates
  });

  factory MovieHarga.fromJson(Map<String, dynamic> json) {
    return MovieHarga(
      priceIDR: json['priceIDR'] ?? 'IDR',
      rates: (json['rates'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

}