import 'package:flutter/material.dart';

class Donation {
  final String id;
  final String donorName;
  final String bloodType;
  final DateTime date;
  final String status;

  Donation({
    required this.id,
    required this.donorName,
    required this.bloodType,
    required this.date,
    required this.status,
  });
}

class DonationProvider with ChangeNotifier {
  final List<Donation> _donations = [];
  bool _isLoading = false;
  String? _error;

  List<Donation> get donations => _donations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> fetchDonations() async {
    try {
      setLoading(true);
      setError(null);
      // TODO: Implement your API call here
      // For example:
      // final response = await donationService.getDonations();
      // _donations = response.data.map((json) => Donation.fromJson(json)).toList();
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  Future<void> addDonation(Donation donation) async {
    try {
      setLoading(true);
      setError(null);
      // TODO: Implement your API call here
      _donations.add(donation);
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  Future<void> updateDonationStatus(String donationId, String newStatus) async {
    try {
      setLoading(true);
      setError(null);
      // TODO: Implement your API call here
      final index = _donations.indexWhere((d) => d.id == donationId);
      if (index != -1) {
        final donation = _donations[index];
        _donations[index] = Donation(
          id: donation.id,
          donorName: donation.donorName,
          bloodType: donation.bloodType,
          date: donation.date,
          status: newStatus,
        );
        notifyListeners();
      }
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }
} 