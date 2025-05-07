import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/donor.dart';

class NotificationService {
  final String apiUrl = 'https://backprojectlifelinkai.fly.dev/send-email';

  Future<void> sendEmailsToDonors(List<Donor> donors) async {
    if (donors.isEmpty) {
      return;
    }
    
    List<Future<http.Response>> requests = [];
    
    // Create request for each donor
    for (final donor in donors) {
      final request = http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to_email': donor.email,
          'fullname': donor.fullname,
          'prediction': donor.predictionValue,
        })
      );
      
      requests.add(request);
    }
    
    // Wait for all requests to complete
    try {
      final responses = await Future.wait(requests);
      
      // Check for errors
      for (final response in responses) {
        if (response.statusCode != 200) {
          throw Exception('Failed to send notification: ${response.statusCode}');
        }
      }
    } catch (error) {
      throw Exception('Notification service error: $error');
    }
  }
}