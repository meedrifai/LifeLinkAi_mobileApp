import 'package:flutter/material.dart';

class BloodStatsDashboard extends StatelessWidget {
  // Changed from Map<String, dynamic> to Map to accept any Map type
  final Map bloodStats;

  const BloodStatsDashboard({Key? key, required this.bloodStats}) : super(key: key);

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
    return types[bloodType] ?? Colors.grey;
  }

  String formatBloodVolume(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ml';
  }

  @override
  Widget build(BuildContext context) {
    // Safely access the byType map with null checks and proper casting
    final Map byType = bloodStats['byType'] as Map? ?? {};
    final int totalVolume = bloodStats['total'] as int? ?? 0;
    final int potentialDonors = bloodStats['potentialDonors'] as int? ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop, color: Color(0xFFDC2626), size: 22),
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
            
            // Stats grid
            Column(
              children: [
                // Total volume card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Column(
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
                            formatBloodVolume(totalVolume),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'From $potentialDonors potential donors',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Blood types grid
                byType.isNotEmpty
                    ? GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: byType.entries.map((entry) {
                          final String bloodType = entry.key.toString();
                          final Map data = entry.value as Map;
                          final int volume = data['volume'] as int? ?? 0;
                          final int count = data['count'] as int? ?? 0;
                          
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
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
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatBloodVolume(volume),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '$count donors',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
                            const SizedBox(width: 8),
                            const Text(
                              'Run prediction to see blood volume by type',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
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