import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Set the button's background color
        foregroundColor: Colors.white, // Set the text/icon color
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18.0, // Adjust text size
          fontWeight: FontWeight.bold, // Adjust text weight
        ),
      ),
    );
  }
}
