import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../widgets/ss_navbar.dart';

class TransferPage extends StatefulWidget {
  final String supervisorSection;

  const TransferPage({super.key, required this.supervisorSection});

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> sections = [];
  List<Map<String, dynamic>> employees = [];
  Map<String, dynamic>? selectedEmployee;
  String? selectedNewSection;

  @override
  void initState() {
    super.initState();
    _fetchSections();
    _fetchEmployees();
  }

  Future<void> _fetchSections() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('sections').get();
      final List<String> fetchedSections =
          snapshot.docs.map((doc) => doc['section_name'] as String).toList();
      setState(() {
        sections = fetchedSections;
      });
    } catch (e) {
      print('Error fetching sections: $e');
    }
  }

  Future<void> _fetchEmployees() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('section', isEqualTo: widget.supervisorSection)
          .get();
      final List<Map<String, dynamic>> fetchedEmployees = snapshot.docs
          .map((doc) => {
                'id': doc[
                    'id'], // Assuming the employee ID is stored in the 'id' field
                'name': doc['name'],
                'section': doc['section']
              })
          .toList();
      setState(() {
        employees = fetchedEmployees;
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  Future<void> _transferEmployee() async {
    if (selectedEmployee == null || selectedNewSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an employee and a new section')),
      );
      return;
    }

    try {
      // Fetch the section document based on the selected section name
      final QuerySnapshot sectionSnapshot = await FirebaseFirestore.instance
          .collection('sections')
          .where('section_name', isEqualTo: selectedNewSection)
          .limit(1)
          .get();

      if (sectionSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New section not found')),
        );
        return;
      }

      final DocumentSnapshot sectionDoc = sectionSnapshot.docs.first;
      final String newSectionId =
          sectionDoc['id']; // Get the id value inside the document

      final QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('id', isEqualTo: selectedEmployee?['id'])
          .get();

      if (employeeSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee not found')),
        );
        return;
      }

      final DocumentSnapshot employeeDoc = employeeSnapshot.docs.first;
      final String currentSection = employeeDoc['section'];
      final DateTime now = DateTime.now();

      // Update the employee's section with the new section ID
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeDoc.id)
          .update({'section': newSectionId});

      // Add to section history
      await FirebaseFirestore.instance.collection('section_history').add({
        'employee_id': selectedEmployee?['id'],
        'section': currentSection,
        'new_section': newSectionId,
        'transfer_date': now,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee transferred successfully')),
      );

      // Clear the selection and refresh the employee list
      setState(() {
        selectedEmployee = null;
        selectedNewSection = null;
      });
      _fetchEmployees(); // Refresh the employee list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Back button is disabled. Use the menu.')),
        );
        return false; // Prevent the back button from working
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transfer Employee'),
          automaticallyImplyLeading: false, // Disable the back button
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: SSNavbar(
            section: widget.supervisorSection), // Pass the section to SSNavbar
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownSearch<Map<String, dynamic>>(
                items: employees,
                itemAsString: (Map<String, dynamic> employee) =>
                    "${employee['name']} (ID: ${employee['id']})",
                selectedItem: selectedEmployee,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Select Employee',
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: const InputDecoration(
                      labelText: 'Search by name or ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  itemBuilder: (context, item, isSelected) {
                    return ListTile(
                      title: Text("${item['name']} (ID: ${item['id']})"),
                    );
                  },
                ),
                onChanged: (value) {
                  setState(() {
                    selectedEmployee = value;
                  });
                },
                filterFn: (employee, filter) {
                  return employee['name']
                          .toString()
                          .toLowerCase()
                          .contains(filter.toLowerCase()) ||
                      employee['id'].toString().contains(filter);
                },
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>(
                items: sections,
                selectedItem: selectedNewSection,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'New Section',
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                onChanged: (value) {
                  setState(() {
                    selectedNewSection = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _transferEmployee,
                child: const Text('Transfer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
