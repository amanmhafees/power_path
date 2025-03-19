import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/engineer_navbar.dart'; // Import the EngineerNavbar

class RemoveTransformerPage extends StatefulWidget {
  final String section;
  final String userName;

  const RemoveTransformerPage(
      {super.key, required this.section, required this.userName});

  @override
  _RemoveTransformerPageState createState() => _RemoveTransformerPageState();
}

class _RemoveTransformerPageState extends State<RemoveTransformerPage> {
  Future<List<Map<String, dynamic>>> _fetchTransformers() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('transformers')
        .where('section', isEqualTo: widget.section)
        .get();
    return result.docs
        .map((doc) => {'id': doc.id, 'name': doc['name']})
        .toList();
  }

  Future<void> _removeTransformer(String transformerId) async {
    await FirebaseFirestore.instance
        .collection('transformers')
        .doc(transformerId)
        .delete();
  }

  Future<void> _confirmDelete(BuildContext context, String transformerId,
      String transformerName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete $transformerName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _removeTransformer(transformerId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$transformerName removed.'),
        ),
      );
      // Refresh the list
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Transformer'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: EngineerNavbar(
        userName: widget.userName,
        section: widget.section,
        currentPage: 'Remove Transformer',
      ), // Add the navbar
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransformers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transformers found.'));
          } else {
            final transformers = snapshot.data!;
            return ListView.builder(
              itemCount: transformers.length,
              itemBuilder: (context, index) {
                final transformer = transformers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(transformer['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _confirmDelete(
                            context, transformer['id'], transformer['name']);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
