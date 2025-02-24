import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_employee.dart'; // Import the AddEmployeePage
import 'login.dart'; // Import the LoginPage
import 'section_details.dart'; // Import the SectionDetailsPage
import 'admin_navbar.dart'; // Import the AdminNavbar
import 'add_section.dart'; // Import the AddSectionPage

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all session data

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSections() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('sections').get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents
        .map((doc) => {'id': doc['id'], 'name': doc['section_name']})
        .toList();
  }

  Future<void> _refreshSections() async {
    setState(() {});
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
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSections,
          ),
        ],
      ),
      drawer: const AdminNavbar(), // Use the AdminNavbar
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sections found.'));
          } else {
            final sections = snapshot.data!;
            return ListView.builder(
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(section['name'][0]),
                    ),
                    title: Text(section['name']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SectionDetailsPage(sectionId: section['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSectionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
