import 'dart:convert';
import 'dart:math';
import 'recensement.dart';

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
  notFound('not_found', 'Non trouvée'),
  invalid('invalid', 'Invalide'),
  invalidFormat('invalid_format', 'Format invalide'),
  invalidSignature('invalid_signature', 'Signature invalide'),
  expired('expired', 'Expirée'),
  suspended('suspended', 'Suspendue'),
  revoked('revoked', 'Révoquée'),
  damaged('damaged', 'Endommagée'),
  qrCodeInvalid('qr_code_invalid', 'Code QR invalide'),
  checksumFailed('checksum_failed', 'Checksum échoué'),
  networkError('network_error', 'Erreur réseau'),
  serverError('server_error', 'Erreur serveur'),
  unknown('unknown', 'Erreur inconnue');

  const VerificationError(this.code, this.label);
  final String code;
  final String label;
  String get message => label;
}

/// Payload du QR Code sécurisé
class QRCodePayload {
  final String cid;
  final String uid;
  final String? sig;
  final DateTime? exp;
  final String? ver;
  final DateTime? issuedDate;

  QRCodePayload({
    required this.cid,
    required this.uid,
    this.sig,
    this.exp,
    this.ver,
    this.issuedDate,
  });

  bool get isExpired => exp != null && DateTime.now().isAfter(exp!);

  String get displayExpiration {
    if (exp == null) return 'N/A';
    return '${exp!.day.toString().padLeft(2, '0')}/'
        '${exp!.month.toString().padLeft(2, '0')}/'
        '${exp!.year}';
  }

  int get daysUntilExpiration {
    if (exp == null) return -1;
    final days = exp!.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }

  String toJsonString() {
    return jsonEncode({
      'cid': cid,
      'uid': uid,
      'sig': sig,
      'exp': exp?.millisecondsSinceEpoch,
      'ver': ver ?? '1.0',
      'issuedDate': issuedDate?.toIso8601String(),
    });
  }

  factory QRCodePayload.fromJson(Map<String, dynamic> json) {
    return QRCodePayload(
      cid: json['cid'] ?? '',
      uid: json['uid'] ?? '',
      sig: json['sig'],
      exp: json['exp'] != null
          ? (json['exp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['exp'])
              : DateTime.parse(json['exp'].toString()))
          : null,
      ver: json['ver'],
      issuedDate: json['issuedDate'] != null
          ? DateTime.parse(json['issuedDate'].toString())
          : null,
    );
  }
}

/// Service de sécurité pour les QR Codes
class QRCodeSecurityService {
  static String generateNumeroCarte() {
    final now = DateTime.now();
    final random = Random.secure();
    final suffix = random.nextInt(999999).toString().padLeft(6, '0');
    return 'CRT-${now.year}-$suffix';
  }

  static String generateMatriculeUnique() {
    final now = DateTime.now();
    final random = Random.secure();
    final suffix = random.nextInt(99999999).toString().padLeft(8, '0');
    return 'MAT-${now.year}-$suffix';
  }

  static QRCodePayload generateQRPayload({
    required String contribuableId,
    required String uniqueId,
    DateTime? expirationDate,
  }) {
    return QRCodePayload(
      cid: contribuableId,
      uid: uniqueId,
      sig: _generateSignature(contribuableId, uniqueId),
      exp: expirationDate ?? DateTime.now().add(const Duration(days: 365)),
      ver: '1.0',
      issuedDate: DateTime.now(),
    );
  }

