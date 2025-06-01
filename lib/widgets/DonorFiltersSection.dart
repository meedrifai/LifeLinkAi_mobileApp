import 'package:flutter/material.dart';
import 'package:lifelinkai/widgets/donor_search_bar.dart';

class DonorFiltersSection extends StatelessWidget {
  final String selectedFilter;
  final Function(String?) onFilterChanged;
  final Function(String) onSearchChanged;

  const DonorFiltersSection({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search Bar
          DonorSearchBar(onChanged: onSearchChanged),
          const SizedBox(height: 12),
          // 🔽 Filter Bar
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Donors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<String>(
              value: selectedFilter,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'all',
                  child: Text('All Donors'),
                ),
                DropdownMenuItem(
                  value: 'predicted',
                  child: Text('Predicted Donors'),
                ),
                DropdownMenuItem(
                  value: 'not_predicted',
                  child: Text('Not Predicted'),
                ),
                DropdownMenuItem(
                  value: 'will_donate',
                  child: Text('Will Donate'),
                ),
                DropdownMenuItem(
                  value: 'wont_donate',
                  child: Text('Won\'t Donate'),
                ),
              ],
              onChanged: onFilterChanged,
            ),
          ),
        ],
      ),
    );
  }
}
