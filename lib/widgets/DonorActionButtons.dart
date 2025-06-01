import 'package:flutter/material.dart';
import 'package:lifelinkai/models/donor.dart';

class DonorActionButtons extends StatelessWidget {
  final List<Donor> donorList;
  final bool isLoading;
  final bool isSending;
  final VoidCallback onPredict;
  final Function(int) onSendNotifications;

  const DonorActionButtons({
    super.key,
    required this.donorList,
    required this.isLoading,
    required this.isSending,
    required this.onPredict,
    required this.onSendNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final willDonateCount = donorList.where((d) => d.predictionValue == 1).length;
    final wontDonateCount = donorList.where((d) => d.predictionValue == 0).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPredictButton(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildNotifyButton(true, willDonateCount)),
              const SizedBox(width: 12),
              Expanded(child: _buildNotifyButton(false, wontDonateCount)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (isLoading || isSending) ? null : onPredict,
        icon: Icon(
          isLoading ? Icons.hourglass_empty : Icons.psychology,
          size: 18,
        ),
        label: Text(
          isLoading ? 'Predicting...' : 'Run Prediction',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildNotifyButton(bool isWillDonate, int count) {
    final isEnabled = !isSending && count > 0;
    final color = isWillDonate ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final icon = isWillDonate ? Icons.notifications : Icons.notifications_off;
    final label = isWillDonate ? 'Will Donate' : 'Won\'t Donate';

    return ElevatedButton.icon(
      onPressed: isEnabled
          ? () => onSendNotifications(isWillDonate ? 1 : 0)
          : null,
      icon: Icon(
        isSending ? Icons.hourglass_empty : icon,
        size: 16,
      ),
      label: Column(
        children: [
          Text(
            isSending ? 'Sending...' : label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            '($count)',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? color : Colors.grey[300],
        foregroundColor: isEnabled ? Colors.white : Colors.grey[600],
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }
}