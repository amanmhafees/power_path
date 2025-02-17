import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_employee.dart'; // Import the AddEmployeePage
import 'login.dart'; // Import the LoginPage

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all session data

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEmployeePage()),
            );
          },
          child: const Text('Add New Employee'),
        ),
      ),
    );
  }
}
