import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('cma_stock_logo');

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
    required List<String> inboxLines,
  }) async {
    // set up notifications details
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id', // Must be unique
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: InboxStyleInformation(
        inboxLines.length > 1 ? inboxLines : [body ?? ''],
        contentTitle: title,
      ),
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // show notification
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
