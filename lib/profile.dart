import 'package:flutter/material.dart';
import 'package:power_path/home.dart';

class EditProfilePage extends StatelessWidget {
  final String userName;
  final String userType;

  const EditProfilePage(
      {super.key, required this.userName, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  userName: userName,
                  userType: userType,
                ),
              ),
            ); // Navigate back to the HomePage with parameters
          },
        ),
      ),
      body: Center(
        child: Text(
          'Edit Profile Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
