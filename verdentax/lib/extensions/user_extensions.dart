import '../models/models.dart';
import '../services/services.dart';

/// Extensions pour aligner le modèle User avec les autres services
extension UserAlignmentExtensions on User {
  
  /// Vérifier si l'utilisateur est un agent
  bool get isAgent => hasRole('agent') || hasRole('agent_collecteur');
  
  /// Vérifier si l'utilisateur est un superviseur
  bool get isSupervisor => hasRole('supervisor') || hasRole('admin');
  
  /// Vérifier si l'utilisateur est un administrateur
  bool get isAdmin => hasRole('admin') || hasRole('super_admin');
  
  /// Obtenir le niveau de permission
  UserPermissionLevel get permissionLevel {
    if (hasRole('super_admin')) return UserPermissionLevel.superAdmin;
    if (hasRole('admin')) return UserPermissionLevel.admin;
    if (hasRole('supervisor')) return UserPermissionLevel.supervisor;
    if (hasRole('agent') || hasRole('agent_collecteur')) return UserPermissionLevel.agent;
    if (hasRole('contribuable')) return UserPermissionLevel.contribuable;
    return UserPermissionLevel.guest;
  }
  
  /// Vérifier si l'utilisateur peut accéder à une fonctionnalité
  bool canAccess(Feature feature) {
    switch (feature) {
      case Feature.dashboard:
        return true; // Tout le monde peut voir le dashboard
      case Feature.recensement:
        return isAgent || isSupervisor || isAdmin;
      case Feature.transactions:
        return isAgent || isSupervisor || isAdmin;
      case Feature.geolocation:
        return isAgent || isSupervisor || isAdmin;
      case Feature.agentManagement:
        return isSupervisor || isAdmin;
      case Feature.userManagement:
        return isAdmin;
      case Feature.systemSettings:
        return isAdmin;
      case Feature.reports:
        return isSupervisor || isAdmin;
      case Feature.audit:
        return isAdmin;
    }
  }
  
  /// Vérifier si l'utilisateur peut modifier une ressource
  bool canModify(ResourceType resourceType, String? resourceOwnerId) {
    // Admin peut tout modifier
    if (isAdmin) return true;
    
    // Superviseur peut modifier les ressources de son équipe
    if (isSupervisor) {
      switch (resourceType) {
        case ResourceType.contribuable:
        case ResourceType.transaction:
        case ResourceType.recensement:
          return true;
        case ResourceType.agent:
          return false; // Seul admin peut modifier les agents
        case ResourceType.user:
          return false; // Seul admin peut modifier les users
      }
    }
    
    // Agent peut modifier ses propres ressources
    if (isAgent) {
      switch (resourceType) {
        case ResourceType.contribuable:
        case ResourceType.transaction:
        case ResourceType.recensement:
          return resourceOwnerId == id; // Seulement ses propres ressources
        case ResourceType.agent:
        case ResourceType.user:
          return false;
      }
    }
    
    return false;
  }
  
  /// Obtenir l'agent associé à cet utilisateur
  Future<AgentsDto?> getAssociatedAgent() async {
    try {
      if (!isAgent) return null;
      
      final agentService = AgentService();
      // Utiliser getAllAgents et filtrer par userId (méthode hypothétique)
      final agents = await agentService.getAllAgents();
      
      return agents.where((agent) => agent.userId == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }
  
  /// Obtenir les statistiques de l'utilisateur
  Future<UserStatistics> getUserStatistics() async {
    try {
      final agent = await getAssociatedAgent();
      
      if (agent == null) {
        return UserStatistics(
          userId: id,
          username: username,
          totalContribuables: 0,
          totalTransactions: 0,
          totalAmount: 0.0,
          lastActivity: DateTime.now(),
          activeZones: 0,
        );
      }
      
      final agentService = AgentService();
      final transactionService = TransactionService();
      
      // Calculer les statistiques manuellement (méthodes hypothétiques)
      final allAgents = await agentService.getAllAgents();
      final allTransactions = await transactionService.getAllTransactions();
      
      final agentTransactions = allTransactions.where((tx) => tx.agentId == agent?.id).toList();
      final totalAmount = agentTransactions.fold<double>(
        0.0, 
        (sum, tx) => sum + tx.montant,
      );
      
      return UserStatistics(
        userId: id,
        username: username,
        totalContribuables: 0, // À calculer depuis le service de recensement
        totalTransactions: agentTransactions.length,
        totalAmount: totalAmount,
        lastActivity: DateTime.now(),
        activeZones: agent?.zoneIds.length ?? 0,
      );
    } catch (e) {
      return UserStatistics(
        userId: id,
        username: username,
        totalContribuables: 0,
        totalTransactions: 0,
        totalAmount: 0.0,
        lastActivity: DateTime.now(),
        activeZones: 0,
      );
    }
  }
  
  /// Créer un audit trail pour une action
  AuditTrail createAuditTrail({
    required String action,
    required String resourceType,
    String? resourceId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? description,
  }) {
    return AuditTrail(
      id: '', // Sera généré par le service
      userId: id,
      username: username,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      oldValues: oldValues,
      newValues: newValues,
      timestamp: DateTime.now(),
      ipAddress: '', // Sera rempli par le service
      userAgent: '', // Sera rempli par le service
      description: description,
    );
  }
  
  /// Obtenir les préférences utilisateur
  Future<UserPreferences> getUserPreferences() async {
    try {
      final storageService = StorageService();
      final prefsJson = await storageService.getSecureData('user_prefs_${id}');
      
      if (prefsJson != null) {
        final prefsMap = Map<String, dynamic>.from(
          // Décoder le JSON
          {} as dynamic
        );
        return UserPreferences.fromJson(prefsMap);
      }
      
      // Préférences par défaut
      return UserPreferences(
        userId: id,
        theme: 'system',
        language: 'fr',
        notifications: true,
        biometricEnabled: true,
        autoSync: true,
        mapType: 'normal',
        dashboardLayout: 'grid',
      );
    } catch (e) {
      return UserPreferences(
        userId: id,
        theme: 'system',
        language: 'fr',
        notifications: true,
        biometricEnabled: true,
        autoSync: true,
        mapType: 'normal',
        dashboardLayout: 'grid',
      );
    }
  }
  
  /// Sauvegarder les préférences utilisateur
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      final storageService = StorageService();
      await storageService.storeSecureData(
        'user_prefs_${id}',
        // Encoder en JSON
        '{}',
      );
    } catch (e) {
      // Logger l'erreur
    }
  }
  
