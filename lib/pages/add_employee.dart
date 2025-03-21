import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> sections = [];
  List<String> designations = [];
  String? selectedSection;
  String? selectedDesignation;

  @override
  void initState() {
    super.initState();
    _fetchSections();
    _fetchDesignations();
  }

  Future<void> _fetchSections() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('sections').get();
    final List<DocumentSnapshot> documents = result.docs;
    setState(() {
      sections = documents.map((doc) => doc['section_name'] as String).toList();
    });
  }

  Future<void> _fetchDesignations() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('designation').get();
    final List<DocumentSnapshot> documents = result.docs;
    setState(() {
      designations =
          documents.map((doc) => doc['designation'] as String).toList();
    });
  }

  Future<bool> _checkIfUserIdExists(String userId) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('employees')
        .where('id', isEqualTo: userId)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  Future<String?> _getSectionIdByName(String sectionName) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('sections')
        .where('section_name', isEqualTo: sectionName)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return documents.first['id'];
    }
    return null;
  }

  void _submitForm() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      bool userIdExists = await _checkIfUserIdExists(_idController.text);
      if (userIdExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('User ID already exists. Please enter another ID.')),
        );
      } else {
        String? sectionId = await _getSectionIdByName(selectedSection!);
        if (sectionId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected section does not exist.')),
          );
          return;
        }

        // Set default password to Temp@123 and hash it
        var bytes = utf8.encode('Temp@123'); // data being hashed
        var digest = sha256.convert(bytes);

        // Save to database
        FirebaseFirestore.instance.collection('employees').add({
          'id': _idController.text,
          'name': _nameController.text,
          'password': digest.toString(),
          'section': sectionId,
          'designation': selectedDesignation,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Employee added successfully. Default password is Temp@123')),
        );
        form.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Employee Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _idController,
                          decoration: InputDecoration(
                            labelText: 'Employee ID',
                            prefixIcon:
                                const Icon(Icons.badge, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an employee ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon:
                                const Icon(Icons.person, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Department Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownSearch<String>(
                          items: sections,
                          onChanged: (value) {
                            setState(() {
                              selectedSection = value;
                            });
                          },
                          selectedItem: selectedSection,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a section';
                            }
                            return null;
                          },
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Section',
                              prefixIcon:
                                  Icon(Icons.business, color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          dropdownBuilder: (context, selectedItem) {
                            return Text(selectedItem ?? '');
                          },
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownSearch<String>(
                          items: designations,
                          onChanged: (value) {
                            setState(() {
                              selectedDesignation = value;
                            });
                          },
                          selectedItem: selectedDesignation,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a designation';
                            }
                            return null;
                          },
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Designation',
                              prefixIcon: Icon(Icons.work, color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          dropdownBuilder: (context, selectedItem) {
                            return Text(selectedItem ?? '');
                          },
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Add Employee',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
