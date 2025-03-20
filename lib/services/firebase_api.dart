import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Function to initialize notifications
  Future<void> initNotifications() async {
    // Request permission from user (will prompt user)
    await _firebaseMessaging.requestPermission();

    // Fetch the FCM token for this device
    final FCMToken = await _firebaseMessaging.getToken();

    // Printing token, normally you would send this to your server
    print("FCM Token: $FCMToken");

    // Initialize push notifications
    await initPushNotification();
  }

  // Function to handle received messages
  Future<void> initPushNotification() async {
    // Handle notification if the app was terminated and now opened
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print("Message received on app launch: ${message.notification?.title}");
      }
    });

    // Foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received in foreground: ${message.notification?.title}");
    });

    // Background message
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked!");
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
  }
}
