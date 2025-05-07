import 'package:flutter/material.dart';

class PredictionBadge extends StatelessWidget {
  final String prediction;
  final String? color;

  const PredictionBadge({
    Key? key,
    required this.prediction,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color dotColor;
    
    if (color == "green") {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      dotColor = Colors.green.shade500;
    } else if (color == "red") {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      dotColor = Colors.red.shade500;
    } else {
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.grey.shade800;
      dotColor = Colors.grey.shade400;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}