import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/firebase_options.dart'; // Import the generated options file
import 'pages/login.dart';
import 'pages/home.dart';
import 'admin/admin_home.dart'; // Import the AdminHomePage
import 'pages/ss_home.dart'; // Import the SSHomePage
import 'services/notification_service.dart'; // Import the NotificationService
import 'services/fcm_service.dart'; // Import the FcmService
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /*Future<void> init(BuildContext context) async {
    NotificationService().requestNotificationPermission();
    await NotificationService().getDeviceToken();
    NotificationService().firebaseInit(context);
    NotificationService().setupInteractMessage(context);
    FcmService.firebaseInit();
  }*/

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isAdmin = prefs.getBool('isAdmin') ?? false;

    if (isLoggedIn) {
      if (isAdmin) {
        return const AdminHomePage();
      } else {
        final designation = prefs.getString('designation') ?? '';
        final section = prefs.getString('section') ?? '';
        final name = prefs.getString('name') ?? '';

        if (designation == 'System Supervisor') {
          return SSHomePage(section: section);
        } else {
          return HomePage(
            userName: name,
            userType: designation.toLowerCase().contains('engineer')
                ? 'engineer'
                : 'worker',
            section: section,
          );
        }
      }
    } else {
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    //init(context); // Initialize notification settings

    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          return MaterialApp(
            title: 'PowerPath',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            debugShowCheckedModeBanner: false, // Remove the debug banner
            home: snapshot.data,
          );
        }
      },
    );
  }
}
