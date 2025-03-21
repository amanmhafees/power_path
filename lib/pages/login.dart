import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Import your home pages
import 'home.dart';
import '../admin/admin_home.dart';
import 'ss_home.dart';

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
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (_isAdmin) {
        // Admin login check - Replace with your Firebase code
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
              await prefs.setString('userName', 'admin');
              await prefs.setString(
                  'section', 'admin'); // Assuming admin section

              // Save FCM token to Firestore
              await FirebaseFirestore.instance
                  .collection('admins')
                  .doc(adminDoc.id)
                  .update({'fcmToken': fcmToken});

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
        // Employee login check - Replace with your Firebase code
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
              await prefs.setString(
                  'designation', designation); // Save designation

              // Save FCM token to Firestore
              await FirebaseFirestore.instance
                  .collection('employees')
                  .doc(employeeDoc.id)
                  .update({'fcmToken': fcmToken});

              if (password == 'Temp@123') {
                _showChangePasswordDialog(
                    employeeDoc.id, name, designation, section);
              } else if (designation == 'System Supervisor') {
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

  void _showChangePasswordDialog(
      String employeeId, String name, String designation, String section) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    String errorMessage = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    obscureText: true,
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final newPassword = newPasswordController.text.trim();
                    final confirmPassword =
                        confirmPasswordController.text.trim();

                    if (newPassword.isEmpty || confirmPassword.isEmpty) {
                      setState(() {
                        errorMessage = 'Please enter both fields';
                      });
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      setState(() {
                        errorMessage = 'Passwords do not match';
                      });
                      return;
                    }

                    if (!_isValidPassword(newPassword)) {
                      setState(() {
                        errorMessage =
                            'Password must be at least 8 characters long, include an uppercase letter, a lowercase letter, a number, and a special character';
                      });
                      return;
                    }

                    final hashedNewPassword = hashPassword(newPassword);

                    await FirebaseFirestore.instance
                        .collection('employees')
                        .doc(employeeId)
                        .update({'password': hashedNewPassword});

                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                userName: name,
                                userType: designation
                                        .toLowerCase()
                                        .contains('engineer')
                                    ? 'engineer'
                                    : 'worker',
                                section: section,
                              )),
                    );
                  },
                  child: const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isValidPassword(String password) {
    final passwordRegExp = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Hide the keyboard
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Logo container with shadow
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200,
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // App name
                        const Text(
                          'PowerPath',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tagline
                        Text(
                          'Energy Management System',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Login card
                        Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // User type toggle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Employee',
                                      style: TextStyle(
                                        color: !_isAdmin
                                            ? Colors.blue.shade700
                                            : Colors.grey.shade600,
                                        fontWeight: !_isAdmin
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Switch(
                                      value: _isAdmin,
                                      activeColor: Colors.blue.shade700,
                                      onChanged: (value) {
                                        setState(() {
                                          _isAdmin = value;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Admin',
                                      style: TextStyle(
                                        color: _isAdmin
                                            ? Colors.blue.shade700
                                            : Colors.grey.shade600,
                                        fontWeight: _isAdmin
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // ID field
                                TextField(
                                  controller: _idController,
                                  decoration: InputDecoration(
                                    labelText: 'ID',
                                    hintText: 'Enter your ID',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.person),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 20),
                                // Password field
                                TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                  ),
                                  obscureText: !_isPasswordVisible,
                                ),
                                const SizedBox(height: 24),
                                // Error message
                                if (_errorMessage.isNotEmpty)
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      _errorMessage,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                // Login button
                                ElevatedButton(
                                  onPressed: login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Footer
                        Text(
                          '© 2025 PowerPath. All rights reserved.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
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
      ),
    );
  }
}
