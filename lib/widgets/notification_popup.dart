import 'package:flutter/material.dart';
import '../models/donor.dart';

class NotificationPopup extends StatelessWidget {
  final NotificationInfo notification;
  final VoidCallback onDismiss;

  const NotificationPopup({
    Key? key,
    required this.notification,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSuccess = notification.type == NotificationType.success;
    
    return Container(
      width: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: isSuccess ? Colors.green[500]! : Colors.red[500]!,
            width: 4,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green[100] : Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check : Icons.close,
                color: isSuccess ? Colors.green[700] : Colors.red[700],
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                notification.message,
                style: TextStyle(
                  color: isSuccess ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: Colors.grey[500],
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}