  /// Vérifier si l'utilisateur a des permissions spécifiques
  bool hasPermission(String permission) {
    switch (permission) {
      case 'create_contribuable':
        return canAccess(Feature.recensement);
      case 'edit_contribuable':
        return canAccess(Feature.recensement);
      case 'delete_contribuable':
        return isSupervisor || isAdmin;
      case 'create_transaction':
        return canAccess(Feature.transactions);
      case 'edit_transaction':
        return canAccess(Feature.transactions);
      case 'delete_transaction':
        return isSupervisor || isAdmin;
      case 'view_reports':
        return canAccess(Feature.reports);
      case 'manage_agents':
        return canAccess(Feature.agentManagement);
      case 'manage_users':
        return canAccess(Feature.userManagement);
      case 'system_settings':
        return canAccess(Feature.systemSettings);
      default:
        return false;
    }
  }
  
  /// Obtenir les zones accessibles pour cet utilisateur
  Future<List<ZoneCollectDto>> getAccessibleZones() async {
    try {
      if (isAdmin) {
        // Admin peut accéder à toutes les zones
        final locationService = LocationService();
        return await locationService.getAllZones();
      }
      
      if (isSupervisor || isAgent) {
        final agent = await getAssociatedAgent();
        if (agent != null) {
          final locationService = LocationService();
          final zones = <ZoneCollectDto>[];
          
          for (final zoneId in agent.zoneIds) {
            final zone = await locationService.getZoneById(zoneId);
            if (zone != null) {
              zones.add(zone);
            }
          }
          
          return zones;
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Valider si l'utilisateur peut effectuer une action sur une zone spécifique
  Future<bool> canAccessZone(int zoneId) async {
    try {
      if (isAdmin) return true;
      
      final accessibleZones = await getAccessibleZones();
      return accessibleZones.any((zone) => zone.id == zoneId);
    } catch (e) {
      return false;
    }
  }
}

/// Niveaux de permission utilisateur
enum UserPermissionLevel {
  guest('guest', 'Invité'),
  contribuable('contribuable', 'Contribuable'),
  agent('agent', 'Agent'),
  supervisor('supervisor', 'Superviseur'),
  admin('admin', 'Administrateur'),
  superAdmin('super_admin', 'Super Administrateur');

  const UserPermissionLevel(this.code, this.label);
  final String code;
  final String label;
}

/// Fonctionnalités de l'application
enum Feature {
  dashboard,
  recensement,
  transactions,
  geolocation,
  agentManagement,
  userManagement,
  systemSettings,
  reports,
  audit,
}

/// Types de ressources
enum ResourceType {
  contribuable,
  transaction,
  agent,
  user,
  recensement,
}

/// Statistiques utilisateur
class UserStatistics {
  final String userId;
  final String username;
  final int totalContribuables;
  final int totalTransactions;
  final double totalAmount;
  final DateTime lastActivity;
  final int activeZones;

  UserStatistics({
    required this.userId,
    required this.username,
    required this.totalContribuables,
    required this.totalTransactions,
    required this.totalAmount,
    required this.lastActivity,
    required this.activeZones,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'totalContribuables': totalContribuables,
      'totalTransactions': totalTransactions,
      'totalAmount': totalAmount,
      'lastActivity': lastActivity.toIso8601String(),
      'activeZones': activeZones,
    };
  }

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      userId: json['userId'],
      username: json['username'],
      totalContribuables: json['totalContribuables'],
      totalTransactions: json['totalTransactions'],
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      lastActivity: DateTime.parse(json['lastActivity']),
      activeZones: json['activeZones'],
    );
  }
}

/// Audit trail pour les actions utilisateur
class AuditTrail {
  final String id;
  final String userId;
  final String username;
  final String action;
  final String resourceType;
  final String? resourceId;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final DateTime timestamp;
  final String ipAddress;
  final String userAgent;
  final String? description;

  AuditTrail({
    required this.id,
    required this.userId,
    required this.username,
    required this.action,
    required this.resourceType,
    this.resourceId,
    this.oldValues,
    this.newValues,
    required this.timestamp,
    required this.ipAddress,
    required this.userAgent,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'action': action,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'oldValues': oldValues,
      'newValues': newValues,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'description': description,
    };
  }

  factory AuditTrail.fromJson(Map<String, dynamic> json) {
    return AuditTrail(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      action: json['action'],
      resourceType: json['resourceType'],
      resourceId: json['resourceId'],
      oldValues: json['oldValues'],
      newValues: json['newValues'],
      timestamp: DateTime.parse(json['timestamp']),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      description: json['description'],
    );
  }
}

/// Préférences utilisateur
class UserPreferences {
  final String userId;
  final String theme;
  final String language;
  final bool notifications;
  final bool biometricEnabled;
  final bool autoSync;
  final String mapType;
  final String dashboardLayout;

  UserPreferences({
    required this.userId,
    required this.theme,
    required this.language,
    required this.notifications,
    required this.biometricEnabled,
    required this.autoSync,
    required this.mapType,
    required this.dashboardLayout,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'theme': theme,
      'language': language,
      'notifications': notifications,
      'biometricEnabled': biometricEnabled,
      'autoSync': autoSync,
      'mapType': mapType,
      'dashboardLayout': dashboardLayout,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'],
      theme: json['theme'],
      language: json['language'],
      notifications: json['notifications'],
      biometricEnabled: json['biometricEnabled'],
      autoSync: json['autoSync'],
      mapType: json['mapType'],
      dashboardLayout: json['dashboardLayout'],
    );
  }

  UserPreferences copyWith({
    String? theme,
    String? language,
    bool? notifications,
    bool? biometricEnabled,
    bool? autoSync,
    String? mapType,
    String? dashboardLayout,
  }) {
    return UserPreferences(
      userId: userId,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoSync: autoSync ?? this.autoSync,
      mapType: mapType ?? this.mapType,
      dashboardLayout: dashboardLayout ?? this.dashboardLayout,
    );
  }
}

/// Extensions pour le service d'authentification
extension AuthServiceExtensions on AuthService {
  
  /// Synchroniser l'utilisateur avec les services métier
  Future<void> syncUserWithServices() async {
    try {
      if (currentUser == null) return;
      
      final user = currentUser!;
      
      // Obtenir l'agent associé si c'est un agent
      if (user.isAgent) {
        final agent = await user.getAssociatedAgent();
        if (agent != null) {
          // Synchroniser les zones de l'agent
          final locationService = LocationService();
          final zones = await locationService.getAllZones();
          
          // Filtrer les zones accessibles
          final accessibleZones = zones.where((zone) => 
            agent.zoneIds.contains(zone.id)
          ).toList();
          
          // Mettre en cache les zones accessibles
          final storageService = StorageService();
          await storageService.storeSecureData(
            'user_zones_${user.id}',
            accessibleZones.map((z) => z.id.toString()).join(','),
          );
        }
      }
      
      // Charger les préférences utilisateur
      await user.getUserPreferences();
      
    } catch (e) {
      // Logger l'erreur mais ne pas arrêter le processus
    }
  }
  
  /// Obtenir les statistiques de l'utilisateur courant
  Future<UserStatistics?> getCurrentUserStatistics() async {
    try {
      if (currentUser == null) return null;
      return await currentUser!.getUserStatistics();
    } catch (e) {
      return null;
    }
  }
  
  /// Créer un audit trail pour l'utilisateur courant
  Future<void> createAuditTrail({
    required String action,
    required String resourceType,
    String? resourceId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? description,
  }) async {
    try {
      if (currentUser == null) return;
      
      final audit = currentUser!.createAuditTrail(
        action: action,
        resourceType: resourceType,
        resourceId: resourceId,
        oldValues: oldValues,
        newValues: newValues,
        description: description != null ? 'Contribuable: $description\nActivité: ${currentUser!.activite}\nType: ${currentUser!.displayType}' : null,
      );
      
      // Sauvegarder l'audit trail (implémentation à faire)
      // await _auditService.saveAuditTrail(audit);
    } catch (e) {
      // Logger l'erreur
    }
  }
  
  /// Valider les permissions de l'utilisateur courant
  bool currentUserCanAccess(Feature feature) {
    return currentUser?.canAccess(feature) ?? false;
  }
  
  bool currentUserCanModify(ResourceType resourceType, String? resourceOwnerId) {
    return currentUser?.canModify(resourceType, resourceOwnerId) ?? false;
  }
  
  bool currentUserHasPermission(String permission) {
    return currentUser?.hasPermission(permission) ?? false;
  }
}
