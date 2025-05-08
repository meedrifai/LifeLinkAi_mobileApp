import 'package:flutter/material.dart';

class BloodStatsDashboard extends StatelessWidget {
  final Map<String, dynamic> bloodStats;

  const BloodStatsDashboard({super.key, required this.bloodStats});

  // Format milliliters for display, converting to liters when appropriate
  String formatBloodVolume(int ml) {
    if (ml >= 1000) {
      return "${(ml / 1000).toStringAsFixed(1)}L";
    }
    return "${ml}ml";
  }

  Color getBloodTypeColor(String bloodType) {
    final types = {
      'A+': const Color(0xFFEF4444),
      'A-': const Color(0xFFF87171),
      'B+': const Color(0xFF3B82F6),
      'B-': const Color(0xFF60A5FA),
      'AB+': const Color(0xFF8B5CF6),
      'AB-': const Color(0xFFA78BFA),
      'O+': const Color(0xFF10B981),
      'O-': const Color(0xFF34D399),
    };
    return types[bloodType] ?? const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF3F4F6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop, color: Color(0xFFDC2626), size: 20),
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
            // Stats Grid
            Column(
              children: [
                // Total predicted volume
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFEE2E2), Color(0xFFFEF2F2)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Volume',
                              style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatBloodVolume(bloodStats['total'] as int),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'From ${bloodStats['potentialDonors']} potential donors',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.bloodtype,
                        color: Color(0xFFDC2626),
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Blood type breakdown
                if ((bloodStats['byType'] as Map).isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Blood Type Breakdown',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: (bloodStats['byType'] as Map).length,
                          itemBuilder: (context, index) {
                            final bloodType = (bloodStats['byType'] as Map).keys.elementAt(index);
                            final data = (bloodStats['byType'] as Map)[bloodType];
                            
                            return Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: getBloodTypeColor(bloodType),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      bloodType,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatBloodVolume(data['volume']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${data['count']} donors',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF9FAFB),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Run prediction to see blood volume by type',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}