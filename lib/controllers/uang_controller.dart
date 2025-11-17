import 'package:intl/intl.dart';
import 'package:project_akhir/services/uang_service.dart';

class UangController {
  final UangService apiService = UangService();
  Map<String, double>? _rates;

  Future<void> intiRates() async {
    _rates = await apiService.fetchRates();
  }

  String convert(double amountIDR, String currency) {
    if (_rates == null) {
      return '...';
    }
    double rate = _rates![currency] ?? 1.0;
    double converted = amountIDR * rate;
    switch (currency) {
      case 'USD':
        return '\$${converted.toStringAsFixed(2)}';
      case 'GBP':
        return '£${converted.toStringAsFixed(2)}';
      default:
        final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
        return format.format(amountIDR);
    }
  }

  List<String> get availableCurrencies => ['IDR','USD','GBP'];

}