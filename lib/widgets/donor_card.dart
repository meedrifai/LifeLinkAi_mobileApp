import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donor.dart';
import 'prediction_badge.dart';

class DonorCard extends StatelessWidget {
  final Donor donor;

  const DonorCard({Key? key, required this.donor}) : super(key: key);

  Color getBloodTypeColor(String bloodType) {
    final types = {
      'A+': Colors.red.shade500,
      'A-': Colors.red.shade400,
      'B+': Colors.blue.shade500,
      'B-': Colors.blue.shade400,
      'AB+': Colors.purple.shade500,
      'AB-': Colors.purple.shade400,
      'O+': Colors.green.shade500,
      'O-': Colors.green.shade400
    };
    
    return types[bloodType] ?? Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final firstDonation = donor.firstDonationDate != null
        ? DateFormat('yyyy-MM-dd').format(donor.firstDonationDate!)
        : 'N/A';
        
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          donor.fullname,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CIN: ${donor.cin ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getBloodTypeColor(donor.bloodType),
                    borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Recency: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${donor.recencyMonths} months',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.analytics_outlined, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Frequency: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${donor.frequency}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'First: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          firstDonation,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Last: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd').format(donor.lastDonationDate),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Card Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                PredictionBadge(
                  prediction: donor.prediction,
                  color: donor.predictionColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}