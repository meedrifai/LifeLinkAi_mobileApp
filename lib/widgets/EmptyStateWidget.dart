import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.water_drop,
              size: 40,
              color: const Color(0xFFFCA5A5),
            ),
            const SizedBox(height: 8),
            Text(
              title ?? 'No donors found.',
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message ?? 'Try adjusting your filters or search criteria.',
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}