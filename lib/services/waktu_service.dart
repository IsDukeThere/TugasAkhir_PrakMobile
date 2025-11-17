import 'package:intl/intl.dart';

class WaktuService {
  final DateTime showTimeUtc;

  WaktuService({required this.showTimeUtc});

  static const Map<String, int> _zoneOffsets = {
    "WIB": 7,
    "WITA": 8,
    "WIT": 9,
    "London": 0,
  };

  String convertToZone(String zone) {
    final offset = _zoneOffsets[zone] ?? 0;
    final convertedTime = showTimeUtc.add(Duration(hours: offset));
    return DateFormat('HH:mm').format(convertedTime);
  }

  List<String> get availableZones => _zoneOffsets.keys.toList();
}