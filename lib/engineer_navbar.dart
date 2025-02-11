import 'package:flutter/material.dart';
import 'login.dart'; // Import the LoginPage
import 'add_transformer.dart';
import 'home.dart'; // Import the HomePage

class EngineerNavbar extends StatelessWidget {
  final String userName;
  final String section;

  const EngineerNavbar(
      {super.key, required this.userName, required this.section});

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
            ),
            child: Text(
              'Welcome, $userName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Navigate to HomePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    userName: userName,
                    userType: 'engineer', // Assuming the userType is 'engineer'
                    section: section,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add New Transformer'),
            onTap: () {
              // Navigate to Add New Transformer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddTransformer(section: section, userName: userName),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Sections'),
            onTap: () {
              // Navigate to Sections
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    userName: userName,
                    userType: 'engineer', // Assuming the userType is 'engineer'
                    section: section,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}
