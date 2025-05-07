import 'package:flutter/material.dart';

class NotificationPopup extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onClose;

  const NotificationPopup({
    Key? key,
    required this.message,
    required this.isSuccess,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Material(
          elevation: 6.0,
          borderRadius: BorderRadius.circular(12.0),
          color: isSuccess ? Colors.green.shade500 : Colors.red.shade500,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}