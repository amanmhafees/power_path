import 'package:flutter/material.dart';
import 'engineer_navbar.dart'; // Import the EngineerNavbar
import 'workers_navbar.dart'; // Import the WorkerNavbar

class HomePage extends StatefulWidget {
  final String userName;
  final String userType;

  const HomePage({super.key, required this.userName, required this.userType});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> sections = [
    'Erumely',
    'Kanjirapally',
    'Mundakkayam',
  ];
  List<String> filteredSections = [];

  @override
  void initState() {
    super.initState();
    filteredSections = sections;
    _searchController.addListener(_filterSections);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSections);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSections() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSections = sections.where((section) {
        return section.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: widget.userType == 'engineer'
          ? EngineerNavbar(userName: widget.userName)
          : WorkerNavbar(userName: widget.userName),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Hide the keyboard
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Sections',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sections',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSections.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(filteredSections[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
