import 'package:flutter/material.dart';
import '../pages/login.dart'; // Import the LoginPage
import '../pages/transfer.dart'; // Import the TransferPage
import '../pages/history.dart'; // Import the HistoryPage
import '../pages/ss_home.dart'; // Import the SSHomePage
import '../pages/retirement.dart'; // Import the RetirementPage
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false,
  );
}

class SSNavbar extends StatelessWidget {
  final String section;
  final String currentPage;

  const SSNavbar({super.key, required this.section, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      section[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 40.0,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'System Supervisor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Supervisor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SSHomePage(section: section),
                        ),
                      );
                    },
                    isActive: currentPage == 'Home',
                  ),
                  const Divider(height: 1),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'MANAGEMENT',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.transfer_within_a_station,
                    title: 'Transfer',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransferPage(supervisorSection: section),
                        ),
                      );
                    },
                    isActive: currentPage == 'Transfer',
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.assignment_ind,
                    title: 'Retirement',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RetirementPage(supervisorSection: section),
                        ),
                      );
                    },
                    isActive: currentPage == 'Retirement',
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.history,
                    title: 'Past employees',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryPage(section: section),
                        ),
                      );
                    },
                    isActive: currentPage == 'Past employees',
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red[700],
                    size: 20,
                  ),
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.shade100 : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.blue.shade700 : Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blue.shade700 : Colors.black87,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 5,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(5),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
