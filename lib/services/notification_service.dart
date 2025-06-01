import 'package:flutter/material.dart';
import 'package:lifelinkai/models/donor.dart';
import 'package:lifelinkai/services/api_service.dart';

class NotificationService {
  Future<void> sendNotifications(
    BuildContext context,
    List<Donor> donorList,
    int predictedValue, {
    required Function(bool) onLoadingChanged,
    required Function(String, bool) onNotification,
  }) async {
    final targets = donorList.where((d) => d.predictionValue == predictedValue).toList();
    
    if (targets.isEmpty) {
      onNotification(
        predictedValue == 1 
          ? "No donors predicted to donate found." 
          : "No donors predicted not to donate found.", 
        false
      );
      return;
    }

    final confirmed = await _showConfirmationDialog(
      context,
      'Send Notifications',
      'Send notifications to ${targets.length} donors?',
    );
    
    if (!confirmed) return;

    onLoadingChanged(true);

    try {
      print('🚀 Starting notification process for ${targets.length} donors...');
      
      final result = await ApiService.sendNotifications(targets);
      
      final successful = result['successful'] as int;
      final failed = result['failed'] as int;
      final invalid = result['invalid'] as int;
      final total = result['total'] as int;

      if (successful == total) {
        onNotification("🎉 All $successful notifications sent successfully!", true);
      } else if (successful > 0) {
        String message = "📊 Mixed results:\n";
        message += "✅ Successful: $successful\n";
        if (failed > 0) message += "❌ Failed: $failed\n";
        if (invalid > 0) message += "⚠️ Invalid emails: $invalid\n";
        message += "\nCheck console for details.";
        
        onNotification(message, successful > failed);
      } else {
        onNotification(
          "❌ All notifications failed to send.\nPlease check your internet connection and try again.", 
          false
        );
      }

      if (result['failedEmails'] != null && (result['failedEmails'] as List).isNotEmpty) {
        print('❌ Failed notifications details:');
        for (String failure in result['failedEmails'] as List<String>) {
          print('  - $failure');
        }
      }

      if (result['invalidEmails'] != null && (result['invalidEmails'] as List).isNotEmpty) {
        print('⚠️ Invalid emails details:');
        for (String invalid in result['invalidEmails'] as List<String>) {
          print('  - $invalid');
        }
      }

    } catch (error) {
      print('💥 Notification error: $error');
      
      String errorMessage = "Failed to send notifications.";
      
      String errorStr = error.toString().toLowerCase();
      if (errorStr.contains('network') || errorStr.contains('connection')) {
        errorMessage = "Network error. Please check your internet connection and try again.";
      } else if (errorStr.contains('timeout')) {
        errorMessage = "Request timeout. The server is taking too long to respond.";
      } else if (errorStr.contains('server') || errorStr.contains('500')) {
        errorMessage = "Server error. Please try again later.";
      } else if (errorStr.contains('all notifications failed')) {
        errorMessage = "All notifications failed to send. Please check your email configuration.";
      }
      
      onNotification(errorMessage, false);

    } finally {
      onLoadingChanged(false);
    }
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title, 
    String message,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.email, color: Color(0xFFDC2626), size: 24),
              const SizedBox(width: 8),
              Flexible(child: Text(title)),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}