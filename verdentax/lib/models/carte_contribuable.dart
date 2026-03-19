import 'dart:convert';

/// Types de cartes contribuables
enum CarteType {
  paper('Papier', 'paper'),
  pvc('PVC', 'pvc'),
  digital('Numérique', 'digital');

  const CarteType(this.label, this.code);
  final String label;
  final String code;
}

/// Statuts des cartes contribuables
enum CarteStatus {
  draft('Brouillon', 'draft'),
  active('Active', 'active'),
  expired('Expirée', 'expired'),
  suspended('Suspendue', 'suspended'),
  revoked('Révoquée', 'revoked'),
  lost('Perdue', 'lost'),
  damaged('Endommagée', 'damaged');

  const CarteStatus(this.label, this.code);
  final String label;
  final String code;
}

/// Niveaux de sécurité QR
enum QRSecurityLevel {
  basic('Basique', 'basic'),
  standard('Standard', 'standard'),
  high('Élevé', 'high'),
  maximum('Maximum', 'maximum');

  const QRSecurityLevel(this.label, this.code);
  final String label;
  final String code;
}

/// Types d'erreurs de vérification
enum VerificationError {
  notFound('Non trouvée'),
  invalid('Invalide'),
  expired('Expirée'),
  suspended('Suspendue'),
  revoked('Révoquée'),
  damaged('Endommagée'),
  qrCodeInvalid('Code QR invalide'),
  checksumFailed('Checksum échoué'),
  networkError('Erreur réseau'),
  unknown('Erreur inconnue');

  const VerificationError(this.message);
  final String message;
}

/// Résultats de vérification de carte
class CarteVerificationResult {
  final bool isValid;
  final CarteContribuable? carte;
  final VerificationError? error;
  final DateTime timestamp;
  final String? details;

  CarteVerificationResult({
    required this.isValid,
    this.carte,
    this.error,
    required this.timestamp,
    this.details,
  });

  factory CarteVerificationResult.success(CarteContribuable carte, {String? details}) {
    return CarteVerificationResult(
      isValid: true,
      carte: carte,
      timestamp: DateTime.now(),
      details: details,
    );
  }

  factory CarteVerificationResult.failure(VerificationError error, {String? details}) {
    return CarteVerificationResult(
      isValid: false,
      error: error,
      timestamp: DateTime.now(),
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'carte': carte?.toJson(),
      'error': error?.name,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }

  factory CarteVerificationResult.fromJson(Map<String, dynamic> json) {
    return CarteVerificationResult(
      isValid: json['isValid'],
      carte: json['carte'] != null ? CarteContribuable.fromJson(json['carte']) : null,
      error: json['error'] != null ? VerificationError.values.firstWhere(
        (e) => e.name == json['error'],
        orElse: () => VerificationError.unknown,
      ) : null,
      timestamp: DateTime.parse(json['timestamp']),
      details: json['details'],
    );
  }
}

/// Demande de création de carte
class CarteCreationRequest {
  final int contribuableId;
  final CarteType type;
  final QRSecurityLevel securityLevel;
  final String? photoPath;
  final String? signaturePath;
  final Map<String, dynamic>? additionalData;
  final String requestedBy;
  final DateTime requestedAt;

