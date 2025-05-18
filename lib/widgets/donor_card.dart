import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donor.dart';

class DonorCard extends StatelessWidget {
  final Donor donor;

  const DonorCard({super.key, required this.donor});

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

  Widget getPredictionBadge(String prediction, String? color) {
    late Color backgroundColor;
    late Color textColor;
    late Color dotColor;

    if (color == "green") {
      backgroundColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
      dotColor = const Color(0xFF10B981);
    } else if (color == "red") {
      backgroundColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFB91C1C);
      dotColor = const Color(0xFFEF4444);
    } else {
      backgroundColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF4B5563);
      dotColor = const Color(0xFF9CA3AF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            prediction,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    
    final DateTime lastDonation = DateTime.parse(donor.lastDonationDate);
    final String formattedLastDonation = dateFormatter.format(lastDonation);
    
    // ignore: unnecessary_null_comparison
    final String formattedFirstDonation = donor.firstDonationDate != null 
        ? dateFormatter.format(DateTime.parse(donor.firstDonationDate))
        : 'N/A';
    
    final int recency = DateTime.now().difference(lastDonation).inDays ~/ 30;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              donor.fullname,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 26.0),
                        child: Text(
                          'CIN: ${donor.cin}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getBloodTypeColor(donor.bloodType),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    donor.bloodType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Card Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow('Recency:', '$recency months', Icons.access_time),
                const SizedBox(height: 8),
                _buildInfoRow('Frequency:', '${donor.frequency ?? 0}', Icons.show_chart),
                const SizedBox(height: 8),
                _buildInfoRow('First Donation:', formattedFirstDonation, Icons.calendar_today),
                const SizedBox(height: 8),
                _buildInfoRow('Last Donation:', formattedLastDonation, Icons.calendar_today),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Card Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prediction:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                getPredictionBadge(donor.prediction ?? 'Not defined', donor.predictionColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}