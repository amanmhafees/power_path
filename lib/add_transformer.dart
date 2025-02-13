// Sample code for a widget to show the new transformer page

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'engineer_navbar.dart'; // Import the EngineerNavbar

class AddTransformer extends StatefulWidget {
  final String section;
  final String userName;

  const AddTransformer(
      {super.key, required this.section, required this.userName});

  @override
  _AddTransformerState createState() => _AddTransformerState();
}

class _AddTransformerState extends State<AddTransformer> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mapUrlController = TextEditingController();
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'Active',
    'Inactive',
    'Under Maintenance'
  ];

  Future<void> _addTransformer() async {
    final String name = _nameController.text.trim();
    final String mapUrl = _mapUrlController.text.trim();
    final String? status = _selectedStatus;

    if (name.isEmpty || mapUrl.isEmpty || status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('transformers').add({
        'name': name,
        'map_url': mapUrl,
        'status': status,
        'section': widget.section,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transformer added successfully')),
      );

      // Clear the input fields
      _nameController.clear();
      _mapUrlController.clear();
      setState(() {
        _selectedStatus = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transformer'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: EngineerNavbar(
        userName: widget.userName,
        section: widget.section,
      ), // Pass the necessary parameters to EngineerNavbar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Transformer Name',
                border: OutlineInputBorder(),
              ),
              enableInteractiveSelection: true, // Allow paste option
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mapUrlController,
              decoration: const InputDecoration(
                labelText: 'Location URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              enableInteractiveSelection: true, // Allow paste option
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTransformer,
              child: const Text('Add Transformer'),
            ),
          ],
        ),
      ),
    );
  }
}
