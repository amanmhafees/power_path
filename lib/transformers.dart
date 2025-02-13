import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transformer_detail.dart'; // Import the TransformerDetailPage

// Define a custom color scheme
class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1976D2);
  static const Color grey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
}

class TransformersPage extends StatefulWidget {
  final String section;

  const TransformersPage({super.key, required this.section});

  @override
  _TransformersPageState createState() => _TransformersPageState();
}

class _TransformersPageState extends State<TransformersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> transformers = [];
  List<Map<String, dynamic>> filteredTransformers = [];

  @override
  void initState() {
    super.initState();
    _fetchTransformers();
  }

  Future<void> _fetchTransformers() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('transformers')
          .where('section', isEqualTo: widget.section)
          .get();
      final List<Map<String, dynamic>> fetchedTransformers = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'map_url': doc['map_url'],
                'status': doc['status'],
                'section': doc['section'],
              })
          .toList();
      setState(() {
        transformers = fetchedTransformers;
        filteredTransformers = transformers;
      });
    } catch (e) {
      print('Error fetching transformers: $e');
    }
  }

  void _filterTransformers(String query) {
    setState(() {
      filteredTransformers = transformers
          .where((transformer) =>
              transformer['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Transformers',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: AppColors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: _filterTransformers,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: filteredTransformers.length,
                itemBuilder: (context, index) {
                  final transformer = filteredTransformers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransformerDetailPage(
                              transformer: transformer,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.electric_bolt,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                transformer['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primaryBlue,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
