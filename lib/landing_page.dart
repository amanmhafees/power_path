import 'package:flutter/material.dart';
import 'sign_up_page.dart';
import 'sign_in_page.dart'; // Assuming you have a sign_in_page.dart file

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Path'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ), // Background color matching the screenshot
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.jpg', // Ensure the image is placed in the assets folder
              height: 220,
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Power Path',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 80),

            // Sign In Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Sign In page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                elevation: 5,
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 59, 24, 108),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Sign Up Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Sign Up page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                elevation: 5,
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 59, 24, 108),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
