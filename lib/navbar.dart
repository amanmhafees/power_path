/*import 'package:flutter/material.dart';
import 'package:power_path/profile.dart';

class NavBar extends StatelessWidget {
  final String userName;
  final String userType;

  const NavBar({super.key, required this.userName, required this.userType});

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
              'Power Path',
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
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.layers),
            title: const Text('Select Section'),
            onTap: () {
              Navigator.pushNamed(context, '/sections');
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    userName: userName,
                    userType: userType,
                  ),
                ),
              ); // Navigate to EditProfilePage with parameters
            },
          ),
        ],
      ),
    );
  }
}
*/
