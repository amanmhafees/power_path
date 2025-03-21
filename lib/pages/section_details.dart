import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SectionDetailsPage extends StatefulWidget {
  final String sectionId;

  const SectionDetailsPage({super.key, required this.sectionId});

  @override
  State<SectionDetailsPage> createState() => _SectionDetailsPageState();
}

class _SectionDetailsPageState extends State<SectionDetailsPage> {
  late Future<Map<String, dynamic>> _sectionFuture;
  late Future<List<Map<String, dynamic>>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _sectionFuture = _fetchSectionDetails();
    _employeesFuture = _fetchEmployees();
  }

  Future<Map<String, dynamic>> _fetchSectionDetails() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('sections')
        .where('id', isEqualTo: widget.sectionId)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isNotEmpty) {
      final doc = documents.first;
      return {
        'id': doc['id'],
        'name': doc['section_name'],
      };
    } else {
      return {'id': widget.sectionId, 'name': 'Unknown Section'};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEmployees() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('employees')
        .where('section', isEqualTo: widget.sectionId)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents
        .map((doc) => {
              'id': doc['id'],
              'name': doc['name'],
              'designation': doc['designation'],
              'employeeId':
                  doc['id'], // Fetch the employee ID from the document
              'documentId': doc.id, // Store the document ID
            })
        .toList();
  }

  Future<void> _refreshData() async {
    setState(() {
      _sectionFuture = _fetchSectionDetails();
      _employeesFuture = _fetchEmployees();
    });
  }

  Future<void> _resetPassword(String documentId) async {
    final String newPassword = 'Temp@123';
    final String hashedPassword =
        sha256.convert(utf8.encode(newPassword)).toString();

    await FirebaseFirestore.instance
        .collection('employees')
        .doc(documentId)
        .update({'password': hashedPassword});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset to Temp@123')),
    );
  }

  void _showResetPasswordDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: const Text(
              'Are you sure you want to reset the password for this employee?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _resetPassword(documentId);
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: FutureBuilder<Map<String, dynamic>>(
          future: _sectionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading section...');
            } else if (snapshot.hasError) {
              return const Text('Section Details');
            } else {
              final section = snapshot.data ?? {'name': 'Section Details'};
              return Text(
                section['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              );
            }
          },
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _sectionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text(
                    'Error loading section details',
                    style: TextStyle(color: Colors.white),
                  );
                } else {
                  final section = snapshot.data ?? {'name': 'Unknown Section'};
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.people_alt,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Section Employees',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _employeesFuture,
                                builder: (context, snapshot) {
                                  final count = snapshot.data?.length ?? 0;
                                  return Text(
                                    '$count Employees',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _employeesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          color: Colors.grey[400],
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No employees found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This section has no employees assigned yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final employees = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        final Color cardColor =
                            Colors.primaries[index % Colors.primaries.length];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: cardColor,
                                  child: Text(
                                    employee['name'][0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${employee['employeeId']}', // Display the employee ID
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          employee['designation'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.lock_reset),
                                  onPressed: () => _showResetPasswordDialog(
                                      employee['documentId']),
                                  tooltip: 'Reset Password',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add employee page with pre-selected section
          // You can implement this functionality later
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.person_add),
        tooltip: 'Add Employee to Section',
      ),
    );
  }
}
