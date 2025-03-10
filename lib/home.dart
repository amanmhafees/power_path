import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'engineer_navbar.dart'; // Import the EngineerNavbar
import 'workers_navbar.dart'; // Import the WorkerNavbar
import 'transformers.dart'; // Import the TransformersPage

// Define a custom color scheme
class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1976D2);
  static const Color grey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
}

class HomePage extends StatefulWidget {
  final String userName;
  final String userType;
  final String section;

  const HomePage(
      {super.key,
      required this.userName,
      required this.userType,
      required this.section});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> sections = [];
  List<Map<String, dynamic>> filteredSections = [];

  @override
  void initState() {
    super.initState();
    _fetchSections();
    _searchController.addListener(() {
      _filterSections(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {
      _filterSections(_searchController.text);
    });
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSections() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('sections').get();
      final List<Map<String, dynamic>> fetchedSections = snapshot.docs
          .map((doc) => {
                'id': doc['id'],
                'name': doc['section_name'],
              })
          .toList();
      setState(() {
        sections = fetchedSections;
        filteredSections = sections;
      });
    } catch (e) {
      print('Error fetching sections: $e');
    }
  }

  void _filterSections(String query) {
    setState(() {
      filteredSections = sections.where((section) {
        return section['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Sections',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: widget.userType.toLowerCase().contains('engineer')
          ? EngineerNavbar(
              userName: widget.userName,
              section: widget.section,
              currentPage: 'Home',
            )
          : WorkerNavbar(
              userName: widget.userName,
              section: widget.section,
              currentPage: 'Home',
            ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Sections',
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
                onChanged: _filterSections,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: filteredSections.length,
                itemBuilder: (context, index) {
                  final section = filteredSections[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        if (section['id'] == widget.section) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransformersPage(
                                section: section['id'],
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'You do not have permission to access this section.'),
                            ),
                          );
                        }
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
                                Icons.location_on,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                section['name'],
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
