class User {
  final String id;
  final String email;
  final String city;
  final String nomHospital;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.city,
    required this.nomHospital,
    required this.role,
  });

  // Factory constructor to create a User from JSON with correct nested structure handling
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle the nested "user" object if it exists
    final userData = json.containsKey('user') ? json['user'] as Map<String, dynamic> : json;
    
    return User(
      id: userData['id'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      city: userData['city'] as String? ?? '',
      nomHospital: userData['nom_hospital'] as String? ?? '',
      role: userData['role'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, city: $city, nomHospital: $nomHospital, role: $role}';
  }

  // To convert User back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'city': city,
      'nom_hospital': nomHospital,
      'role': role,
    };
  }
}