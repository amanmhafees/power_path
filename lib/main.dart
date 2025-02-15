import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; // Import the generated options file
import 'login.dart';
import 'home.dart';
import 'admin_home.dart'; // Import the AdminHomePage
import 'ss_home.dart'; // Import the SSHomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
