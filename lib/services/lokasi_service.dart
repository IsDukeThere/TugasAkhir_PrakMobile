import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LokasiService {
  static Future<Map<String, dynamic>> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    
    String countryCode = placemarks.first.isoCountryCode ?? 'US';
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'country': countryCode,
    };
  }   
}