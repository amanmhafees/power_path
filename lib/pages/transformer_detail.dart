import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:power_path/services/get_server_key.dart';
import 'package:power_path/services/notification_service.dart';
import 'package:power_path/utils/app_colors.dart';
import 'package:power_path/widgets/maintenance_details.dart';
import 'package:power_path/widgets/fault_log.dart';
import 'package:power_path/widgets/notes_section.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:power_path/services/get_server_key.dart';
// Import the GetServerKey class

class TransformerDetailPage extends StatefulWidget {
  final Map<String, dynamic> transformer;

  const TransformerDetailPage({Key? key, required this.transformer})
      : super(key: key);

  @override
  _TransformerDetailPageState createState() => _TransformerDetailPageState();
}

class _TransformerDetailPageState extends State<TransformerDetailPage> {
  final TextEditingController _faultController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late CollectionReference faultsCollection;
  late CollectionReference notesCollection;
  String? _selectedStatus;
  Map<String, dynamic>? maintenanceDetails;
  bool isEngineer = false;

  final List<String> _statusOptions = [
    'Active',
    'Inactive',
    'Under Maintenance'
  ];

  @override
  void initState() {
    super.initState();
    faultsCollection = FirebaseFirestore.instance
        .collection('transformers')
        .doc(widget.transformer['id'])
        .collection('faults');
    notesCollection = FirebaseFirestore.instance
        .collection('transformers')
        .doc(widget.transformer['id'])
        .collection('notes');
    _selectedStatus = widget.transformer['status'];
    _fetchMaintenanceDetails();
    _checkIfEngineer();
  }

  Future<void> _fetchMaintenanceDetails() async {
    final DocumentSnapshot transformerDoc = await FirebaseFirestore.instance
        .collection('transformers')
        .doc(widget.transformer['id'])
        .get();
    setState(() {
      maintenanceDetails = transformerDoc.data() as Map<String, dynamic>?;
    });
  }

  Future<void> _checkIfEngineer() async {
    final prefs = await SharedPreferences.getInstance();
    final String designation = prefs.getString('designation') ?? '';
    setState(() {
      isEngineer = designation.toLowerCase().contains('engineer');
    });
  }

