import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/donor.dart';

class DonorProvider with ChangeNotifier {
  List<Donor> _donors = [];
  BloodStats _bloodStats = BloodStats();
  bool _isLoading = false;

  List<Donor> get donors => _donors;
  BloodStats get bloodStats => _bloodStats;
  bool get isLoading => _isLoading;

  // Base URL for API calls
  final String baseUrl = 'https://backprojectlifelinkai.fly.dev';

  // Get filtered donors based on search text
  List<Donor> getFilteredDonors(String searchText) {
    if (searchText.isEmpty) {
      return _donors;
    }
    return _donors.where((donor) => 
      donor.cin != null && 
      donor.cin!.toLowerCase().contains(searchText.toLowerCase())
    ).toList();
  }

  // Fetch donors from API
  Future<void> fetchDonors() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mocked data for demonstration - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      _donors = _generateMockDonors();
      _updateBloodStats();
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Make prediction for all donors
  Future<void> predictDonors() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Prepare samples data for prediction
      final samples = _donors.map((donor) => {
        'recency': donor.recencyMonths,
        'frequency': donor.frequency,
        'time': donor.timeMonths ?? 0,
      }).toList();

      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'samples': samples}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> predictions = data['predictions'];

        // Update donors with predictions
        for (int i = 0; i < _donors.length; i++) {
          _donors[i] = _donors[i].copyWith(
            prediction: predictions[i] == 1 ? 'Will Donate' : 'Will Not Donate',
            predictionValue: predictions[i],
            predictionColor: predictions[i] == 1 ? 'green' : 'red',
          );
        }

        _updateBloodStats();
      } else {
        throw Exception('Failed to predict donors');
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send notifications to donors based on prediction value
  Future<void> sendNotifications(int predictionValue) async {
    final targets = _donors.where((d) => d.predictionValue == predictionValue).toList();

    try {
      for (final donor in targets) {
        if (donor.email != null) {
          await http.post(
            Uri.parse('$baseUrl/send-email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'to_email': donor.email,
              'fullname': donor.fullname,
              'prediction': donor.predictionValue,
            }),
          );
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  // Update blood statistics based on current donor predictions
  void _updateBloodStats() {
    const bloodPerDonor = 250; // ml per donor
    int total = 0;
    int potentialDonors = 0;
    Map<String, BloodTypeStats> byType = {};

    for (final donor in _donors) {
      if (donor.predictionValue == 1) {
        potentialDonors++;
        total += bloodPerDonor;

        // Group by blood type
        if (!byType.containsKey(donor.bloodType)) {
          byType[donor.bloodType] = BloodTypeStats(count: 0, volume: 0);
        }

        byType[donor.bloodType] = BloodTypeStats(
          count: byType[donor.bloodType]!.count + 1,
          volume: byType[donor.bloodType]!.volume + bloodPerDonor,
        );
      }
    }

    _bloodStats = BloodStats(
      totalVolume: total,
      potentialDonors: potentialDonors,
      byType: byType,
    );

    notifyListeners();
  }

  // Generate mock donors for testing
  List<Donor> _generateMockDonors() {
    return [
      Donor(
        id: '1',
        fullname: 'Mohammed Alaoui',
        cin: 'A123456',
        bloodType: 'A+',
        email: 'mohammed@example.com',
        firstDonationDate: DateTime(2018, 5, 15),
        lastDonationDate: DateTime(2025, 1, 1),
        frequency: 8,
      ),
      Donor(
        id: '2',
        fullname: 'Fatima Benali',
        cin: 'B789012',
        bloodType: 'O-',
        email: 'simorifai181@gmail.com',
        firstDonationDate: DateTime(2024, 3, 7),
        lastDonationDate: DateTime(2025, 2, 21),
        frequency: 7,
      ),
      Donor(
        id: '3',
        fullname: 'Youssef El Amrani',
        cin: 'C345678',
        bloodType: 'B+',
        email: 'youssef@example.com',
        firstDonationDate: DateTime(2019, 8, 12),
        lastDonationDate: DateTime(2023, 9, 5),
        frequency: 4,
      ),
      Donor(
        id: '4',
        fullname: 'Amal Kaddouri',
        cin: 'D901234',
        bloodType: 'AB+',
        email: 'amal@example.com',
        firstDonationDate: DateTime(2021, 1, 30),
        lastDonationDate: DateTime(2024, 1, 15),
        frequency: 2,
      ),
      Donor(
        id: '5',
        fullname: 'Karim Tazi',
        cin: 'E567890',
        bloodType: 'A-',
        email: 'karim@example.com',
        firstDonationDate: DateTime(2017, 11, 9),
        lastDonationDate: DateTime(2023, 6, 22),
        frequency: 8,
      ),
    ];
  }
}