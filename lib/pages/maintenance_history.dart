import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/engineer_navbar.dart'; // Import the EngineerNavbar
import 'transformers_maintenance_details.dart'; // Import the TransformerMaintenanceDetailsPage

// Define a custom color scheme
class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1976D2);
  static const Color grey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
  static const Color greyBadge = Color(0xFF9E9E9E);
}

class MaintenanceDetailsPage extends StatelessWidget {
  final String section;
  final String userName;

  const MaintenanceDetailsPage(
      {super.key, required this.section, required this.userName});

  Future<List<Map<String, dynamic>>> _fetchTransformers() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('transformers')
        .where('section', isEqualTo: section)
        .get();
    return result.docs
        .map((doc) =>
            {'id': doc.id, 'name': doc['name'], 'status': doc['status']})
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.green;
      case 'Inactive':
        return AppColors.red;
      case 'Under Maintenance':
        return AppColors.greyBadge;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Details'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: EngineerNavbar(
        userName: userName,
        section: section,
        currentPage: 'Maintenance Details',
      ), // Add the navbar
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransformers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transformers found.'));
          } else {
            final transformers = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: transformers.length,
              itemBuilder: (context, index) {
                final transformer = transformers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransformerMaintenanceDetailsPage(
                            transformerId: transformer['id'],
                            transformerName: transformer['name'],
                            userName: userName,
                            section: section,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.electric_bolt,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              transformer['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(transformer['status']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              transformer['status'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.primaryBlue,
                            size: 14,
                          ),
                        ],
                      ),
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
