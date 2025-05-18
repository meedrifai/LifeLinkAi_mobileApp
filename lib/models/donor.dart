class Donor {
  final String id;
  final String fullname;
  final String cin;
  final String bloodType;
  final String lastDonationDate;
  final String firstDonationDate;
  final int? frequency;
  final String email;
  final String? prediction;
  final String? predictionColor;
  final int? predictionValue;

  Donor({
    required this.id,
    required this.fullname,
    required this.cin,
    required this.bloodType,
    required this.lastDonationDate,
    required this.firstDonationDate,
    this.frequency,
    required this.email,
    this.prediction,
    this.predictionColor,
    this.predictionValue,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'] ?? '',
      fullname: json['fullname'] ?? '',
      cin: json['cin'],
      bloodType: json['blood_type'] ?? 'Unknown',
      lastDonationDate: json['last_donation_date'] ?? '',
      firstDonationDate: json['first_donation_date'],
      frequency: json['frequence'],
      email: json['email'] ?? '',
      prediction: json['prediction'],
      predictionColor: json['predictionColor'],
      predictionValue: json['predictionValue'],
    );
  }

  Donor copyWith({
    String? id,
    String? fullname,
    String? cin,
    String? bloodType,
    String? lastDonationDate,
    String? firstDonationDate,
    int? frequency,
    String? email,
    String? prediction,
    String? predictionColor,
    int? predictionValue,
  }) {
    return Donor(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      cin: cin ?? this.cin,
      bloodType: bloodType ?? this.bloodType,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      firstDonationDate: firstDonationDate ?? this.firstDonationDate,
      frequency: frequency ?? this.frequency,
      email: email ?? this.email,
      prediction: prediction ?? this.prediction,
      predictionColor: predictionColor ?? this.predictionColor,
      predictionValue: predictionValue ?? this.predictionValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'cin': cin,
      'blood_type': bloodType,
      'last_donation_date': lastDonationDate,
      'first_donation_date': firstDonationDate,
      'frequence': frequency,
      'email': email,
      'prediction': prediction,
      'predictionColor': predictionColor,
      'predictionValue': predictionValue,
    };
  }
}