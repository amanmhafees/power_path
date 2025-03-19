import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class SSTransferPage extends StatefulWidget {
  const SSTransferPage({super.key});

  @override
  _SSTransferPageState createState() => _SSTransferPageState();
}

class _SSTransferPageState extends State<SSTransferPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployeeId;
  String? _selectedNewSectionId;
  String _errorMessage = '';

  Future<List<Map<String, dynamic>>> _fetchSystemSupervisors() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('employees')
        .where('designation', isEqualTo: 'System Supervisor')
        .get();
    return result.docs
        .map((doc) => {'id': doc['id'], 'name': doc['name']})
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchSections() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('sections').get();
    return result.docs
        .map((doc) => {
              'id': doc['id'],
              'section_name': doc['section_name'],
              'section_id': doc['id']
            })
        .toList();
  }

  Future<void> _transferSS() async {
    if (_selectedEmployeeId == null || _selectedNewSectionId == null) {
      setState(() {
        _errorMessage =
            'Please select both a system supervisor and a new section';
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
      final oldSection = doc['section'];

      await FirebaseFirestore.instance
          .collection('employees')
          .doc(doc.id)
          .update({
        'section': _selectedNewSectionId,
      });

      await FirebaseFirestore.instance.collection('section_history').add({
        'employee_id': _selectedEmployeeId,
        'old_section': oldSection,
        'new_section': _selectedNewSectionId,
        'transfer_date': Timestamp.now(),
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
        title: const Text('SS Transfer'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchSystemSupervisors(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final supervisors = snapshot.data!;
                  return DropdownSearch<Map<String, dynamic>>(
                    items: supervisors,
                    itemAsString: (item) => '${item['name']} (${item['id']})',
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployeeId = value?['id'];
                      });
                    },
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'System Supervisor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a system supervisor';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchSections(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final sections = snapshot.data!;
                  return DropdownSearch<Map<String, dynamic>>(
                    items: sections,
                    itemAsString: (item) => item['section_name'],
                    onChanged: (value) {
                      setState(() {
                        _selectedNewSectionId = value?['id'];
                      });
                    },
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'New Section',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a new section';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _transferSS,
                child: const Text('Transfer SS'),
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
