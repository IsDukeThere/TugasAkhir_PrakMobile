import 'dart:convert';

import 'package:http/http.dart' as http;

class UangService {
  final String api = "https://api.exchangerate-api.com/v4/latest/IDR";
  final String apiKey = "477afcf519f72f7ba0d93ec3";

  Future<Map<String, double>> fetchRates() async {
    final response  = await http.get(Uri.parse("$api?apikey=$apiKey"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;
      return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } else {
      throw Exception('Gagal mengambil kurs mata uang');
    }
  }

}