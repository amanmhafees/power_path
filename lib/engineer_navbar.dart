import 'package:flutter/material.dart';
import 'login.dart'; // Import the LoginPage

class EngineerNavbar extends StatelessWidget {
  final String userName;

  const EngineerNavbar({super.key, required this.userName});

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
              Navigator.pop(context);
              // Navigate to Home
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add New Transformer'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Add New Transformer
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Sections'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Sections
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
