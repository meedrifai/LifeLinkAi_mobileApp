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

  // FIXED: Send email notification to donor with proper error handling
  static Future<Map<String, dynamic>> sendNotifications(List<Donor> donors) async {
    if (donors.isEmpty) {
      throw Exception('No donors to send notifications to');
    }

    List<String> successfulEmails = [];
    List<String> failedEmails = [];
    List<String> invalidEmails = [];

    print('🚀 Starting to send ${donors.length} notifications...');

    for (int i = 0; i < donors.length; i++) {
      final donor = donors[i];
      
      try {
        // Validate email format
        if (donor.email.isEmpty || !_isValidEmail(donor.email)) {
          print('❌ Invalid email for ${donor.fullname}: "${donor.email}"');
          invalidEmails.add('${donor.fullname} (${donor.email.isEmpty ? "empty email" : "invalid format"})');
          continue;
        }

        print('📧 Sending notification ${i + 1}/${donors.length} to ${donor.email}...');

        final response = await http.post(
          Uri.parse('$_baseUrl/send-email'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'to_email': donor.email.trim(),
            'fullname': donor.fullname.trim(),
            'prediction': donor.predictionValue,
            'blood_type': donor.bloodType,
            'last_donation_date': donor.lastDonationDate,
          }),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout');
          },
        );

        print('📨 Response for ${donor.email}: ${response.statusCode}');
        
        if (response.body.isNotEmpty) {
          print('📄 Response body: ${response.body}');
        }

        // Check for successful response
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Try to parse response to check for success indicator
          try {
            final responseData = jsonDecode(response.body);
            if (responseData is Map && responseData.containsKey('success')) {
              if (responseData['success'] == true) {
                successfulEmails.add(donor.email);
                print('✅ Successfully sent to ${donor.email}');
              } else {
                String errorMsg = responseData['message'] ?? 'Unknown error';
                failedEmails.add('${donor.fullname} ($errorMsg)');
                print('❌ Backend reported failure for ${donor.email}: $errorMsg');
              }
            } else {
              // If no success field, assume success based on status code
              successfulEmails.add(donor.email);
              print('✅ Successfully sent to ${donor.email} (status-based)');
            }
          } catch (jsonError) {
            // If response is not JSON, assume success based on status code
            successfulEmails.add(donor.email);
            print('✅ Successfully sent to ${donor.email} (non-JSON response)');
          }
        } else {
          // Handle HTTP error responses
          String errorMessage = 'HTTP ${response.statusCode}';
          
          try {
            final errorData = jsonDecode(response.body);
            if (errorData is Map && errorData.containsKey('message')) {
              errorMessage = errorData['message'].toString();
            } else if (errorData is Map && errorData.containsKey('error')) {
              errorMessage = errorData['error'].toString();
            }
          } catch (e) {
            if (response.body.isNotEmpty) {
              errorMessage = response.body.length > 100 
                  ? '${response.body.substring(0, 100)}...' 
                  : response.body;
            }
          }
          
          failedEmails.add('${donor.fullname} ($errorMessage)');
          print('❌ Failed to send to ${donor.email}: $errorMessage');
        }

        // Small delay between requests to avoid overwhelming the server
        if (i < donors.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }

      } catch (e) {
        String errorMsg = e.toString();
        if (errorMsg.contains('SocketException')) {
          errorMsg = 'Network connection error';
        } else if (errorMsg.contains('TimeoutException')) {
          errorMsg = 'Request timeout';
        } else if (errorMsg.contains('FormatException')) {
          errorMsg = 'Invalid server response';
        }
        
        failedEmails.add('${donor.fullname} ($errorMsg)');
        print('❌ Exception sending to ${donor.email}: $e');
      }
    }

    // Create summary
    final result = {
      'total': donors.length,
      'successful': successfulEmails.length,
      'failed': failedEmails.length,
      'invalid': invalidEmails.length,
      'successfulEmails': successfulEmails,
      'failedEmails': failedEmails,
      'invalidEmails': invalidEmails,
    };

    print('\n📊 Notification Summary:');
    print('✅ Successful: ${successfulEmails.length}');
    print('❌ Failed: ${failedEmails.length}');
    print('⚠️  Invalid emails: ${invalidEmails.length}');

    if (failedEmails.isNotEmpty) {
      print('\n❌ Failed notifications:');
      for (String failure in failedEmails) {
        print('  - $failure');
      }
    }

    if (invalidEmails.isNotEmpty) {
      print('\n⚠️  Invalid emails:');
      for (String invalid in invalidEmails) {
        print('  - $invalid');
      }
    }

    // Determine if we should throw an exception
    if (successfulEmails.isEmpty && (failedEmails.isNotEmpty || invalidEmails.isNotEmpty)) {
      throw Exception('All notifications failed to send');
    }

    return result;
  }

  // Helper method to validate email format
  static bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    return emailRegex.hasMatch(email.trim());
  }

  static Future<void> addOrUpdateDonor(Map<String, dynamic> donorData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/donors/add-or-update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(donorData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("######## Add Not Succeed ########");
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du donneur: $e');
    }
  }


  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chatboot'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': true,
          'intent': data['intent'],
          'response': data['response'],
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}