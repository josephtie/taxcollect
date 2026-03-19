class ContribuableDto {
  final int? id;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? activites;
  final String? email;
  final String? adresse;
  final double? latitude;
  final double? longitude;
  final int? zoneCollecteId;
  final List<int>? taxeIds;

  ContribuableDto({
    this.id,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.activites,
    this.email,
    this.adresse,
    this.latitude,
    this.longitude,
    this.zoneCollecteId,
    this.taxeIds,
  });

  factory ContribuableDto.fromJson(Map<String, dynamic> json) {
    return ContribuableDto(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'],
      activites: json['activites'],
      email: json['email'],
      adresse: json['adresse'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      zoneCollecteId: json['zoneCollecteId'],
      taxeIds: json['taxeIds'] != null
          ? List<int>.from(json['taxeIds'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'activites': activites,
      'email': email,
      'adresse': adresse,
      'latitude': latitude,
      'longitude': longitude,
      'zoneCollecteId': zoneCollecteId,
      'taxeIds': taxeIds,
    };
  }

  String get fullName => '$prenom $nom';
  
  String get displayName => fullName.isNotEmpty ? fullName : 'Contribuable';
}

class AgentsDto {
  final int? id;
  final String nom;
  final String prenom;
  final String? email;
  final String? telephone;
  final List<int>? zoneIds;

  AgentsDto({
    this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.telephone,
    this.zoneIds,
  });

  factory AgentsDto.fromJson(Map<String, dynamic> json) {
    return AgentsDto(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'],
      telephone: json['telephone'],
      zoneIds: json['zoneIds'] != null
          ? List<int>.from(json['zoneIds'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'zoneIds': zoneIds,
    };
  }

  String get fullName => '$prenom $nom';
  
  String get displayName => fullName.isNotEmpty ? fullName : 'Agent';

  AgentsDto copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    List<int>? zoneIds,
  }) {
    return AgentsDto(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      zoneIds: zoneIds ?? this.zoneIds,
    );
  }
}

class ZoneCollectDto {
  final int? id;
  final String nom;
  final int? quartierId;

  ZoneCollectDto({
    this.id,
    required this.nom,
    this.quartierId,
  });

  factory ZoneCollectDto.fromJson(Map<String, dynamic> json) {
    return ZoneCollectDto(
      id: json['id'],
      nom: json['nom'] ?? '',
      quartierId: json['quartierId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'quartierId': quartierId,
    };
  }
}

class QuartierDto {
  final int? id;
  final String nom;
  final int? communeId;

  QuartierDto({
    this.id,
    required this.nom,
    this.communeId,
  });

  factory QuartierDto.fromJson(Map<String, dynamic> json) {
    return QuartierDto(
      id: json['id'],
      nom: json['nom'] ?? '',
      communeId: json['communeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'communeId': communeId,
    };
  }
}

class CommuneDto {
  final int? id;
  final String nom;

  CommuneDto({
    this.id,
    required this.nom,
  });

  factory CommuneDto.fromJson(Map<String, dynamic> json) {
    return CommuneDto(
      id: json['id'],
      nom: json['nom'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}

class TaxeDto {
  final int? id;
  final String nom;
  final String? description;
  final double? taux;
  
  // Aliases for backward compatibility
  String get libelle => nom;
  double? get montant => taux;

  TaxeDto({
    this.id,
    required this.nom,
    this.description,
    this.taux,
  });

  factory TaxeDto.fromJson(Map<String, dynamic> json) {
    return TaxeDto(
      id: json['id'],
      nom: json['nom'] ?? json['libelle'] ?? '',
      description: json['description'],
      taux: json['taux']?.toDouble() ?? json['montant']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'libelle': nom, // Include both for compatibility
      'description': description,
      'taux': taux,
      'montant': taux, // Include both for compatibility
    };
  }
}
