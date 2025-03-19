import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/engineer_navbar.dart'; // Import the EngineerNavbar

class ScheduleMaintenancePage extends StatefulWidget {
  final String userName;
  final String section;

  const ScheduleMaintenancePage(
      {Key? key, required this.userName, required this.section})
      : super(key: key);

  @override
  _ScheduleMaintenancePageState createState() =>
      _ScheduleMaintenancePageState();
}

class _ScheduleMaintenancePageState extends State<ScheduleMaintenancePage> {
  final TextEditingController _purposeController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTransformerId;
  String? _selectedTransformerName;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _scheduleMaintenance() async {
    final String purpose = _purposeController.text;
    final DateTime? date = _selectedDate;
    if (purpose.isNotEmpty && date != null && _selectedTransformerId != null) {
      await FirebaseFirestore.instance
          .collection('transformers')
          .doc(_selectedTransformerId)
          .update({
        'nextMaintenanceDate': date,
        'maintenancePurpose': purpose,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Maintenance scheduled for $_selectedTransformerName on $date with purpose: $purpose'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select a transformer, enter a purpose, and select a date'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Maintenance'),
      ),
      drawer: EngineerNavbar(
        userName: widget.userName,
        section: widget.section,
        currentPage: 'Schedule Maintenance',
      ), // Add the EngineerNavbar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transformers')
                  .where('section', isEqualTo: widget.section)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final transformers = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  value: _selectedTransformerId,
                  items: transformers.map((DocumentSnapshot document) {
                    return DropdownMenuItem<String>(
                      value: document.id,
                      child: Text(document['name']),
                      onTap: () {
                        setState(() {
                          _selectedTransformerName = document['name'];
                        });
                      },
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTransformerId = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Transformer',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose of Maintenance',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date selected'
                        : 'Selected date: ${_selectedDate!.toLocal()}'
                            .split(' ')[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scheduleMaintenance,
              child: const Text('Schedule Maintenance'),
            ),
          ],
        ),
      ),
    );
  }
}
