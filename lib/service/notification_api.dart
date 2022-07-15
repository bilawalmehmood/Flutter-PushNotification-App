import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pushnotification/res/constants.dart';
import 'package:http/http.dart' as http;

class NotificationApi {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> sendNotification({
    required String? deviceToken,
    required String title,
    required String description,
    required String page,
  }) async {
    if (deviceToken == null) {
      return;
    }
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Authorization': 'key=${Constants.firebaseServerKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "to": deviceToken,
        "notification": {
          "sound": "default",
          "body": description,
          "title": title,
          "content_available": true,
          "priority": "high"
        },
        "data": {
          "page": page,
        }
      }),
    );
  }

  static void registerNotification() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    // On iOS, this helps to take the user permissions
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // When the app is open and running
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null &&
            message.notification!.title != null &&
            message.notification!.body != null &&
            message.data['page'] != null) {
          sendLocalNotification(message.notification!.title!,
              message.notification!.body!, message.data['page']);
        }
      });
    }
  }

  static void initLocalNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings initializationSettingsIOS =
        const IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void sendLocalNotification(
      String title, String body, String page) async {
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      '1',
      'pushnotificationapp',
      channelDescription: 'Channel Description',
    );

    IOSNotificationDetails iosDetails = const IOSNotificationDetails();

    NotificationDetails generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      generalNotificationDetails,
      payload: page,
    );
  }
}
