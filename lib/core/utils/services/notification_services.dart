import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

Future<void> messageBackHandler(RemoteMessage message) async {
  print('background message $message');
}

class NotificationServices {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  initializeNotification() async {
    await _firebaseMessaging.requestPermission();

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'NOTIF_ID',
      'NOTIF_NAME',
      importance: Importance.high,
    );
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: (details) {},
    );
    _firebaseMessaging.getInitialMessage().then((message) {
      // Handle the notification when the app is closed
    });

    FirebaseMessaging.onMessage.listen((message) {
      AndroidNotificationDetails androidNotificationDetails =
          const AndroidNotificationDetails('NOTIF_ID', 'NOTIF_NAME');
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      notificationPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Handle the notification when the app is in background
    });
  }

  Future<AccessCredentials> _getAccessToken() async {
    String serviceAccountPath = 'google_services/notification_key.json';

    String serviceAccountJson = await rootBundle.loadString(
      serviceAccountPath,
    );
    final serviceAccount = ServiceAccountCredentials.fromJson(
      serviceAccountJson,
    );

    final scopes = <String>[
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      serviceAccount,
      scopes,
    );
    return client.credentials;
  }

  Future sendNotification(
      {required String deviceToken,
      required String title,
      required String body}) async {
    try {
      final credentials = await _getAccessToken();
      final accessToken = credentials.accessToken.data;
      final url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/chat-app-41a9a/messages:send');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final payload = jsonEncode({
        'message': {
          'token': deviceToken,
          'notification': {
            'body': body,
            'title': title,
          },
        },
      });
      final response = await http.post(
        url,
        headers: headers,
        body: payload,
      );
      print(response.statusCode);
    } catch (e) {}
  }
}
