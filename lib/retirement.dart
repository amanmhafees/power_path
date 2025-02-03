//sample code
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class RetirementPage extends StatefulWidget {
  const RetirementPage({Key? key});

  @override
  _RetirementPageState createState() => _RetirementPageState();
}

class _RetirementPageState extends State<RetirementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirement'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Add the code to navigate to the retirement form
          },
          child: const Text('Retire'),
        ),
      ),
    );
  }
}
