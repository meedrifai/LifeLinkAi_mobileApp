class HospitalData {
  final List<Region> regions;

  HospitalData({required this.regions});

  factory HospitalData.fromJson(Map<String, dynamic> json) {
    return HospitalData(
      regions: (json['regions'] as List)
          .map((region) => Region.fromJson(region))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regions': regions.map((region) => region.toJson()).toList(),
    };
  }
}

class Region {
  final String region;
  final List<Delegation> delegations;

  Region({required this.region, required this.delegations});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      region: json['region'],
      delegations: (json['delegations'] as List)
          .map((delegation) => Delegation.fromJson(delegation))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'delegations': delegations.map((delegation) => delegation.toJson()).toList(),
    };
  }
}

class Delegation {
  final String delegation;
  final List<Commune> communes;

  Delegation({required this.delegation, required this.communes});

  factory Delegation.fromJson(Map<String, dynamic> json) {
    return Delegation(
      delegation: json['delegation'],
      communes: (json['communes'] as List)
          .map((commune) => Commune.fromJson(commune))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delegation': delegation,
      'communes': communes.map((commune) => commune.toJson()).toList(),
    };
  }
}

class Commune {
  final String commune;
  final List<String> hopitaux;

  Commune({required this.commune, required this.hopitaux});

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(
      commune: json['commune'],
      hopitaux: List<String>.from(json['hopitaux'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commune': commune,
      'hopitaux': hopitaux,
    };
  }
}