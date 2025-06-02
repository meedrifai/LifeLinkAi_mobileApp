import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hospital_data.dart';

class HospitalDataService {
  static HospitalData? _cachedData;

  static Future<HospitalData> loadHospitalData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      // Charger depuis les assets
      final String jsonString = await rootBundle.loadString('data/hospital_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _cachedData = HospitalData.fromJson(jsonData);
      return _cachedData!;
    } catch (e) {
      print('Error loading hospital data: $e');
      // Retourner des données par défaut en cas d'erreur
      return HospitalData(regions: []);
    }
  }

  static void clearCache() {
    _cachedData = null;
  }
}