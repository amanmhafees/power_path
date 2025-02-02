import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method
import 'package:dropdown_search/dropdown_search.dart';
import 'login.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedDesignation = '';
  String _selectedSection = '';
  String _errorMessage = '';

  String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final digest = sha256.convert(bytes); // Hash the bytes using SHA-256
    return digest.toString(); // Convert the hash to a string
  }

  void addEmployee() async {
    if (_formKey.currentState!.validate()) {
      final id = int.tryParse(_idController.text);
      final name = _nameController.text;
      final password = _passwordController.text;
      final designation = _selectedDesignation;
      final section = _selectedSection;

      if (id == null ||
          name.isEmpty ||
          password.isEmpty ||
          designation.isEmpty ||
          section.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in all fields';
        });
        return;
      }

      final hashedPassword = hashPassword(password); // Hash the password

      FirebaseFirestore.instance.collection('employees').add({
        'id': id,
        'name': name,
        'password': hashedPassword, // Store the hashed password
        'designation': designation,
        'section': section,
      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        setState(() {
          _errorMessage = 'Error: $error';
        });
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Employee'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Hide the keyboard
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add New Employee',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 33, 150, 243),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                      DropdownSearch<String>(
                        items: const [
                          'Assistant Engineer',
                          'Sub Engineer',
                          'Line Man',
                          'Overseer',
                          'System Supervisor',
                        ],
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Designation',
                            prefixIcon: Icon(Icons.work),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: 'Search Designation',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedDesignation = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a designation';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownSearch<String>(
                        items: const [
                          'Kanjirapally',
                          'Erumely',
                          'Kottayam',
                          'Pala',
                          'Kochi',
                          'Thiruvananthapuram',
                          'Kollam',
                          'Alappuzha',
                          'Thrissur',
                          'Kozhikode',
                          'Kannur',
                          'Kasaragod',
                          'Wayanad',
                          'Malappuram',
                          'Palakkad',
                          'Idukki',
                          'Pathanamthitta',
                        ],
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Section',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: 'Search Section',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedSection = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a section';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: addEmployee,
                        child: const Text(
                          'Add Employee',
                          style: TextStyle(fontSize: 18),
                        ),
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
            ),
          ),
        ),
      ),
    );
  }
}
