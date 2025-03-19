import 'package:flutter/material.dart';
import '../pages/login.dart'; // Import the LoginPage
import '../pages/add_transformer.dart';
import '../pages/home.dart'; // Import the HomePage
import '../pages/schedule_maintenance.dart'; // Import the ScheduleMaintenancePage
import '../pages/maintenance_history.dart'; // Import the MaintenanceDetailsPage
import '../pages/remove_transformer.dart'; // Import the RemoveTransformerPage
import '../pages/on_duty.dart'; // Import the OnDutyPage
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

class EngineerNavbar extends StatelessWidget {
  final String userName;
  final String section;
  final String currentPage;

  const EngineerNavbar({
    super.key,
    required this.userName,
    required this.section,
    required this.currentPage,
  });

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
                    child: Icon(
                      Icons.engineering,
                      size: 40,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome, $userName',
                    style: const TextStyle(
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
                      'Engineer',
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
                          builder: (context) => HomePage(
                            userName: userName,
                            userType:
                                'engineer', // Assuming the userType is 'engineer'
                            section: section,
                          ),
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
                    icon: Icons.add,
                    title: 'Add New Transformer',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTransformer(
                              section: section, userName: userName),
                        ),
                      );
                    },
                    isActive: currentPage == 'Add New Transformer',
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.business,
                    title: 'Sections',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            userName: userName,
                            userType:
                                'engineer', // Assuming the userType is 'engineer'
                            section: section,
                          ),
                        ),
                      );
                    },
                    isActive: currentPage == 'Home',
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.schedule,
                    title: 'Schedule Maintenance',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleMaintenancePage(
                            userName: userName,
                            section: section,
                          ),
                        ),
                      );
                    },
                    isActive: currentPage == 'Schedule Maintenance',
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.list,
                    title: 'Maintenance Details',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaintenanceDetailsPage(
                            section: section,
                            userName: userName,
                          ),
                        ),
                      );
                    },
                    isActive: currentPage == 'Maintenance Details',
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.delete,
                    title: 'Remove Transformer',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RemoveTransformerPage(
                            section: section,
                            userName: userName,
                          ),
                        ),
                      );
                    },
                    isActive: currentPage == 'Remove Transformer',
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.work,
                    title: 'On Duty',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnDutyPage(
                            section: section,
                            userName: userName,
                          ),
                        ),
                      );
                    },
                    isActive: currentPage == 'On Duty',
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