  static QRCodePayload? parseQRCode(String qrData) {
    try {
      final json = jsonDecode(qrData);
      if (json is Map<String, dynamic>) {
        return QRCodePayload.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static bool verifyQRSignature(QRCodePayload payload) {
    if (payload.sig == null || payload.sig!.isEmpty) return false;
    final expected = _generateSignature(payload.cid, payload.uid);
    return payload.sig == expected;
  }

  static String _generateSignature(String cid, String uid) {
    final data = '$cid-$uid-${DateTime.now().year}';
    final bytes = utf8.encode(data);
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Demande de vérification de carte
class CarteVerificationRequest {
  final String qrCodeData;
  final String? agentId;
  final double? latitude;
  final double? longitude;
  final String? deviceId;
  final Map<String, dynamic>? metadata;

  CarteVerificationRequest({
    required this.qrCodeData,
    this.agentId,
    this.latitude,
    this.longitude,
    this.deviceId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'qrCodeData': qrCodeData,
      'agentId': agentId,
      'latitude': latitude,
      'longitude': longitude,
      'deviceId': deviceId,
      'metadata': metadata,
    };
  }
}

/// Historique de vérification de carte
class CarteVerificationHistory {
  final String id;
  final String carteId;
  final String agentId;
  final bool isValid;
  final String message;
  final VerificationError? error;
  final DateTime verifiedAt;
  final double? latitude;
  final double? longitude;
  final String? deviceId;
  final Map<String, dynamic>? metadata;

  CarteVerificationHistory({
    required this.id,
    required this.carteId,
    required this.agentId,
    required this.isValid,
    required this.message,
    this.error,
    required this.verifiedAt,
    this.latitude,
    this.longitude,
    this.deviceId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carteId': carteId,
      'agentId': agentId,
      'isValid': isValid,
      'message': message,
      'error': error?.name,
      'verifiedAt': verifiedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'deviceId': deviceId,
      'metadata': metadata,
    };
  }
}

/// Résultats de vérification de carte
class CarteVerificationResult {
  final bool isValid;
  final String message;
  final CarteContribuable? carte;
  final ContribuableForm? contribuable;
  final QRCodePayload? payload;
  final VerificationError? error;
  final DateTime verifiedAt;
  final String? verifiedBy;
  final Map<String, dynamic>? verificationMetadata;

  CarteVerificationResult({
    required this.isValid,
    required this.message,
    this.carte,
    this.contribuable,
    this.payload,
    this.error,
    required this.verifiedAt,
    this.verifiedBy,
    this.verificationMetadata,
  });

  factory CarteVerificationResult.success({
    QRCodePayload? payload,
    CarteContribuable? carte,
    ContribuableForm? contribuable,
    String? verifiedBy,
    Map<String, dynamic>? metadata,
  }) {
    return CarteVerificationResult(
      isValid: true,
      message: 'Carte vérifiée avec succès',
      carte: carte,
      contribuable: contribuable,
      payload: payload,
      verifiedAt: DateTime.now(),
      verifiedBy: verifiedBy,
      verificationMetadata: metadata,
    );
  }

  factory CarteVerificationResult.failure({
    required String message,
    VerificationError? error,
    Map<String, dynamic>? metadata,
  }) {
    return CarteVerificationResult(
      isValid: false,
      message: message,
      error: error,
      verifiedAt: DateTime.now(),
      verificationMetadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'message': message,
      'carte': carte?.toJson(),
      'contribuable': contribuable?.toJson(),
      'payload': payload?.toJsonString(),
      'error': error?.name,
      'verifiedAt': verifiedAt.toIso8601String(),
      'verifiedBy': verifiedBy,
      'verificationMetadata': verificationMetadata,
    };
  }

  factory CarteVerificationResult.fromJson(Map<String, dynamic> json) {
    return CarteVerificationResult(
      isValid: json['isValid'] ?? false,
      message: json['message'] ?? '',
      carte: json['carte'] != null ? CarteContribuable.fromJson(json['carte']) : null,
      contribuable: json['contribuable'] != null
          ? ContribuableForm.fromJson(json['contribuable'])
          : null,
      payload: json['payload'] != null
          ? QRCodePayload.fromJson(jsonDecode(json['payload']))
          : null,
      error: json['error'] != null
          ? VerificationError.values.firstWhere(
              (e) => e.name == json['error'],
              orElse: () => VerificationError.unknown,
            )
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : DateTime.now(),
      verifiedBy: json['verifiedBy'],
      verificationMetadata: json['verificationMetadata'],
    );
  }
}

/// Demande de création de carte
class CarteCreationRequest {
  final String contribuableId;
  final CarteType type;
  final QRSecurityLevel securityLevel;
  final DateTime? dateExpiration;
  final String? agentId;
  final String? zoneId;

  CarteCreationRequest({
    required this.contribuableId,
    required this.type,
    required this.securityLevel,
    this.dateExpiration,
    this.agentId,
    this.zoneId,
  });

  Map<String, dynamic> toJson() {
    return {
      'contribuableId': contribuableId,
      'type': type.code,
      'securityLevel': securityLevel.code,
      'dateExpiration': dateExpiration?.toIso8601String(),
      'agentId': agentId,
      'zoneId': zoneId,
    };
  }

  factory CarteCreationRequest.fromJson(Map<String, dynamic> json) {
    return CarteCreationRequest(
      contribuableId: json['contribuableId']?.toString() ?? '',
      type: CarteType.values.firstWhere(
        (t) => t.code == json['type'],
        orElse: () => CarteType.pvc,
      ),
      securityLevel: QRSecurityLevel.values.firstWhere(
        (s) => s.code == json['securityLevel'],
        orElse: () => QRSecurityLevel.standard,
      ),
      dateExpiration: json['dateExpiration'] != null
          ? DateTime.parse(json['dateExpiration'])
          : null,
      agentId: json['agentId'],
      zoneId: json['zoneId'],
    );
  }
}

/// Carte contribuable principale
class CarteContribuable {
  final String id;
  final String contribuableId;
  final String numeroCarte;
  final String matriculeUnique;
  final String qrCodeData;
  final CarteType type;
  final CarteStatus status;
  final QRSecurityLevel securityLevel;
  final DateTime dateEmission;
  final DateTime dateExpiration;
  final String? photoUrl;
  final String? agentId;
  final String? zoneId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CarteContribuable({
    required this.id,
    required this.contribuableId,
    required this.numeroCarte,
    required this.matriculeUnique,
    required this.qrCodeData,
    required this.type,
    required this.status,
    required this.securityLevel,
    required this.dateEmission,
    required this.dateExpiration,
    this.photoUrl,
    this.agentId,
    this.zoneId,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  // Getters
  String get displayType => type.label;
  String get displayStatus => status.label;
  String get displayMatricule => matriculeUnique;
  bool get isExpired => DateTime.now().isAfter(dateExpiration);
  bool get isValid => status == CarteStatus.active && !isExpired;

  bool get isNearExpiration {
    final days = daysUntilExpiration;
    return days >= 0 && days <= 30;
  }

  int get daysUntilExpiration {
    final days = dateExpiration.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }

  CarteContribuable copyWith({
    String? id,
    String? contribuableId,
    String? numeroCarte,
    String? matriculeUnique,
    String? qrCodeData,
    CarteType? type,
    CarteStatus? status,
    QRSecurityLevel? securityLevel,
    DateTime? dateEmission,
    DateTime? dateExpiration,
    String? photoUrl,
    String? agentId,
    String? zoneId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarteContribuable(
      id: id ?? this.id,
      contribuableId: contribuableId ?? this.contribuableId,
      numeroCarte: numeroCarte ?? this.numeroCarte,
      matriculeUnique: matriculeUnique ?? this.matriculeUnique,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      type: type ?? this.type,
      status: status ?? this.status,
      securityLevel: securityLevel ?? this.securityLevel,
      dateEmission: dateEmission ?? this.dateEmission,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      photoUrl: photoUrl ?? this.photoUrl,
      agentId: agentId ?? this.agentId,
      zoneId: zoneId ?? this.zoneId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contribuableId': contribuableId,
      'numeroCarte': numeroCarte,
      'matriculeUnique': matriculeUnique,
      'qrCodeData': qrCodeData,
      'type': type.code,
      'status': status.code,
      'securityLevel': securityLevel.code,
      'dateEmission': dateEmission.toIso8601String(),
      'dateExpiration': dateExpiration.toIso8601String(),
      'photoUrl': photoUrl,
      'agentId': agentId,
      'zoneId': zoneId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CarteContribuable.fromJson(Map<String, dynamic> json) {
    return CarteContribuable(
      id: json['id'] ?? '',
      contribuableId: json['contribuableId']?.toString() ?? '',
      numeroCarte: json['numeroCarte'] ?? '',
      matriculeUnique: json['matriculeUnique'] ?? '',
      qrCodeData: json['qrCodeData'] ?? '',
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
      dateEmission: json['dateEmission'] != null ? DateTime.parse(json['dateEmission']) : DateTime.now(),
      dateExpiration: json['dateExpiration'] != null ? DateTime.parse(json['dateExpiration']) : DateTime.now().add(const Duration(days: 365)),
      photoUrl: json['photoUrl'],
      agentId: json['agentId'],
      zoneId: json['zoneId'],
      metadata: json['metadata'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

/// Statistiques des cartes
class CarteStatistics {
  final int totalCartes;
  final int cartesActives;
  final int cartesExpirees;
  final int cartesSuspendues;
  final int cartesExpirantDans30Jours;
  final int cartesEmisesAujourdhui;
  final int cartesNonSynchronisees;
  final int cartesRevokes;
  final Map<String, int> repartitionParType;
  final Map<String, int> repartitionParStatut;
  final Map<String, int> repartitionParZone;
  final List<CarteContribuable> recentesCartes;

  CarteStatistics({
    required this.totalCartes,
    required this.cartesActives,
    required this.cartesExpirees,
    required this.cartesSuspendues,
    required this.cartesExpirantDans30Jours,
    required this.cartesEmisesAujourdhui,
    required this.cartesNonSynchronisees,
    required this.cartesRevokes,
    required this.repartitionParType,
    required this.repartitionParStatut,
    required this.repartitionParZone,
    required this.recentesCartes,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalCartes': totalCartes,
      'cartesActives': cartesActives,
      'cartesExpirees': cartesExpirees,
      'cartesSuspendues': cartesSuspendues,
      'cartesExpirantDans30Jours': cartesExpirantDans30Jours,
      'cartesEmisesAujourdhui': cartesEmisesAujourdhui,
      'cartesNonSynchronisees': cartesNonSynchronisees,
      'cartesRevokes': cartesRevokes,
      'repartitionParType': repartitionParType,
      'repartitionParStatut': repartitionParStatut,
      'repartitionParZone': repartitionParZone,
      'recentesCartes': recentesCartes.map((c) => c.toJson()).toList(),
    };
  }

  factory CarteStatistics.fromJson(Map<String, dynamic> json) {
    return CarteStatistics(
      totalCartes: json['totalCartes'] ?? 0,
      cartesActives: json['cartesActives'] ?? 0,
      cartesExpirees: json['cartesExpirees'] ?? 0,
      cartesSuspendues: json['cartesSuspendues'] ?? 0,
      cartesExpirantDans30Jours: json['cartesExpirantDans30Jours'] ?? 0,
      cartesEmisesAujourdhui: json['cartesEmisesAujourdhui'] ?? 0,
      cartesNonSynchronisees: json['cartesNonSynchronisees'] ?? 0,
      cartesRevokes: json['cartesRevokes'] ?? 0,
      repartitionParType: Map<String, int>.from(json['repartitionParType'] ?? {}),
      repartitionParStatut: Map<String, int>.from(json['repartitionParStatut'] ?? {}),
      repartitionParZone: Map<String, int>.from(json['repartitionParZone'] ?? {}),
      recentesCartes: (json['recentesCartes'] as List<dynamic>?)
          ?.map((c) => CarteContribuable.fromJson(c))
          .toList() ??
          [],
    );
  }
}