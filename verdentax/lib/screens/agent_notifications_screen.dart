import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AgentNotificationsScreen extends StatefulWidget {
  const AgentNotificationsScreen({super.key});

  @override
  State<AgentNotificationsScreen> createState() => _AgentNotificationsScreenState();
}

class _AgentNotificationsScreenState extends State<AgentNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final notificationService = NotificationService();
    final notifications = notificationService.notifications;

    return Scaffold(
      drawer: AgentDrawer(
        agentName: user?.fullName ?? 'Agent',
        agentEmail: user?.email ?? '',
        onLogout: () {
          authService.logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => notificationService.clearAll(),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64.sp, color: Colors.grey.shade400),
                  SizedBox(height: 8.h),
                  Text('Aucune notification', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 6.h),
                  child: ListTile(
                    leading: _typeIcon(n.type),
                    title: Text(n.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.body, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                        if (n.createdAt != null)
                          Text(
                            _formatTime(n.createdAt!),
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                    trailing: n.isRead
                        ? null
                        : Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () => _handleTap(context, n),
                  ),
                );
              },
            ),
    );
  }

  Icon _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.nouvelleAffectation:
      case NotificationType.changementSecteur:
        return const Icon(Icons.assignment, color: Colors.blue);
      case NotificationType.nouvelleTournee:
        return const Icon(Icons.map, color: Colors.teal);
      case NotificationType.aRevoir:
        return const Icon(Icons.replay, color: Colors.purple);
      case NotificationType.promesseEcheance:
        return const Icon(Icons.schedule, color: Colors.orange);
      case NotificationType.paiementConfirme:
        return const Icon(Icons.check_circle, color: Colors.green);
      case NotificationType.syncEchouee:
        return const Icon(Icons.sync_problem, color: Colors.red);
      case NotificationType.anomalie:
        return const Icon(Icons.warning, color: Colors.red);
      case NotificationType.messageSuperviseur:
        return const Icon(Icons.message, color: Colors.indigo);
    }
  }

  void _handleTap(BuildContext context, NotificationDto n) {
    switch (n.type) {
      case NotificationType.nouvelleTournee:
        Navigator.pushNamed(context, '/agent-tournee');
        break;
      case NotificationType.promesseEcheance:
        Navigator.pushNamed(context, '/agent-promesse');
        break;
      case NotificationType.syncEchouee:
        Navigator.pushNamed(context, '/agent-sync');
        break;
      case NotificationType.aRevoir:
        Navigator.pushNamed(context, '/agent-impayes');
        break;
      default:
        break;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }
}
