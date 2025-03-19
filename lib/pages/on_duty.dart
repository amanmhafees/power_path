import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/engineer_navbar.dart';
import '../widgets/workers_navbar.dart';

class OnDutyPage extends StatefulWidget {
  final String section;
  final String userName;

  const OnDutyPage({Key? key, required this.section, required this.userName})
      : super(key: key);

  @override
  _OnDutyPageState createState() => _OnDutyPageState();
}

class _OnDutyPageState extends State<OnDutyPage> {
  final TextEditingController _dayShiftController = TextEditingController();
  final TextEditingController _nightShiftController = TextEditingController();
  String selectedShift = 'Day';
  String designation = '';

  @override
  void initState() {
    super.initState();
    _getDesignation();
  }

  Future<void> _getDesignation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      designation = prefs.getString('designation') ?? '';
    });
  }

  Future<void> _addOnDuty(String shift) async {
    final String employeeName = shift == 'Day'
        ? _dayShiftController.text.trim()
        : _nightShiftController.text.trim();

    if (employeeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an employee name')),
      );
      return;
    }

    try {
      final employeeSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('name', isEqualTo: employeeName)
          .get();

      if (employeeSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee not found')),
        );
        return;
      }

      final employeeData = employeeSnapshot.docs.first.data();

      await FirebaseFirestore.instance.collection('on_duty').add({
        'employee_name': employeeName,
        'shift': shift,
        'section': widget.section,
        'designation': employeeData['designation'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee added to $shift shift successfully')),
      );

      if (shift == 'Day') {
        _dayShiftController.clear();
      } else {
        _nightShiftController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _clearShift(String shift) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('on_duty')
          .where('shift', isEqualTo: shift)
          .where('section', isEqualTo: widget.section)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$shift shift cleared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _editShift(String shift) async {
    final currentShiftSnapshot = await FirebaseFirestore.instance
        .collection('on_duty')
        .where('shift', isEqualTo: shift)
        .where('section', isEqualTo: widget.section)
        .get();

    final currentShiftEmployees =
        currentShiftSnapshot.docs.map((doc) => doc['employee_name']).toSet();

    final employeesSnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('section', isEqualTo: widget.section)
        .get();

    final availableEmployees = employeesSnapshot.docs
        .where((doc) => !currentShiftEmployees.contains(doc['name']))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $shift Shift'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: availableEmployees.map((doc) {
                    return ListTile(
                      title: Text(doc['name']),
                      subtitle: Text('Designation: ${doc['designation']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('on_duty')
                              .add({
                            'employee_name': doc['name'],
                            'shift': shift,
                            'section': widget.section,
                            'designation': doc['designation'],
                          });
                          setState(() {
                            availableEmployees.remove(doc);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${doc['name']} added to $shift shift')),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterByShift(String shift) {
    setState(() {
      selectedShift = shift;
    });
  }

  void _refreshPage() {
    setState(() {
      // Reload the state of the widget
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('On Duty'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPage,
          ),
        ],
      ),
      drawer: designation.toLowerCase().contains('engineer')
          ? EngineerNavbar(
              userName: widget.userName,
              section: widget.section,
              currentPage: 'On Duty',
            )
          : WorkerNavbar(
              userName: widget.userName,
              section: widget.section,
              currentPage: 'On Duty',
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildShiftButton('Day', Colors.blue),
                      _buildShiftButton('Night', Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (selectedShift == 'Day') ...[
                const Text(
                  'Day Shift',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                if (designation.toLowerCase().contains('engineer')) ...[
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _editShift('Day'),
                        child: const Icon(Icons.edit),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _clearShift('Day'),
                        child: const Text('Clear Day Shift'),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                const Text(
                  'Night Shift',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                if (designation.toLowerCase().contains('engineer')) ...[
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _editShift('Night'),
                        child: const Icon(Icons.edit),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _clearShift('Night'),
                        child: const Text('Clear Night Shift'),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 24),
              const Text(
                'Employees on Duty Today',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('on_duty')
                    .where('section', isEqualTo: widget.section)
                    .where('shift', isEqualTo: selectedShift)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final employees = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return ListTile(
                        title: Text(employee['employee_name']),
                        subtitle: Text(
                            'Shift: ${employee['shift']}, Designation: ${employee['designation']}'),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftButton(String shift, Color color) {
    final bool isSelected = selectedShift == shift;
    return Expanded(
      child: GestureDetector(
        onTap: () => _filterByShift(shift),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                shift,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
