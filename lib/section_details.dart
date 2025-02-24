import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SectionDetailsPage extends StatelessWidget {
  final String sectionId;

  const SectionDetailsPage({super.key, required this.sectionId});

  Future<List<Map<String, dynamic>>> _fetchEmployees() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('employees')
        .where('section', isEqualTo: sectionId)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents
        .map((doc) => {
              'id': doc['id'],
              'name': doc['name'],
              'designation': doc['designation']
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section Details'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEmployees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No employees found.'));
          } else {
            final employees = snapshot.data ?? [];
            return ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(employee['name'][0]),
                    ),
                    title: Text(employee['name']),
                    subtitle: Text(employee['designation']),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
