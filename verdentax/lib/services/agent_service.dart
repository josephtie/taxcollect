import 'dart:async';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'location_service.dart';

/// Service pour gérer les agents et leurs relations avec les zones
class AgentService {
  static final AgentService _instance = AgentService._internal();
  factory AgentService() => _instance;
  AgentService._internal();

  final Logger _logger = Logger();
  
  // Cache pour les données des agents
  List<AgentsDto> _agentsCache = [];
  final Map<String, List<ZoneCollectDto>> _agentZonesCache = {};
  
  // Initialize the service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing AgentService...');
      
      // Load all agents
      await _loadAgents();
      
      _logger.i('AgentService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing AgentService: $e');
      rethrow;
    }
  }
  
  /// Obtenir tous les agents
  Future<List<AgentsDto>> getAllAgents() async {
    try {
      if (_agentsCache.isNotEmpty) {
        return _agentsCache;
      }
      
      final apiService = ApiService();
      _agentsCache = await apiService.getAllAgents();
      return _agentsCache;
    } catch (e) {
      _logger.e('Error getting agents: $e');
      return [];
    }
  }
  
  /// Obtenir un agent par ID
  Future<AgentsDto?> getAgentById(int id) async {
    try {
      final agents = await getAllAgents();
      return agents.where((a) => a.id == id).firstOrNull;
    } catch (e) {
      _logger.e('Error getting agent $id: $e');
      return null;
    }
  }
  
  /// Créer un nouvel agent
  Future<AgentsDto> createAgent({
    required String nom,
    required String prenom,
    String? email,
    String? telephone,
    List<int>? zoneIds,
  }) async {
    try {
      // Validation des données
      _validateAgentData(nom, prenom, email, telephone);
      
      final apiService = ApiService();
      final agent = await apiService.createAgent(AgentsDto(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        zoneIds: zoneIds,
      ));
      
      // Update cache
      _agentsCache.add(agent);
      
      // Update zones cache if zones are assigned
      if (zoneIds != null && zoneIds.isNotEmpty) {
        await _loadAgentZones(agent.id.toString());
      }
      
      _logger.i('Created agent: ${agent.fullName}');
      return agent;
    } catch (e) {
      _logger.e('Error creating agent: $e');
      rethrow;
    }
  }
  
  /// Mettre à jour un agent
  Future<AgentsDto> updateAgent(AgentsDto agent) async {
    try {
      // Validation des données
      _validateAgentData(agent.nom, agent.prenom, agent.email, agent.telephone);
      
      final apiService = ApiService();
      final updatedAgent = await apiService.updateAgent(agent);
      
      // Update cache
      final index = _agentsCache.indexWhere((a) => a.id == agent.id);
      if (index != -1) {
        _agentsCache[index] = updatedAgent;
      }
      
      // Update zones cache
      await _loadAgentZones(agent.id.toString());
      
      _logger.i('Updated agent: ${updatedAgent.fullName}');
      return updatedAgent;
    } catch (e) {
      _logger.e('Error updating agent: $e');
      rethrow;
    }
  }
  
  /// Supprimer un agent
  Future<void> deleteAgent(int id) async {
    try {
      final apiService = ApiService();
      await apiService.deleteAgent(id);
      
      // Remove from cache
      _agentsCache.removeWhere((a) => a.id == id);
      _agentZonesCache.remove(id.toString());
      
      _logger.i('Deleted agent: $id');
    } catch (e) {
      _logger.e('Error deleting agent $id: $e');
      rethrow;
    }
  }
  
  /// Obtenir les zones assignées à un agent
  Future<List<ZoneCollectDto>> getAgentZones(int agentId) async {
    try {
      final agentIdStr = agentId.toString();
      
      if (_agentZonesCache.containsKey(agentIdStr)) {
        return _agentZonesCache[agentIdStr]!;
      }
      
      await _loadAgentZones(agentIdStr);
      return _agentZonesCache[agentIdStr] ?? [];
    } catch (e) {
      _logger.e('Error getting zones for agent $agentId: $e');
      return [];
    }
  }
  
  /// Assigner des zones à un agent
  Future<void> assignZonesToAgent(int agentId, List<int> zoneIds) async {
    try {
      final agent = await getAgentById(agentId);
      if (agent == null) {
        throw Exception('Agent not found: $agentId');
      }
      
      // Validate zones exist
      final locationService = LocationService();
      for (final zoneId in zoneIds) {
        final zone = await locationService.getZoneById(zoneId);
        if (zone == null) {
          throw Exception('Zone not found: $zoneId');
        }
      }
      
      // Update agent with new zones
      final updatedAgent = agent.copyWith(zoneIds: zoneIds);
      await updateAgent(updatedAgent);
      
      _logger.i('Assigned ${zoneIds.length} zones to agent $agentId');
    } catch (e) {
      _logger.e('Error assigning zones to agent $agentId: $e');
      rethrow;
    }
  }
  
  /// Ajouter une zone à un agent
  Future<void> addZoneToAgent(int agentId, int zoneId) async {
    try {
      final agent = await getAgentById(agentId);
      if (agent == null) {
        throw Exception('Agent not found: $agentId');
      }
      
      final currentZones = agent.zoneIds ?? [];
      if (!currentZones.contains(zoneId)) {
        currentZones.add(zoneId);
        await assignZonesToAgent(agentId, currentZones);
      }
    } catch (e) {
      _logger.e('Error adding zone $zoneId to agent $agentId: $e');
      rethrow;
    }
  }
  
  /// Retirer une zone d'un agent
  Future<void> removeZoneFromAgent(int agentId, int zoneId) async {
    try {
      final agent = await getAgentById(agentId);
      if (agent == null) {
        throw Exception('Agent not found: $agentId');
      }
      
      final currentZones = agent.zoneIds ?? [];
      currentZones.remove(zoneId);
      await assignZonesToAgent(agentId, currentZones);
    } catch (e) {
      _logger.e('Error removing zone $zoneId from agent $agentId: $e');
      rethrow;
    }
  }
  
  /// Obtenir les agents par zone
  Future<List<AgentsDto>> getAgentsByZone(int zoneId) async {
    try {
      final agents = await getAllAgents();
      return agents.where((agent) => 
        agent.zoneIds != null && agent.zoneIds!.contains(zoneId)
      ).toList();
    } catch (e) {
      _logger.e('Error getting agents for zone $zoneId: $e');
      return [];
    }
  }
  
  /// Obtenir les agents sans zone assignée
  Future<List<AgentsDto>> getAgentsWithoutZones() async {
    try {
      final agents = await getAllAgents();
      return agents.where((agent) => 
        agent.zoneIds == null || agent.zoneIds!.isEmpty
      ).toList();
    } catch (e) {
      _logger.e('Error getting agents without zones: $e');
      return [];
    }
  }
  
  /// Obtenir les agents avec leurs zones
  Future<List<AgentWithZones>> getAgentsWithZones() async {
    try {
      final agents = await getAllAgents();
      final agentsWithZones = <AgentWithZones>[];
      
      for (final agent in agents) {
        final zones = await getAgentZones(agent.id ?? 0);
        agentsWithZones.add(AgentWithZones(
          agent: agent,
          zones: zones,
        ));
      }
      
      return agentsWithZones;
    } catch (e) {
      _logger.e('Error getting agents with zones: $e');
      return [];
    }
  }
  
  /// Rechercher des agents
  Future<List<AgentsDto>> searchAgents(String query) async {
    try {
      final agents = await getAllAgents();
      final lowerQuery = query.toLowerCase();
      
      return agents.where((agent) => 
        agent.nom.toLowerCase().contains(lowerQuery) ||
        agent.prenom.toLowerCase().contains(lowerQuery) ||
        (agent.email?.toLowerCase().contains(lowerQuery) ?? false) ||
        (agent.telephone?.toLowerCase().contains(lowerQuery) ?? false)
      ).toList();
    } catch (e) {
      _logger.e('Error searching agents: $e');
      return [];
    }
  }
  
  /// Obtenir les statistiques des agents
  Future<AgentStatistics> getStatistics() async {
    try {
      final agents = await getAllAgents();
      final agentsWithZones = agents.where((a) => 
        a.zoneIds != null && a.zoneIds!.isNotEmpty
      ).length;
      
      final totalZonesAssigned = agents.fold<int>(0, (sum, agent) => 
        sum + (agent.zoneIds?.length ?? 0)
      );
      
      return AgentStatistics(
        totalAgents: agents.length,
        agentsWithZones: agentsWithZones,
        agentsWithoutZones: agents.length - agentsWithZones,
        averageZonesPerAgent: agents.isNotEmpty 
          ? totalZonesAssigned / agents.length 
          : 0,
      );
    } catch (e) {
      _logger.e('Error getting agent statistics: $e');
      return AgentStatistics(
        totalAgents: 0,
        agentsWithZones: 0,
        agentsWithoutZones: 0,
        averageZonesPerAgent: 0,
      );
    }
  }
  
  // Private methods
  
  Future<void> _loadAgents() async {
    try {
      final apiService = ApiService();
      _agentsCache = await apiService.getAllAgents();
      _logger.i('Loaded ${_agentsCache.length} agents');
    } catch (e) {
      _logger.w('Error loading agents: $e');
    }
  }
  
  Future<void> _loadAgentZones(String agentId) async {
    try {
      final agent = _agentsCache.where((a) => a.id.toString() == agentId).firstOrNull;
      if (agent == null || agent.zoneIds == null) {
        _agentZonesCache[agentId] = [];
        return;
      }
      
      final locationService = LocationService();
      final zones = <ZoneCollectDto>[];
      
      for (final zoneId in agent.zoneIds!) {
        final zone = await locationService.getZoneById(zoneId);
        if (zone != null) {
          zones.add(zone);
        }
      }
      
      _agentZonesCache[agentId] = zones;
    } catch (e) {
      _logger.w('Error loading zones for agent $agentId: $e');
      _agentZonesCache[agentId] = [];
    }
  }
  
  void _validateAgentData(String nom, String prenom, String? email, String? telephone) {
    if (nom.trim().isEmpty) {
      throw Exception('Le nom de l\'agent est obligatoire');
    }
    
    if (prenom.trim().isEmpty) {
      throw Exception('Le prénom de l\'agent est obligatoire');
    }
    
    if (email != null && email.isNotEmpty && !_isValidEmail(email)) {
      throw Exception('L\'email de l\'agent est invalide');
    }
    
    if (telephone != null && telephone.isNotEmpty && !_isValidPhone(telephone)) {
      throw Exception('Le téléphone de l\'agent est invalide');
    }
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone);
  }
  
  /// Rafraîchir le cache
  void refreshCache() {
    _agentsCache.clear();
    _agentZonesCache.clear();
  }
}

