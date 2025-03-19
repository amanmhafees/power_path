import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransformerMaintenanceDetailsPage extends StatelessWidget {
  final String transformerId;
  final String transformerName;
  final String userName;
  final String section;

  const TransformerMaintenanceDetailsPage(
      {super.key,
      required this.transformerId,
      required this.transformerName,
      required this.userName,
      required this.section});

  Future<List<Map<String, dynamic>>> _fetchMaintenanceRecords() async {
    final DocumentSnapshot transformerDoc = await FirebaseFirestore.instance
        .collection('transformers')
        .doc(transformerId)
        .get();
    final List<dynamic> maintenanceRecords =
        transformerDoc['maintenanceRecords'] ?? [];
    return maintenanceRecords
        .map((record) => {
              'date': (record['date'] as Timestamp).toDate(),
              'details': record['details']
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maintenance Records for $transformerName'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true, // Include the back button
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMaintenanceRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No maintenance records found.'));
          } else {
            final maintenanceRecords = snapshot.data!;
            maintenanceRecords.sort((a, b) => b['date'].compareTo(a['date']));
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: maintenanceRecords.length,
              itemBuilder: (context, index) {
                final record = maintenanceRecords[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    child: ListTile(
                      title: Text(
                          'Date: ${record['date'].toLocal().toString().split(' ')[0]}'),
                      subtitle: Text('Details: ${record['details']}'),
                    ),
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
