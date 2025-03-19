import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:power_path/utils/app_colors.dart';

class MaintenanceDetailsSection extends StatelessWidget {
  final Map<String, dynamic> maintenanceDetails;
  final String transformerId;
  final Future<void> Function() completeMaintenance;

  const MaintenanceDetailsSection({
    Key? key,
    required this.maintenanceDetails,
    required this.transformerId,
    required this.completeMaintenance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                if (maintenanceDetails['nextMaintenanceDate'] != null)
                  IconButton(
                    icon: const Icon(Icons.check_circle,
                        color: AppColors.buttonColor),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final String designation =
                          prefs.getString('designation') ?? '';
                      if (designation.toLowerCase().contains('engineer')) {
                        await completeMaintenance();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Only engineers can complete maintenance.'),
                          ),
                        );
                      }
                    },
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
                  'Last Maintenance Date: ${maintenanceDetails['lastMaintenanceDate'] != null ? (maintenanceDetails['lastMaintenanceDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'Not available'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Next Maintenance Date: ${maintenanceDetails['nextMaintenanceDate'] != null ? (maintenanceDetails['nextMaintenanceDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'Not yet decided'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                if (maintenanceDetails['nextMaintenanceDate'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Maintenance Purpose: ${maintenanceDetails['maintenancePurpose'] ?? 'Not available'}',
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
    );
  }
}
