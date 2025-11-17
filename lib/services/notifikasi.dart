// import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project_akhir/main.dart';

Future<void> requestNotificationPermission() async {
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestNotificationsPermission();
}



Future<void> showNotification(String title) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'watchlist_channel',
    'Watchlist',
    channelDescription: 'notifikasi watchlist film baru',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    "Watchlist Baru!",
    "'$title' telah ditambahkan ke watchlist",
    notificationDetails,
  );
}

//Belum di implementasikan

// Future<void> callbackNotifikasi() async {
//   log('Alarm callback triggered');
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'film_new_channel',
//     'Film Baru',
//     channelDescription: 'Channel untuk notifikasi film baru',
//     importance: Importance.high,
//     priority: Priority.high,
//   );

//   const NotificationDetails notificationDetails =
//       NotificationDetails(android: androidDetails);

//   await flutterLocalNotificationsPlugin.periodicallyShow(
//     0,
//     'Film baru tersedia!',
//     'Cek daftar film terbaru sekarang.',
//     RepeatInterval.everyMinute,
//     notificationDetails,
//   );
// }
