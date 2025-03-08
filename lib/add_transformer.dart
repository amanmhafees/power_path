import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _dateOfInstallationController =
      TextEditingController();
  final TextEditingController _yearOfManufacturingController =
      TextEditingController();
  String? _selectedStatus;
  File? _selectedImage;

  final List<String> _statusOptions = [
    'Active',
    'Inactive',
    'Under Maintenance'
  ];

  Future<void> _addTransformer() async {
    final String name = _nameController.text.trim();
    final String mapUrl = _mapUrlController.text.trim();
    final String capacity = _capacityController.text.trim();
    final String dateOfInstallation = _dateOfInstallationController.text.trim();
    final String yearOfManufacturing =
        _yearOfManufacturingController.text.trim();
    final String? status = _selectedStatus;

    if (name.isEmpty ||
        mapUrl.isEmpty ||
        capacity.isEmpty ||
        dateOfInstallation.isEmpty ||
        yearOfManufacturing.isEmpty ||
        status == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and select an image')),
      );
      return;
    }

    try {
      // Upload image to Cloudinary and get the download URL
      final String imageUrl = await _uploadImage(name);

      await FirebaseFirestore.instance.collection('transformers').add({
        'name': name,
        'map_url': mapUrl,
        'status': status,
        'section': widget.section,
        'image_url': imageUrl,
        'details': [
          {
            'capacity': capacity,
            'date_of_installation': dateOfInstallation,
            'year_of_manufacturing': yearOfManufacturing,
          }
        ],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transformer added successfully')),
      );

      // Clear the input fields
      _nameController.clear();
      _mapUrlController.clear();
      _capacityController.clear();
      _dateOfInstallationController.clear();
      _yearOfManufacturingController.clear();
      setState(() {
        _selectedStatus = null;
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String> _uploadImage(String transformerName) async {
    final String cloudName = 'dkzaen9x5';
    final String uploadPreset = 'powerpath';
    final Uri apiUrl =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', apiUrl)
      ..fields['upload_preset'] = uploadPreset
      ..fields['public_id'] = transformerName.replaceAll(
          ' ', '_') // Use transformer name as the public ID
      ..files
          .add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final responseJson = json.decode(responseString);
      return responseJson['secure_url'];
    } else {
      final responseData = await response.stream.bytesToString();
      throw Exception('Failed to upload image: ${responseData}');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
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
        currentPage: 'Add New Transformer',
      ), // Pass the necessary parameters to EngineerNavbar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              TextField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                enableInteractiveSelection: true, // Allow paste option
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dateOfInstallationController,
                decoration: const InputDecoration(
                  labelText: 'Date of Installation',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                enableInteractiveSelection: true, // Allow paste option
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _yearOfManufacturingController,
                decoration: const InputDecoration(
                  labelText: 'Year of Manufacturing',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addTransformer,
                child: const Text('Add Transformer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
