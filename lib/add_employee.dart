import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

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

  Future<void> _fetchDesignations() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('designation').get();
      final List<String> fetchedDesignations =
          snapshot.docs.map((doc) => doc['designation'] as String).toList();
      setState(() {
        designations = fetchedDesignations;
      });
    } catch (e) {
      print('Error fetching designations: $e');
    }
  }

  Future<bool> _isIdUnique(String id) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('id', isEqualTo: id)
        .get();
    return snapshot.docs.isEmpty;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validator,
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String id = _idController.text.trim();
      final bool isUnique = await _isIdUnique(id);
      if (isUnique) {
        // Add the employee to the database
        await FirebaseFirestore.instance.collection('employees').add({
          'id': id,
          'name': _nameController.text.trim(),
          'password': _passwordController.text.trim(),
          'section': selectedSection,
          'designation': selectedDesignation,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID already exists')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Employee',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _idController,
                                label: 'Id',
                                icon: Icons.badge,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the Id';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                controller: _nameController,
                                label: 'Name',
                                icon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the name';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Section Dropdown with search
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: DropdownSearch<String>(
                                  items: sections,
                                  dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: 'Section',
                                      prefixIcon: Icon(Icons.location_city),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  popupProps: const PopupProps.menu(
                                    showSearchBox: true, // Enable search box
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Search Section",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSection = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a section';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Designation Dropdown with search
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: DropdownSearch<String>(
                                  items: designations,
                                  dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: 'Designation',
                                      prefixIcon: Icon(Icons.work),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  popupProps: const PopupProps.menu(
                                    showSearchBox: true, // Enable search box
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: "Search Designation",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDesignation = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a designation';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
