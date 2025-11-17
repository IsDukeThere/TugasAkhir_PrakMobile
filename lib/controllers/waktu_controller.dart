import 'package:project_akhir/model/waktu_tayang.dart';
import 'package:project_akhir/services/waktu_service.dart';

class ShowtimeController {
  String getConvertedShowtime(WaktuTayang showtime, String zone) {
    final waktuService = WaktuService(showTimeUtc: showtime.showTimeUtc);
    return waktuService.convertToZone(zone);
  }

  List<String> getAvailableZones() {
    return WaktuService(showTimeUtc: DateTime.now()).availableZones;
  }
}