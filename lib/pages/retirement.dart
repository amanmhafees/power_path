import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../widgets/ss_navbar.dart'; // Import the SSNavbar

class RetirementPage extends StatefulWidget {
  final String supervisorSection;

  const RetirementPage({super.key, required this.supervisorSection});

  @override
  _RetirementPageState createState() => _RetirementPageState();
}

class _RetirementPageState extends State<RetirementPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployeeId;
  String _errorMessage = '';

  Future<List<Map<String, dynamic>>> _fetchEmployees() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('employees')
        .where('section', isEqualTo: widget.supervisorSection)
        .get();
    return result.docs
        .map((doc) => {'id': doc['id'], 'name': doc['name']})
        .toList();
  }

  Future<void> _retireEmployee() async {
    if (_selectedEmployeeId == null) {
      setState(() {
        _errorMessage = 'Please select an employee';
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('id', isEqualTo: _selectedEmployeeId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Employee ID does not exist';
        });
        return;
      }

      final doc = querySnapshot.docs.first;

      await FirebaseFirestore.instance
          .collection('employees')
          .doc(doc.id)
          .update({
        'status': 'retired',
      });

      await FirebaseFirestore.instance.collection('retirement_history').add({
        'employee_id': _selectedEmployeeId,
        'section': widget.supervisorSection,
        'retirement_date': Timestamp.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirement'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: SSNavbar(
        section: widget.supervisorSection,
        currentPage: "Retirement",
      ), // Add the SSNavbar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchEmployees(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final employees = snapshot.data!;
                  return DropdownSearch<Map<String, dynamic>>(
                    items: employees,
                    itemAsString: (item) => '${item['name']} (${item['id']})',
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployeeId = value?['id'];
                      });
                    },
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Employee',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an employee';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _retireEmployee,
                child: const Text('Retire Employee'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
