// Sample code for a widget to show the new transformer page

import 'package:flutter/material.dart';
import 'engineer_navbar.dart'; // Import the EngineerNavbar

class AddTransformer extends StatelessWidget {
  final String section;
  final String userName;

  const AddTransformer(
      {super.key, required this.section, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transformer'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: EngineerNavbar(
          userName: userName,
          section: section), // Pass the necessary parameters to EngineerNavbar
      body: Center(
        child: Text(
          'Add Transformer Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
