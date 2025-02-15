import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import the dart:convert package
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

// Define a custom color scheme
class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1976D2);
  static const Color grey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
  static const Color buttonColor = Color(0xFF4CAF50); // New button color
}

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

  Future<void> _completeMaintenance() async {
    final DateTime now = DateTime.now();
    await FirebaseFirestore.instance
        .collection('transformers')
        .doc(widget.transformer['id'])
        .update({
      'lastMaintenanceDate': now,
      'nextMaintenanceDate': null,
      'maintenancePurpose': null,
    });
    setState(() {
      maintenanceDetails!['lastMaintenanceDate'] = Timestamp.fromDate(now);
      maintenanceDetails!['nextMaintenanceDate'] = null;
      maintenanceDetails!['maintenancePurpose'] = null;
    });
  }

  //redirecting to maps
  void _launchMapsUrl(String mapsUrl) async {
    final Uri url = Uri.parse(mapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $mapsUrl';
    }
  }

  Future<void> _addFault() async {
    final String fault = _faultController.text.trim();
    if (fault.isNotEmpty) {
      await faultsCollection.add({'fault': fault});
      _faultController.clear();
    }
  }

  Future<void> _deleteFault(String faultId) async {
    await faultsCollection.doc(faultId).delete();
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
      _sendPushNotification(note, userName, section);
    }
  }

  Future<void> _deleteNote(String noteId) async {
    await notesCollection.doc(noteId).delete();
  }

  Future<void> _sendPushNotification(
      String note, String userName, String section) async {
    // Replace with your FCM server key
    const String serverKey = 'YOUR_FCM_SERVER_KEY';
    final String transformerName = widget.transformer['name'];

    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final Map<String, dynamic> body = {
      'to': '/topics/$section',
      'notification': {
        'title': 'New Note for $transformerName',
        'body': '$note\nPosted by $userName',
      },
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'transformer_id': widget.transformer['id'],
      },
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      print('Error sending push notification: ${response.body}');
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

                // Maintenance Details Section
                if (maintenanceDetails != null) ...[
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Maintenance Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (maintenanceDetails!['nextMaintenanceDate'] !=
                                  null)
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: AppColors.buttonColor),
                                  onPressed: _completeMaintenance,
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last Maintenance Date: ${maintenanceDetails!['lastMaintenanceDate'] != null ? (maintenanceDetails!['lastMaintenanceDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'Not available'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Next Maintenance Date: ${maintenanceDetails!['nextMaintenanceDate'] != null ? (maintenanceDetails!['nextMaintenanceDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'Not yet decided'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (maintenanceDetails!['nextMaintenanceDate'] !=
                                  null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Maintenance Purpose: ${maintenanceDetails!['maintenancePurpose'] ?? 'Not available'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Fault Log Section
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
                        child: Text(
                          'Fault Log',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _faultController,
                          decoration: InputDecoration(
                            hintText: 'Enter fault log notes here...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addFault,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Add Fault'),
                          ),
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: faultsCollection.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final faults = snapshot.data!.docs;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: faults.length,
                            itemBuilder: (context, index) {
                              final fault = faults[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        fault['fault'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      value: false,
                                      onChanged: (bool? value) {
                                        if (value == true) {
                                          _deleteFault(fault.id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Notes Section
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
                        child: Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: 'Enter note here...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addNote,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Add Note'),
                          ),
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: notesCollection
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final notes = snapshot.data!.docs;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            note['note'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Posted by ${note['user']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _deleteNote(note.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
