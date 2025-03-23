import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ss_navbar.dart';

class HistoryPage extends StatelessWidget {
  final String section;

  const HistoryPage({super.key, required this.section});

  Future<List<Map<String, String>>> fetchPastEmployees(String section) async {
    // Normalize the section value for consistency
    String normalizedSection = section.trim().toLowerCase();
    print('Fetching employees for section: $normalizedSection'); // Debugging

    QuerySnapshot transferSnapshot = await FirebaseFirestore.instance
        .collection('section_history')
        .where('old_section', isEqualTo: normalizedSection)
        .get();

    QuerySnapshot retirementSnapshot = await FirebaseFirestore.instance
        .collection('retirement_history')
        .where('section', isEqualTo: normalizedSection)
        .get();

    print(
        'Transfer documents found: ${transferSnapshot.docs.length}'); // Debugging
    print(
        'Retirement documents found: ${retirementSnapshot.docs.length}'); // Debugging

    List<Map<String, String>> pastEmployees = [];

    for (var doc in transferSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      String employeeId = data['employee_id'].toString(); // Ensure it's String
      String newSection = data['new_section'] ?? 'Unknown';
      String transferDate = (data['transfer_date'] != null)
          ? (data['transfer_date'] as Timestamp).toDate().toString()
          : 'No Date';

      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('id', isEqualTo: employeeId)
          .get();
      String employeeName = employeeSnapshot.docs.isNotEmpty
          ? employeeSnapshot.docs.first['name']
          : 'Unknown';

      print(
          'Employee: $employeeName, New Section: $newSection, Transfer Date: $transferDate');

      pastEmployees.add({
        'employee_id': employeeId,
        'employee_name': employeeName,
        'new_section': newSection,
        'transfer_date': transferDate,
      });
    }

    for (var doc in retirementSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      String employeeId = data['employee_id'].toString(); // Ensure it's String
      String retirementDate = (data['retirement_date'] != null)
          ? (data['retirement_date'] as Timestamp).toDate().toString()
          : 'No Date';

      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('id', isEqualTo: employeeId)
          .get();
      String employeeName = employeeSnapshot.docs.isNotEmpty
          ? employeeSnapshot.docs.first['name']
          : 'Unknown';

      print('Employee: $employeeName, Retirement Date: $retirementDate');

      pastEmployees.add({
        'employee_id': employeeId,
        'employee_name': employeeName,
        'new_section': 'Retired',
        'transfer_date': retirementDate,
      });
    }

    return pastEmployees;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Employees'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        automaticallyImplyLeading: true, // Ensure the back button is shown
        foregroundColor: Colors.white,
      ),
      drawer: SSNavbar(
        section: section,
        currentPage: "Past employees",
      ), // Pass the section to SSNavbar
      body: FutureBuilder<List<Map<String, String>>>(
        future: fetchPastEmployees(section),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No past employees found in this section.'));
          } else {
            final pastEmployees = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: pastEmployees.map((employee) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Employee Name: ${employee['employee_name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('New Section: ${employee['new_section']}'),
                        Text('Transfer Date: ${employee['transfer_date']}'),
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
