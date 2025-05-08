import 'package:http/http.dart' as http;
import 'package:lifelinkai/models/donor.dart';
import 'dart:convert';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/models/donation.dart';

class ApiService {
  static const _baseUrl = 'https://backprojectlifelinkai.fly.dev';

  static Future<User?> login(String email, String password) async {
    try {
      print('Making login request to $_baseUrl/login');

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the response has the expected structure
        if (data == null) {
          print("Error: Response data is null");
          return null;
        }

        try {
          final user = User.fromJson(data);

          // Validate that essential fields are not empty
          if (user.id.isEmpty || user.email.isEmpty) {
            print(
              "Warning: User has empty essential fields - ID: '${user.id}', Email: '${user.email}'",
            );
          }

          // Additional detailed logging to help debug
          print('Parsed user data:');
          print('- ID: "${user.id}"');
          print('- Email: "${user.email}"');
          print('- City: "${user.city}"');
          print('- Hospital: "${user.nomHospital}"');
          print('- Role: "${user.role}"');

          return user;
        } catch (e) {
          print("Error parsing user: $e");
          return null;
        }
      } else {
        print(
          "Failed to login: ${response.statusCode}, body: ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("Network or other error: $e");
      return null;
    }
  }

  static Future<List<Donation>> fetchDonationsByHospital(
    String hospitalName,
  ) async {
    try {
      print('Fetching donations for hospital: $hospitalName');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/donations?hospital=${Uri.encodeComponent(hospitalName)}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        print('Fetched ${data.length} donations');

        return data.map((item) => Donation.fromJson(item)).toList();
      } else {
        print("Failed to fetch donations: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Network or other error when fetching donations: $e");
      return [];
    }
  }

  // Make prediction for donors
  static Future<List<int>> predictDonors(
    List<Map<String, dynamic>> features,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'samples': features}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return List<int>.from(data['predictions']);
    } else {
      throw Exception('Failed to predict donors');
    }
  }

  // Send email notification to donor
  static Future<void> sendNotifications(List<Donor> donors) async {
    for (final donor in donors) {
      await http.post(
        Uri.parse('$_baseUrl/send-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to_email': donor.email,
          'fullname': donor.fullname,
          'prediction': donor.predictionValue,
        }),
      );
    }
  }
}