  CarteCreationRequest({
    required this.contribuableId,
    required this.type,
    required this.securityLevel,
    this.photoPath,
    this.signaturePath,
    this.additionalData,
    required this.requestedBy,
    required this.requestedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'contribuableId': contribuableId,
      'type': type.code,
      'securityLevel': securityLevel.code,
      'photoPath': photoPath,
      'signaturePath': signaturePath,
      'additionalData': additionalData,
      'requestedBy': requestedBy,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }

  factory CarteCreationRequest.fromJson(Map<String, dynamic> json) {
    return CarteCreationRequest(
      contribuableId: json['contribuableId'],
      type: CarteType.values.firstWhere(
        (t) => t.code == json['type'],
        orElse: () => CarteType.pvc,
      ),
      securityLevel: QRSecurityLevel.values.firstWhere(
        (s) => s.code == json['securityLevel'],
        orElse: () => QRSecurityLevel.standard,
      ),
      photoPath: json['photoPath'],
      signaturePath: json['signaturePath'],
      additionalData: json['additionalData'],
      requestedBy: json['requestedBy'],
      requestedAt: DateTime.parse(json['requestedAt']),
    );
  }
}

/// Carte contribuable principale
class CarteContribuable {
  final String id;
  final String numero;
  final int contribuableId;
  final String contribuableNom;
  final String contribuablePrenom;
  final CarteType type;
  final CarteStatus status;
  final QRSecurityLevel securityLevel;
  final String qrCode;
  final String qrHash;
  final String? photoPath;
  final String? signaturePath;
  final DateTime dateEmission;
  final DateTime? dateExpiration;
  final DateTime? dateDerniereVerification;
  final int nombreVerifications;
  final String? derniereLocalisation;
  final Map<String, dynamic>? metadata;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  CarteContribuable({
    required this.id,
    required this.numero,
    required this.contribuableId,
    required this.contribuableNom,
    required this.contribuablePrenom,
    required this.type,
    required this.status,
    required this.securityLevel,
    required this.qrCode,
    required this.qrHash,
    this.photoPath,
    this.signaturePath,
    required this.dateEmission,
    this.dateExpiration,
    this.dateDerniereVerification,
    this.nombreVerifications = 0,
    this.derniereLocalisation,
    this.metadata,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  // Getters
  String get contribuableFullName => '$contribuablePrenom $contribuableNom';
  String get displayType => type.label;
  String get displayStatus => status.label;
  String get displaySecurityLevel => securityLevel.label;
  bool get isExpired => dateExpiration != null && DateTime.now().isAfter(dateExpiration!);
  bool get isValid => status == CarteStatus.active && !isExpired;
  int get daysUntilExpiration {
    if (dateExpiration == null) return -1;
    final days = dateExpiration!.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }

  CarteContribuable copyWith({
    String? id,
    String? numero,
    int? contribuableId,
    String? contribuableNom,
    String? contribuablePrenom,
    CarteType? type,
    CarteStatus? status,
    QRSecurityLevel? securityLevel,
    String? qrCode,
    String? qrHash,
    String? photoPath,
    String? signaturePath,
    DateTime? dateEmission,
    DateTime? dateExpiration,
    DateTime? dateDerniereVerification,
    int? nombreVerifications,
    String? derniereLocalisation,
    Map<String, dynamic>? metadata,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return CarteContribuable(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      contribuableId: contribuableId ?? this.contribuableId,
      contribuableNom: contribuableNom ?? this.contribuableNom,
      contribuablePrenom: contribuablePrenom ?? this.contribuablePrenom,
      type: type ?? this.type,
      status: status ?? this.status,
      securityLevel: securityLevel ?? this.securityLevel,
      qrCode: qrCode ?? this.qrCode,
      qrHash: qrHash ?? this.qrHash,
      photoPath: photoPath ?? this.photoPath,
      signaturePath: signaturePath ?? this.signaturePath,
      dateEmission: dateEmission ?? this.dateEmission,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      dateDerniereVerification: dateDerniereVerification ?? this.dateDerniereVerification,
      nombreVerifications: nombreVerifications ?? this.nombreVerifications,
      derniereLocalisation: derniereLocalisation ?? this.derniereLocalisation,
      metadata: metadata ?? this.metadata,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'contribuableId': contribuableId,
      'contribuableNom': contribuableNom,
      'contribuablePrenom': contribuablePrenom,
      'type': type.code,
      'status': status.code,
      'securityLevel': securityLevel.code,
      'qrCode': qrCode,
      'qrHash': qrHash,
      'photoPath': photoPath,
      'signaturePath': signaturePath,
      'dateEmission': dateEmission.toIso8601String(),
      'dateExpiration': dateExpiration?.toIso8601String(),
      'dateDerniereVerification': dateDerniereVerification?.toIso8601String(),
      'nombreVerifications': nombreVerifications,
      'derniereLocalisation': derniereLocalisation,
      'metadata': metadata,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CarteContribuable.fromJson(Map<String, dynamic> json) {
    return CarteContribuable(
      id: json['id'],
      numero: json['numero'],
      contribuableId: json['contribuableId'],
      contribuableNom: json['contribuableNom'],
      contribuablePrenom: json['contribuablePrenom'],
      type: CarteType.values.firstWhere(
        (t) => t.code == json['type'],
        orElse: () => CarteType.pvc,
      ),
      status: CarteStatus.values.firstWhere(
        (s) => s.code == json['status'],
        orElse: () => CarteStatus.draft,
      ),
      securityLevel: QRSecurityLevel.values.firstWhere(
        (s) => s.code == json['securityLevel'],
        orElse: () => QRSecurityLevel.standard,
      ),
      qrCode: json['qrCode'],
      qrHash: json['qrHash'],
      photoPath: json['photoPath'],
      signaturePath: json['signaturePath'],
      dateEmission: DateTime.parse(json['dateEmission']),
      dateExpiration: json['dateExpiration'] != null ? DateTime.parse(json['dateExpiration']) : null,
      dateDerniereVerification: json['dateDerniereVerification'] != null ? DateTime.parse(json['dateDerniereVerification']) : null,
      nombreVerifications: json['nombreVerifications'] ?? 0,
      derniereLocalisation: json['derniereLocalisation'],
      metadata: json['metadata'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedBy: json['updatedBy'],
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Valider la carte
  bool validate() {
    if (qrCode.isEmpty || qrHash.isEmpty) return false;
    if (status != CarteStatus.active) return false;
    if (isExpired) return false;
    return true;
  }

  /// Mettre à jour les informations de vérification
  CarteContribuable updateVerification(String? localisation) {
    return copyWith(
      dateDerniereVerification: DateTime.now(),
      nombreVerifications: nombreVerifications + 1,
      derniereLocalisation: localisation,
    );
  }

  /// Générer un hash de vérification
  String generateVerificationHash() {
    final data = '$id-$numero-$contribuableId-$qrCode-${DateTime.now().millisecondsSinceEpoch}';
    final bytes = utf8.encode(data);
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Vérifier si la carte peut être renouvelée
  bool canBeRenewed() {
    return status == CarteStatus.active || 
           status == CarteStatus.expired ||
           status == CarteStatus.damaged;
  }

  /// Obtenir le statut de renouvellement
  String getRenewalStatus() {
    if (status == CarteStatus.draft) return 'En préparation';
    if (status == CarteStatus.active && !isExpired) return 'Valide';
    if (status == CarteStatus.expired) return 'Expirée - Renouvellement requis';
    if (status == CarteStatus.suspended) return 'Suspendue';
    if (status == CarteStatus.revoked) return 'Révoquée';
    if (status == CarteStatus.lost) return 'Perdue - Remplacement requis';
    if (status == CarteStatus.damaged) return 'Endommagée - Remplacement requis';
    return 'Inconnu';
  }
}

/// Statistiques des cartes
class CarteStatistics {
  final int totalCartes;
  final int cartesActives;
  final int cartesExpirees;
  final int cartesSuspendues;
  final int cartesRevoquees;
  final int cartesPerdues;
  final int cartesEndommagees;
  final int cartesBrouillon;
  final Map<CarteType, int> repartitionParType;
  final Map<QRSecurityLevel, int> repartitionParSecurite;
  final DateTime dernieresMisesAJour;

  CarteStatistics({
    required this.totalCartes,
    required this.cartesActives,
    required this.cartesExpirees,
    required this.cartesSuspendues,
    required this.cartesRevoquees,
    required this.cartesPerdues,
    required this.cartesEndommagees,
    required this.cartesBrouillon,
    required this.repartitionParType,
    required this.repartitionParSecurite,
    required this.dernieresMisesAJour,
  });

  double get tauxActivation => totalCartes > 0 ? cartesActives / totalCartes : 0.0;
  double get tauxExpiration => totalCartes > 0 ? cartesExpirees / totalCartes : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'totalCartes': totalCartes,
      'cartesActives': cartesActives,
      'cartesExpirees': cartesExpirees,
      'cartesSuspendues': cartesSuspendues,
      'cartesRevoquees': cartesRevoquees,
      'cartesPerdues': cartesPerdues,
      'cartesEndommagees': cartesEndommagees,
      'cartesBrouillon': cartesBrouillon,
      'repartitionParType': repartitionParType.map((k, v) => MapEntry(k.code, v)),
      'repartitionParSecurite': repartitionParSecurite.map((k, v) => MapEntry(k.code, v)),
      'dernieresMisesAJour': dernieresMisesAJour.toIso8601String(),
      'tauxActivation': tauxActivation,
      'tauxExpiration': tauxExpiration,
    };
  }

  factory CarteStatistics.fromJson(Map<String, dynamic> json) {
    return CarteStatistics(
      totalCartes: json['totalCartes'],
      cartesActives: json['cartesActives'],
      cartesExpirees: json['cartesExpirees'],
      cartesSuspendues: json['cartesSuspendues'],
      cartesRevoquees: json['cartesRevoquees'],
      cartesPerdues: json['cartesPerdues'],
      cartesEndommagees: json['cartesEndommagees'],
      cartesBrouillon: json['cartesBrouillon'],
      repartitionParType: Map.from(json['repartitionParType'] ?? {})
          .map((k, v) => MapEntry(
            CarteType.values.firstWhere(
              (t) => t.code == k,
              orElse: () => CarteType.pvc,
            ),
            v,
          )),
      repartitionParSecurite: Map.from(json['repartitionParSecurite'] ?? {})
          .map((k, v) => MapEntry(
            QRSecurityLevel.values.firstWhere(
              (s) => s.code == k,
              orElse: () => QRSecurityLevel.standard,
            ),
            v,
          )),
      dernieresMisesAJour: DateTime.parse(json['dernieresMisesAJour']),
    );
  }
}

/// Historique des opérations sur carte
class CarteOperationHistory {
  final String id;
  final String carteId;
  final String operation; // creation, update, verification, suspension, revocation
  final String? ancienStatut;
  final String? nouveauStatut;
  final String? raison;
  final String operateurId;
  final String operateurNom;
  final DateTime timestamp;
  final String? localisation;
  final Map<String, dynamic>? metadata;

  CarteOperationHistory({
    required this.id,
    required this.carteId,
    required this.operation,
    this.ancienStatut,
    this.nouveauStatut,
    this.raison,
    required this.operateurId,
    required this.operateurNom,
    required this.timestamp,
    this.localisation,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carteId': carteId,
      'operation': operation,
      'ancienStatut': ancienStatut,
      'nouveauStatut': nouveauStatut,
      'raison': raison,
      'operateurId': operateurId,
      'operateurNom': operateurNom,
      'timestamp': timestamp.toIso8601String(),
      'localisation': localisation,
      'metadata': metadata,
    };
  }

  factory CarteOperationHistory.fromJson(Map<String, dynamic> json) {
    return CarteOperationHistory(
      id: json['id'],
      carteId: json['carteId'],
      operation: json['operation'],
      ancienStatut: json['ancienStatut'],
      nouveauStatut: json['nouveauStatut'],
      raison: json['raison'],
      operateurId: json['operateurId'],
      operateurNom: json['operateurNom'],
      timestamp: DateTime.parse(json['timestamp']),
      localisation: json['localisation'],
      metadata: json['metadata'],
    );
  }
}