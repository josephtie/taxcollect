import 'dart:convert';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'connectivity_service.dart';

class MessagerieService {
  static final MessagerieService _instance = MessagerieService._internal();
  factory MessagerieService() => _instance;
  MessagerieService._internal();

  final Logger _logger = Logger();
  final List<MessageDto> _messages = [];

  List<MessageDto> get messages => List.unmodifiable(_messages);
  int get unreadCount => _messages.where((m) => !m.isRead && !m.isFromAgent).length;

  Future<MessageDto> sendSignalement({
    required int agentId,
    String? agentNom,
    required SignalementType signalementType,
    String? contenu,
    int? contribuableId,
    String? contribuableNom,
  }) async {
    final message = MessageDto(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      agentId: agentId,
      agentNom: agentNom,
      type: MessageType.signalement,
      sujet: signalementType.label,
      contenu: contenu ?? '',
      signalementType: signalementType,
      contribuableId: contribuableId,
      contribuableNom: contribuableNom,
      isFromAgent: true,
      createdAt: DateTime.now(),
    );

    _messages.add(message);
    await _saveOffline(message);

    final connectivityService = ConnectivityService();
    if (connectivityService.canPerformOnlineOperation()) {
      try {
        final apiService = ApiService();
        await apiService.post(
          AppConfig.signalementEndpoint,
          data: message.toJson(),
        );
      } catch (e) {
        _logger.e('Erreur envoi signalement: $e');
      }
    }

    _logger.i('Signalement envoyé: ${signalementType.label}');
    return message;
  }

  Future<MessageDto> sendMessage({
    required int agentId,
    String? agentNom,
    required String contenu,
    String? sujet,
  }) async {
    final message = MessageDto(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      agentId: agentId,
      agentNom: agentNom,
      type: MessageType.message,
      sujet: sujet,
      contenu: contenu,
      isFromAgent: true,
      createdAt: DateTime.now(),
    );

    _messages.add(message);
    await _saveOffline(message);

    final connectivityService = ConnectivityService();
    if (connectivityService.canPerformOnlineOperation()) {
      try {
        final apiService = ApiService();
        await apiService.post(
          AppConfig.messagerieEndpoint,
          data: message.toJson(),
        );
      } catch (e) {
        _logger.e('Erreur envoi message: $e');
      }
    }

    return message;
  }

  Future<List<MessageDto>> getMessages(int agentId) async {
    final connectivityService = ConnectivityService();
    if (connectivityService.canPerformOnlineOperation()) {
      try {
        final apiService = ApiService();
        final response = await apiService.get<List<dynamic>>(
          '${AppConfig.messagerieEndpoint}/conversation/$agentId',
        );
        _messages.clear();
        _messages.addAll(response.map((j) => MessageDto.fromJson(j)));
        return _messages;
      } catch (e) {
        _logger.e('Erreur chargement messages: $e');
      }
    }
    return _messages.where((m) => m.agentId == agentId).toList();
  }

  void markAsRead(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isRead: true);
    }
  }

  Future<void> _saveOffline(MessageDto message) async {
    final storageService = StorageService();
    await storageService.storeOfflineData('msg_${message.id}', message.toJson());
  }
}
