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
  final TextEditingController _passwordController = TextEditingController();
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

        // Hash the password
        var bytes = utf8.encode(_passwordController.text); // data being hashed
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
          const SnackBar(content: Text('Employee added successfully.')),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'Employee ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an employee ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
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
                  ),
                ),
                dropdownBuilder: (context, selectedItem) {
                  return Text(selectedItem ?? '');
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
              ),
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
                  ),
                ),
                dropdownBuilder: (context, selectedItem) {
                  return Text(selectedItem ?? '');
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Add Employee'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
