import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import 'storage_service.dart';
import 'connectivity_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final Logger _logger = Logger();
  final List<NotificationDto> _notifications = [];
  final StreamController<NotificationDto> _controller = StreamController<NotificationDto>.broadcast();

  List<NotificationDto> get notifications => List.unmodifiable(_notifications);
  Stream<NotificationDto> get notificationStream => _controller.stream;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize() async {
    await _loadFromStorage();
    _logger.i('NotificationService initialized with ${_notifications.length} notifications');
  }

  void addNotification(NotificationDto notification) {
    _notifications.insert(0, notification);
    _controller.add(notification);
    _saveToStorage();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _saveToStorage();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _saveToStorage();
  }

  void clearAll() {
    _notifications.clear();
    _saveToStorage();
  }

  List<NotificationDto> getUnread() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  List<NotificationDto> getByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  void checkPromesseEcheances(List<PromessePaiementDto> promesses) {
    for (final p in promesses) {
      if (p.isEcheanceToday && p.statut == 'EN_ATTENTE') {
        final exists = _notifications.any((n) =>
          n.type == NotificationType.promesseEcheance &&
          n.data?['promesseId'] == p.id
        );
        if (!exists) {
          addNotification(NotificationDto(
            id: 'notif_promesse_${p.id}',
            type: NotificationType.promesseEcheance,
            title: 'Promesse à échéance aujourd\'hui',
            body: '${p.contribuableFullName} - ${p.montant.toStringAsFixed(0)} FCFA',
            createdAt: DateTime.now(),
            data: {'promesseId': p.id, 'contribuableId': p.contribuableId},
          ));
        }
      }
    }
  }

  void checkSyncFailure(int pendingCount) {
    if (pendingCount > 0) {
      final exists = _notifications.any((n) =>
        n.type == NotificationType.syncEchouee && !n.isRead
      );
      if (!exists) {
        addNotification(NotificationDto(
          id: 'notif_sync_${DateTime.now().millisecondsSinceEpoch}',
          type: NotificationType.syncEchouee,
          title: 'Synchronisation en attente',
          body: '$pendingCount élément(s) à synchroniser',
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  Future<void> _loadFromStorage() async {
    final storageService = StorageService();
    final data = await storageService.getLocalData('notifications');
    if (data != null) {
      try {
        final list = jsonDecode(data) as List<dynamic>;
        _notifications.addAll(
          list.map((j) => NotificationDto.fromJson(j as Map<String, dynamic>)),
        );
      } catch (e) {
        _logger.e('Erreur chargement notifications: $e');
      }
    }
  }

  Future<void> _saveToStorage() async {
    final storageService = StorageService();
    final data = jsonEncode(_notifications.map((n) => n.toJson()).toList());
    await storageService.storeLocalData('notifications', data);
  }
}
