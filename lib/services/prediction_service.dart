import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/donor.dart';

class PredictionService {
  final String apiUrl = 'https://backprojectlifelinkai.fly.dev/predict';

  Future<List<Donor>> predictDonations(List<Donor> donors) async {
    // Extract features from donors for prediction
    final samples = donors.map((donor) => donor.getFeatures()).toList();
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'samples': samples})
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to predict donations: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      final List<dynamic> predictions = data['predictions'];
      
      // Update donors with predictions
      List<Donor> updatedDonors = [];
      for (int i = 0; i < donors.length; i++) {
        final willDonate = predictions[i] == 1;
        updatedDonors.add(donors[i].copyWith(
          prediction: willDonate ? 'Will Donate' : 'Will Not Donate',
          predictionValue: predictions[i],
          predictionColor: willDonate ? 'green' : 'red',
        ));
      }
      
      return updatedDonors;
    } catch (error) {
      // Re-throw with more context
      throw Exception('Prediction service error: $error');
    }
  }
}