  Future<void> _completeMaintenance() async {
    final TextEditingController maintenanceDetailsController =
        TextEditingController();
    final DateTime now = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Maintenance Details'),
          content: TextField(
            controller: maintenanceDetailsController,
            decoration: const InputDecoration(
              hintText: 'Enter details of the maintenance performed',
            ),
            maxLines: 5,
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
                final String maintenanceDetails =
                    maintenanceDetailsController.text.trim();
                if (maintenanceDetails.isNotEmpty) {
                  final maintenanceRecord = {
                    'date': now,
                    'details': maintenanceDetails,
                  };

                  await FirebaseFirestore.instance
                      .collection('transformers')
                      .doc(widget.transformer['id'])
                      .update({
                    'lastMaintenanceDate': now,
                    'maintenanceRecords':
                        FieldValue.arrayUnion([maintenanceRecord]),
                    'nextMaintenanceDate':
                        null, // Clear the next maintenance date
                    'maintenancePurpose': null, // Clear the maintenance purpose
                  });

                  setState(() {
                    this.maintenanceDetails!['lastMaintenanceDate'] =
                        Timestamp.fromDate(now);
                    this.maintenanceDetails!['nextMaintenanceDate'] = null;
                    this.maintenanceDetails!['maintenancePurpose'] = null;
                    if (this.maintenanceDetails!['maintenanceRecords'] ==
                        null) {
                      this.maintenanceDetails!['maintenanceRecords'] = [
                        maintenanceRecord
                      ];
                    } else {
                      (this.maintenanceDetails!['maintenanceRecords'] as List)
                          .add(maintenanceRecord);
                    }
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(String? newStatus) async {
    if (newStatus != null) {
      await FirebaseFirestore.instance
          .collection('transformers')
          .doc(widget.transformer['id'])
          .update({'status': newStatus});
      setState(() {
        _selectedStatus = newStatus;
      });
    }
  }

  Future<void> _addFault() async {
    final String fault = _faultController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('userName') ?? 'Unknown User';
    final String section = prefs.getString('section') ?? 'Unknown Section';
    if (fault.isNotEmpty) {
      await faultsCollection.add({'fault': fault});
      await _sendNotificationToSection(
          section, '$fault', userName, 'Fault Logged');
      _faultController.clear();
    }
  }

  Future<void> _deleteFault(String faultId) async {
    await faultsCollection.doc(faultId).delete();
  }

  Future<void> _addNote() async {
    final String note = _noteController.text.trim();
    if (note.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final String userName = prefs.getString('userName') ?? 'Unknown User';
      final String section = prefs.getString('section') ?? 'Unknown Section';

      await notesCollection.add({
        'note': note,
        'user': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _noteController.clear();
      // _sendPushNotification(note, userName, section);

      await _sendNotificationToSection(section, '$note', userName, 'New Note');
    }
  }

  // Sending notification to all employees in the same section
  Future<void> _sendNotificationToSection(
      String section, String message, String userName, String Title) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('section', isEqualTo: section)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final GetServerKey getServerKey = GetServerKey();
      String accessToken =
          await getServerKey.getServerKeyToken(); // Get OAuth 2.0 access token

      const String fcmUrl =
          "https://fcm.googleapis.com/v1/projects/power-path-c1bb4/messages:send";

      for (var employeeDoc in querySnapshot.docs) {
        final fcmToken = employeeDoc['fcmToken'];
        if (fcmToken != null) {
          final Map<String, dynamic> notificationData = {
            "message": {
              "token": fcmToken,
              "notification": {
                "title": "$Title by $userName",
                "body": "$message on ${widget.transformer['name']}",
              },
              "data": {
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                "id": "1",
              }
            }
          };

          final response = await http.post(
            Uri.parse(fcmUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization":
                  "Bearer $accessToken", // Use OAuth 2.0 access token
            },
            body: jsonEncode(notificationData),
          );

          if (response.statusCode == 200) {
            print("Notification sent successfully to ${employeeDoc['name']}");
          } else {
            print(
                "Failed to send notification to ${employeeDoc['name']}: ${response.body}");
          }
        }
      }
    }
  }

  Future<void> _deleteNote(String noteId) async {
    await notesCollection.doc(noteId).delete();
  }

  Future<void> _addTransformerDetail() async {
    final TextEditingController capacityController = TextEditingController();
    final TextEditingController dateOfInstallationController =
        TextEditingController();
    final TextEditingController yearOfManufactureController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Transformer Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateOfInstallationController,
                decoration: const InputDecoration(
                  labelText: 'Date of Installation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: yearOfManufactureController,
                decoration: const InputDecoration(
                  labelText: 'Year of Manufacture',
                  border: OutlineInputBorder(),
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
                final String dateOfInstallation =
                    dateOfInstallationController.text.trim();
                final String capacity = capacityController.text.trim();
                final String yearOfManufacture =
                    yearOfManufactureController.text.trim();

                if (dateOfInstallation.isNotEmpty &&
                    capacity.isNotEmpty &&
                    yearOfManufacture.isNotEmpty) {
                  final newDetail = {
                    'date_of_installation': dateOfInstallation,
                    'capacity': capacity,
                    'year_of_manufacturing': yearOfManufacture,
                  };

                  await FirebaseFirestore.instance
                      .collection('transformers')
                      .doc(widget.transformer['id'])
                      .update({
                    'details': FieldValue.arrayUnion([newDetail]),
                  });

                  setState(() {
                    widget.transformer['details'].add(newDetail);
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _launchMapsUrl(String mapsUrl) async {
    final Uri url = Uri.parse(mapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $mapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String mapsUrl = widget.transformer['map_url'];
    final String? imageUrl = widget.transformer['image_url'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.transformer['name'],
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                      ),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Image not got',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'URL not present',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Directions Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _launchMapsUrl(mapsUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 202, 201, 201),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Get Directions'),
                  ),
                ),
                const SizedBox(height: 24),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    _updateStatus(newValue);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Transformer Details Section
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Date of Installation:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Capacity:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Year of Manufacture:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      if (widget.transformer['details'] != null)
                        ...widget.transformer['details'].map<Widget>((detail) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(detail['date_of_installation']),
                                const SizedBox(height: 8),
                                Text(detail['capacity']),
                                const SizedBox(height: 8),
                                Text(detail['year_of_manufacturing']),
                              ],
                            ),
                          );
                        }).toList()
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('N/A'),
                            SizedBox(height: 8),
                            Text('N/A'),
                            SizedBox(height: 8),
                            Text('N/A'),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Add Details Button for Engineers
                if (isEngineer)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addTransformerDetail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Add Details'),
                    ),
                  ),
                const SizedBox(height: 24),

                // Maintenance Details Section
                if (maintenanceDetails != null)
                  MaintenanceDetailsSection(
                    maintenanceDetails: maintenanceDetails!,
                    transformerId: widget.transformer['id'],
                    completeMaintenance: _completeMaintenance,
                  ),
                const SizedBox(height: 24),

                // Fault Log Section
                FaultLogSection(
                  faultsCollection: faultsCollection,
                  faultController: _faultController,
                  addFault: _addFault,
                  deleteFault: _deleteFault,
                ),
                const SizedBox(height: 24),

                // Notes Section
                NotesSection(
                  notesCollection: notesCollection,
                  noteController: _noteController,
                  addNote: _addNote,
                  deleteNote: _deleteNote,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
