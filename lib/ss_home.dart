import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart'; // Import the LoginPage

class SSHomePage extends StatelessWidget {
  final String section;

  const SSHomePage({super.key, required this.section});

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<Map<String, List<Map<String, String>>>> fetchEmployees(
      String section) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('section', isEqualTo: section)
        .get();

    Map<String, List<Map<String, String>>> employeesByDesignation = {};

    for (var doc in snapshot.docs) {
      String designation = doc['designation'];
      String name = doc['name'];

      if (!employeesByDesignation.containsKey(designation)) {
        employeesByDesignation[designation] = [];
      }

      employeesByDesignation[designation]!.add({'name': name});
    }

    return employeesByDesignation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Supervisor Home Page'),
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
      body: FutureBuilder<Map<String, List<Map<String, String>>>>(
        future: fetchEmployees(section),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No employees found in this section.'));
          } else {
            final employeesByDesignation = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: employeesByDesignation.entries.map((entry) {
                final designation = entry.key;
                final employees = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$designation (${employees.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...employees.map((employee) {
                          return Text(employee['name']!);
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
