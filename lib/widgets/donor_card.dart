import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donor.dart';

class DonorCard extends StatelessWidget {
  final Donor donor;

  const DonorCard({
    Key? key, 
    required this.donor,
  }) : super(key: key);

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

  Widget _getPredictionBadge(String prediction, String? color) {
    if (color == "green") {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green[500],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            prediction,
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else if (color == "red") {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.red[500],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            prediction,
            style: TextStyle(
              color: Colors.red[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            prediction,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final firstDonation = donor.firstDonationDate != null 
        ? dateFormat.format(donor.firstDonationDate!)
        : 'N/A';
    final lastDonation = dateFormat.format(donor.lastDonationDate);
    
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
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[100]!),
              ),
            ),
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
                                color: Color(0xFF1F2937),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (donor.cin != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'CIN: ${donor.cin}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _getBloodTypeColor(donor.bloodType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    donor.bloodType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow('Recency:', '${donor.recencyMonths} months', Icons.access_time),
                const SizedBox(height: 8),
                _infoRow('Frequency:', '${donor.frequency}', Icons.trending_up),
                const SizedBox(height: 8),
                _infoRow('First donation:', firstDonation, Icons.calendar_today),
                const SizedBox(height: 8),
                _infoRow('Last donation:', lastDonation, Icons.calendar_month),
              ],
            ),
          ),
          
          // Card Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
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
                    color: Colors.grey[700],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: donor.predictionColor == 'green'
                        ? Colors.green[50]
                        : donor.predictionColor == 'red'
                            ? Colors.red[50]
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _getPredictionBadge(
                    donor.prediction ?? 'Not defined',
                    donor.predictionColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}