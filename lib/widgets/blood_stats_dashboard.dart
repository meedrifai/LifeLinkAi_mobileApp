import 'package:flutter/material.dart';
import '../models/donor.dart';

class BloodStatsDashboard extends StatelessWidget {
  final BloodStats bloodStats;

  const BloodStatsDashboard({
    Key? key,
    required this.bloodStats,
  }) : super(key: key);

  // Format milliliters for display, converting to liters when appropriate
  String _formatBloodVolume(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }

  // Get color for blood type display
  Color _getBloodTypeColor(String bloodType) {
    final types = {
      'A+': Colors.red[500]!,
      'A-': Colors.red[400]!,
      'B+': Colors.blue[500]!,
      'B-': Colors.blue[400]!,
      'AB+': Colors.purple[500]!,
      'AB-': Colors.purple[400]!,
      'O+': Colors.green[500]!,
      'O-': Colors.green[400]!,
    };
    return types[bloodType] ?? Colors.grey[500]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard header
            Row(
              children: [
                Icon(Icons.water_drop, color: Colors.red[600], size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Predicted Blood Collection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Total volume section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFEF2F2),
                    const Color(0xFFFEE2E2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Volume',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatBloodVolume(bloodStats.totalVolume),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'From ${bloodStats.potentialDonors} potential donors',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Blood type breakdown
            bloodStats.byType.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[400], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Run prediction to see blood volume by type',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: bloodStats.byType.length,
                    itemBuilder: (context, index) {
                      final bloodType = bloodStats.byType.keys.elementAt(index);
                      final stats = bloodStats.byType[bloodType]!;
                      
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _getBloodTypeColor(bloodType),
                            child: Text(
                              bloodType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatBloodVolume(stats.volume),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${stats.count} donors',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}