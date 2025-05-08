class Donor {
  final String? id;
  final String fullname;
  final String? cin;
  final String bloodType;
  final String? email;
  final DateTime? firstDonationDate;
  final DateTime lastDonationDate;
  final int frequency;
  final String? prediction;
  final int? predictionValue; // 1 = will donate, 0 = will not donate
  final String? predictionColor;

  Donor({
    this.id,
    required this.fullname,
    this.cin,
    required this.bloodType,
    this.email,
    this.firstDonationDate,
    required this.lastDonationDate,
    this.frequency = 0,
    this.prediction = "Not defined",
    this.predictionValue,
    this.predictionColor,
  });

  Donor copyWith({
    String? id,
    String? fullname,
    String? cin,
    String? bloodType,
    String? email,
    DateTime? firstDonationDate,
    DateTime? lastDonationDate,
    int? frequency,
    String? prediction,
    int? predictionValue,
    String? predictionColor,
  }) {
    return Donor(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      cin: cin ?? this.cin,
      bloodType: bloodType ?? this.bloodType,
      email: email ?? this.email,
      firstDonationDate: firstDonationDate ?? this.firstDonationDate,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      frequency: frequency ?? this.frequency,
      prediction: prediction ?? this.prediction,
      predictionValue: predictionValue ?? this.predictionValue,
      predictionColor: predictionColor ?? this.predictionColor,
    );
  }

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'],
      fullname: json['fullname'] ?? 'Unknown',
      cin: json['cin'],
      bloodType: json['blood_type'] ?? 'Unknown',
      email: json['email'],
      firstDonationDate: json['first_donation_date'] != null 
          ? DateTime.parse(json['first_donation_date']) 
          : null,
      lastDonationDate: json['last_donation_date'] != null 
          ? DateTime.parse(json['last_donation_date']) 
          : DateTime.now(),
      frequency: json['frequence'] ?? 0,
      prediction: json['prediction'] ?? 'Not defined',
      predictionValue: json['predictionValue'],
      predictionColor: json['predictionColor'],
    );
  }

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
      'predictionValue': predictionValue,
      'predictionColor': predictionColor,
    };
  }

  // Calculate recency in months from now
  int get recencyMonths {
    return DateTime.now().difference(lastDonationDate).inDays ~/ 30;
  }

  // Calculate time since first donation in months
  int? get timeMonths {
    if (firstDonationDate == null) return null;
    return DateTime.now().difference(firstDonationDate!).inDays ~/ 30;
  }
}

class BloodStats {
  final int totalVolume;
  final int potentialDonors;
  final Map<String, BloodTypeStats> byType;

  BloodStats({
    this.totalVolume = 0,
    this.potentialDonors = 0,
    this.byType = const {},
  });

  BloodStats copyWith({
    int? totalVolume,
    int? potentialDonors,
    Map<String, BloodTypeStats>? byType,
  }) {
    return BloodStats(
      totalVolume: totalVolume ?? this.totalVolume,
      potentialDonors: potentialDonors ?? this.potentialDonors,
      byType: byType ?? this.byType,
    );
  }
}

class BloodTypeStats {
  final int count;
  final int volume;

  BloodTypeStats({
    this.count = 0,
    this.volume = 0,
  });
}

enum NotificationType { success, error }

class NotificationInfo {
  final String message;
  final NotificationType type;

  NotificationInfo({
    required this.message,
    required this.type,
  });
}