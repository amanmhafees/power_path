import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'admin_home.dart'; // Import the AdminHomePage
import 'ss_home.dart'; // Import the SSHomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAdmin = false; // Toggle for admin login
  String _errorMessage = '';
  bool _isPasswordVisible = false; // State variable for password visibility

  String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final digest = sha256.convert(bytes); // Hash the bytes using SHA-256
    return digest.toString(); // Convert the hash to a string
  }

  Future<void> login() async {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both Id and Password';
      });
      return;
    }

    try {
      if (_isAdmin) {
        // Admin login check
        FirebaseFirestore.instance
            .collection('admins')
            .where('adminid', isEqualTo: id)
            .limit(1)
            .get()
            .then((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            final adminDoc = snapshot.docs.first;
            final storedHashedPassword = adminDoc['password'];
            final inputHashedPassword = password;

            if (storedHashedPassword == inputHashedPassword) {
              // Save login state
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);
              await prefs.setBool('isAdmin', true);
              await prefs.setString('userId', id);
              await prefs.setString('userName', adminDoc['name']);
              await prefs.setString(
                  'section', 'admin'); // Assuming admin section

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminHomePage()),
              );
            } else {
              setState(() {
                _errorMessage = 'Invalid Admin Id or Password';
              });
            }
          } else {
            setState(() {
              _errorMessage = 'Invalid Admin Id or Password';
            });
          }
        }).catchError((error) {
          setState(() {
            _errorMessage = 'Error: $error';
          });
        });
      } else {
        // Employee login check
        FirebaseFirestore.instance
            .collection('employees')
            .where('id',
                isEqualTo: id) // Employee ID is likely stored as a number
            .limit(1)
            .get()
            .then((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            final employeeDoc = snapshot.docs.first;
            final storedHashedPassword = employeeDoc['password'];
            final inputHashedPassword = hashPassword(password);

            if (storedHashedPassword == inputHashedPassword) {
              final designation = employeeDoc['designation'];
              final section = employeeDoc['section'];
              final name = employeeDoc['name'];

              // Save login state
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);
              await prefs.setBool('isAdmin', false);
              await prefs.setString('userId', id);
              await prefs.setString('userName', name);
              await prefs.setString('section', section);

              if (designation == 'System Supervisor') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SSHomePage(section: section)),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(
                            userName: name,
                            userType:
                                designation.toLowerCase().contains('engineer')
                                    ? 'engineer'
                                    : 'worker',
                            section: section,
                          )),
                );
              }
            } else {
              setState(() {
                _errorMessage = 'Invalid Employee Id or Password';
              });
            }
          } else {
            setState(() {
              _errorMessage = 'Invalid Employee Id or Password';
            });
          }
        }).catchError((error) {
          setState(() {
            _errorMessage = 'Error: $error';
          });
        });
      }
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
        title: const Text('Login'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Hide the keyboard
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
                    Image.asset(
                      'assets/images/logo.png',
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'PowerPath',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Employee'),
                                Switch(
                                  value: _isAdmin,
                                  onChanged: (value) {
                                    setState(() {
                                      _isAdmin = value;
                                    });
                                  },
                                ),
                                const Text('Admin'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _idController,
                              decoration: const InputDecoration(
                                labelText: 'Id',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              obscureText: !_isPasswordVisible,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed:
                                  login, // Pass the login function as a callback
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text('Login'),
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
