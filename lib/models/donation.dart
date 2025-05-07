class Donation {
  final String id;
  final String fullname;
  final String cin;
  final String numTel;
  final String email;
  final String bloodType;
  final int frequence;
  final String firstDonationDate;
  final String lastDonationDate;

  Donation({
    required this.id,
    required this.fullname,
    required this.cin,
    required this.numTel,
    required this.email,
    required this.bloodType,
    required this.frequence,
    required this.firstDonationDate,
    required this.lastDonationDate,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      cin: json['cin'] as String? ?? '',
      numTel: json['num_tel'] as String? ?? '',
      email: json['email'] as String? ?? '',
      bloodType: json['blood_type'] as String? ?? '',
      frequence: json['frequence'] as int? ?? 0,
      firstDonationDate: json['first_donation_date'] as String? ?? '',
      lastDonationDate: json['last_donation_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'cin': cin,
      'num_tel': numTel,
      'email': email,
      'blood_type': bloodType,
      'frequence': frequence,
      'first_donation_date': firstDonationDate,
      'last_donation_date': lastDonationDate,
    };
  }
}