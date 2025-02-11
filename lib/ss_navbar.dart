import 'package:flutter/material.dart';
import 'login.dart'; // Import the LoginPage
import 'transfer.dart'; // Import the TransferPage
import 'history.dart'; // Import the HistoryPage
import 'ss_home.dart'; // Import the SSHomePage

class SSNavbar extends StatelessWidget {
  final String section;

  const SSNavbar({super.key, required this.section});

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
            child: const Text(
              'Navigation Menu',
              style: TextStyle(
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SSHomePage(section: section),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.transfer_within_a_station),
            title: const Text('Transfer'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransferPage(supervisorSection: section),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_ind),
            title: const Text('Retirement'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Retirement
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Past employees'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(section: section),
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
