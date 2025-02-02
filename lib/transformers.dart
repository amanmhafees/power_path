import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'engineer_navbar.dart'; // Import the EngineerNavbar
import 'workers_navbar.dart'; // Import the WorkerNavbar
import 'login.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userType;

  const HomePage({super.key, required this.userName, required this.userType});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> transformers = [
    {'name': 'Transformer 1', 'status': 'active'},
    {'name': 'Transformer 2', 'status': 'inactive'},
    {'name': 'Transformer 3', 'status': 'under maintenance'},
    {'name': 'Transformer 4', 'status': 'inactive'},
    {'name': 'Transformer 5', 'status': 'active'},
    {'name': 'Transformer 6', 'status': 'inactive'},
    {'name': 'Transformer 7', 'status': 'active'},
    {'name': 'Transformer 8', 'status': 'active'},
    {'name': 'Transformer 9', 'status': 'active'},
    {'name': 'Transformer 10', 'status': 'active'},
    {'name': 'Transformer 11', 'status': 'active'},
    {'name': 'Transformer 12', 'status': 'active'},
    {'name': 'Transformer 13', 'status': 'active'},
    {'name': 'Transformer 14', 'status': 'active'},
    {'name': 'Transformer 15', 'status': 'active'},
    {'name': 'Transformer 16', 'status': 'active'},
    {'name': 'Transformer 17', 'status': 'active'},
    {'name': 'Transformer 18', 'status': 'active'},
    {'name': 'Transformer 19', 'status': 'active'},
    {'name': 'Transformer 20', 'status': 'active'},
    {'name': 'Transformer 21', 'status': 'active'},
    // Add more transformers as needed
  ];
  List<Map<String, String>> filteredTransformers = [];

  @override
  void initState() {
    super.initState();
    filteredTransformers = transformers;
    _searchController.addListener(_filterTransformers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTransformers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterTransformers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredTransformers = transformers.where((transformer) {
        final name = transformer['name']!.toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0); // Close the app
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transformers'),
          automaticallyImplyLeading: true, // Enable the default back button
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
          backgroundColor: Colors.blue.shade700,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        drawer: widget.userType == 'engineer'
            ? EngineerNavbar(userName: widget.userName)
            : WorkerNavbar(
                userName: widget.userName), // Add the appropriate NavBar here
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Hide the keyboard
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Transformers',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(), // Ensure smooth scrolling
                  itemCount: filteredTransformers.length,
                  itemBuilder: (context, index) {
                    final transformer = filteredTransformers[index];
                    final String name = transformer['name'] as String;
                    final String status = transformer['status'] as String;
                    Color badgeColor;

                    switch (status) {
                      case 'active':
                        badgeColor = Colors.green;
                        break;
                      case 'inactive':
                        badgeColor = Colors.red;
                        break;
                      case 'under maintenance':
                        badgeColor = Colors.grey;
                        break;
                      default:
                        badgeColor = Colors.black;
                    }

                    return ListTile(
                      title: Text(name),
                      trailing: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