/// Modèle pour représenter un agent avec ses zones
class AgentWithZones {
  final AgentsDto agent;
  final List<ZoneCollectDto> zones;
  
  AgentWithZones({
    required this.agent,
    required this.zones,
  });
  
  String get zonesDisplay {
    if (zones.isEmpty) return 'Aucune zone';
    return zones.map((z) => z.nom).join(', ');
  }
  
  Map<String, dynamic> toJson() {
    return {
      'agent': agent.toJson(),
      'zones': zones.map((z) => z.toJson()).toList(),
    };
  }
  
  factory AgentWithZones.fromJson(Map<String, dynamic> json) {
    return AgentWithZones(
      agent: AgentsDto.fromJson(json['agent']),
      zones: (json['zones'] as List)
          .map((z) => ZoneCollectDto.fromJson(z))
          .toList(),
    );
  }
}

/// Statistiques des agents
class AgentStatistics {
  final int totalAgents;
  final int agentsWithZones;
  final int agentsWithoutZones;
  final double averageZonesPerAgent;
  
  AgentStatistics({
    required this.totalAgents,
    required this.agentsWithZones,
    required this.agentsWithoutZones,
    required this.averageZonesPerAgent,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'totalAgents': totalAgents,
      'agentsWithZones': agentsWithZones,
      'agentsWithoutZones': agentsWithoutZones,
      'averageZonesPerAgent': averageZonesPerAgent,
    };
  }
}

// Extension on ApiService for agent operations
extension ApiServiceAgentExtension on ApiService {
  Future<AgentsDto> updateAgent(AgentsDto agent) async {
    try {
      final response = await put<AgentsDto>(
        '${AppConfig.agentsEndpoint}/${agent.id}',
        data: agent.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteAgent(int id) async {
    try {
      await delete('${AppConfig.agentsEndpoint}/$id');
    } catch (e) {
      rethrow;
    }
  }
}
