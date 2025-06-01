import 'package:flutter/material.dart';

class DonorSummaryChips extends StatelessWidget {
  final int totalCount;
  final int filteredCount;
  final int displayedCount;

  const DonorSummaryChips({
    super.key,
    required this.totalCount,
    required this.filteredCount,
    required this.displayedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryChip('Total: $totalCount'),
          const SizedBox(width: 8),
          _buildSummaryChip('Filtered: $filteredCount'),
          const SizedBox(width: 8),
          _buildSummaryChip('Showing: $displayedCount'),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}