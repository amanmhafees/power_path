/*import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // Import kDebugMode
import 'package:power_path/main.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      Get.snackbar(
          'Permission Denied', 'Please enable notifications in settings');
      Future.delayed(Duration(seconds: 2), () {
        openAppSettings();
      });
    }
  }

  // Get device token
  Future<String> getDeviceToken() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    String? token = await messaging.getToken();
    print("token=> $token");
    return token!;
  }

  // Initialize local notifications
  Future<void> initlocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidinitSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosinitSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidinitSettings,
      iOS: iosinitSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification response
        handleMessage(context, message);
      },
    );
  }

  // Firebase initialization
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen(
      (message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (kDebugMode) {
          print("Notification Title: ${notification!.title}");
          print("Notification Body: ${notification.body}");
        }
        //ios
        if (Platform.isIOS) {
          iosForgroundMessage();
        }
        //android
        if (Platform.isAndroid) {
          initlocalNotification(context, message);
          showNotification(message);
        }
      },
    );
  }

  // Function to show notification
  Future<void> showNotification(RemoteMessage message) async {
    if (message.notification?.android != null) {
      AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId ?? 'default_channel_id',
        "PowerPath",
        importance: Importance.high,
        showBadge: true,
        playSound: true,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        showWhen: false,
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      );
    }
  }

  // Background and terminated state
  Future<void> setupInteractMessage(BuildContext context) async {
    // Background state
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        handleMessage(context, message);
      },
    );

    // Terminated state
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message != null && message.data.isNotEmpty) {
          handleMessage(context, message);
        }
      },
    );
  }

  // Handle message
  Future<void> handleMessage(
      BuildContext context, RemoteMessage message) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
  }

  // Handle iOS foreground messages
  Future iosForgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
*/
