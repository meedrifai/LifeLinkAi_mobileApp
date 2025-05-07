class Donor {
  final String? id;
  final String fullname;
  final String? cin;
  final String bloodType;
  final String email;
  final DateTime? firstDonationDate;
  final DateTime lastDonationDate;
  final int frequency;
  String prediction;
  String? predictionColor;
  int? predictionValue;

  Donor({
    this.id,
    required this.fullname,
    this.cin,
    required this.bloodType,
    required this.email,
    this.firstDonationDate,
    required this.lastDonationDate,
    required this.frequency,
    this.prediction = 'Not defined',
    this.predictionColor,
    this.predictionValue,
  });

  // Create a donor from JSON map
  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'],
      fullname: json['fullname'] ?? 'Unknown',
      cin: json['cin'],
      bloodType: json['blood_type'] ?? 'Unknown',
      email: json['email'] ?? '',
      firstDonationDate: json['first_donation_date'] != null 
          ? DateTime.parse(json['first_donation_date']) 
          : null,
      lastDonationDate: json['last_donation_date'] != null 
          ? DateTime.parse(json['last_donation_date'])
          : DateTime.now(),
      frequency: json['frequence'] ?? 0,
      prediction: json['prediction'] ?? 'Not defined',
      predictionColor: json['predictionColor'],
      predictionValue: json['predictionValue'],
    );
  }

  // Convert donor to JSON map for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'cin': cin,
      'blood_type': bloodType,
      'email': email,
      'first_donation_date': firstDonationDate?.toIso8601String(),
      'last_donation_date': lastDonationDate.toIso8601String(),
      'frequence': frequency,
      'prediction': prediction,
      'predictionColor': predictionColor,
      'predictionValue': predictionValue,
    };
  }

  // Create a copy of this donor with different attributes
  Donor copyWith({
    String? prediction,
    String? predictionColor,
    int? predictionValue,
  }) {
    return Donor(
      id: id,
      fullname: fullname,
      cin: cin,
      bloodType: bloodType,
      email: email,
      firstDonationDate: firstDonationDate,
      lastDonationDate: lastDonationDate,
      frequency: frequency,
      prediction: prediction ?? this.prediction,
      predictionColor: predictionColor ?? this.predictionColor,
      predictionValue: predictionValue ?? this.predictionValue,
    );
  }

  // Calculate recency in months
  int get recencyMonths {
    return DateTime.now().difference(lastDonationDate).inDays ~/ 30;
  }

  // Calculate time in months
  int get timeMonths {
    if (firstDonationDate == null) return 0;
    return DateTime.now().difference(firstDonationDate!).inDays ~/ 30;
  }

  // Get features for prediction model
  Map<String, dynamic> getFeatures() {
    return {
      'recency': recencyMonths,
      'frequency': frequency,
      'time': timeMonths
    };
  }
}