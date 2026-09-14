import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/theme_config.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 18.sp),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 2.h),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SyncStatusBadge extends StatelessWidget {
  final bool isOnline;
  final String? lastSyncTime;

  const SyncStatusBadge({
    super.key,
    required this.isOnline,
    this.lastSyncTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isOnline
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isOnline ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.cloud_done : Icons.cloud_off,
            size: 14.sp,
            color: isOnline ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 4.w),
          Text(
            isOnline ? 'En ligne' : 'Hors ligne',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isOnline ? Colors.green : Colors.orange,
            ),
          ),
          if (lastSyncTime != null) ...[
            SizedBox(width: 6.w),
            Text(
              '• $lastSyncTime',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AgentDrawer extends StatelessWidget {
  final String agentName;
  final String agentEmail;
  final VoidCallback onLogout;

  const AgentDrawer({
    super.key,
    required this.agentName,
    required this.agentEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(agentName, style: TextStyle(fontSize: 16.sp)),
            accountEmail: Text(agentEmail, style: TextStyle(fontSize: 13.sp)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40.sp, color: Theme.of(context).primaryColor),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
              ),
            ),
          ),
          _drawerItem(Icons.dashboard, 'Tableau de bord', () => Navigator.pushReplacementNamed(context, '/agent-dashboard')),
          _drawerItem(Icons.route, 'Ma tournée', () => Navigator.pushReplacementNamed(context, '/agent-tournee')),
          _drawerItem(Icons.people, 'Contribuables', () => Navigator.pushReplacementNamed(context, '/agent-contribuables')),
          _drawerItem(Icons.person_add, 'Nouveau contribuable', () => Navigator.pushReplacementNamed(context, '/agent-nouveau-contribuable')),
          _drawerItem(Icons.map, 'Carte', () => Navigator.pushReplacementNamed(context, '/agent-carte')),
          _drawerItem(Icons.near_me, 'Proche de moi', () => Navigator.pushReplacementNamed(context, '/agent-nearby')),
          _drawerItem(Icons.payments, 'Encaissements', () => Navigator.pushReplacementNamed(context, '/agent-encaissement')),
          _drawerItem(Icons.receipt_long, 'Reçus', () => Navigator.pushReplacementNamed(context, '/agent-recus')),
          _drawerItem(Icons.handshake, 'Promesses', () => Navigator.pushReplacementNamed(context, '/agent-promesse')),
          _drawerItem(Icons.warning, 'Impayés', () => Navigator.pushReplacementNamed(context, '/agent-impayes')),
          _drawerItem(Icons.account_balance, 'Caisse', () => Navigator.pushReplacementNamed(context, '/agent-caisse')),
          _drawerItem(Icons.sync, 'Synchronisation', () => Navigator.pushReplacementNamed(context, '/agent-sync')),
          _drawerItem(Icons.history, 'Journal', () => Navigator.pushReplacementNamed(context, '/agent-journal')),
          _drawerItem(Icons.notifications, 'Notifications', () => Navigator.pushReplacementNamed(context, '/agent-notifications')),
          _drawerItem(Icons.bar_chart, 'Statistiques', () => Navigator.pushReplacementNamed(context, '/agent-stats')),
          _drawerItem(Icons.qr_code_scanner, 'Vérifier reçu', () => Navigator.pushReplacementNamed(context, '/agent-verif-recu')),
          _drawerItem(Icons.message, 'Messagerie', () => Navigator.pushReplacementNamed(context, '/agent-messagerie')),
          _drawerItem(Icons.warning_amber, 'Conflits sync', () => Navigator.pushReplacementNamed(context, '/agent-conflict')),
          _drawerItem(Icons.outbox, 'Remise caisse', () => Navigator.pushReplacementNamed(context, '/agent-remise-caisse')),
          _drawerItem(Icons.person, 'Mon profil', () => Navigator.pushReplacementNamed(context, '/dashboard')),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red, size: 20.sp),
            title: Text('Déconnexion', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return Builder(builder: (context) {
      return ListTile(
        leading: Icon(icon, size: 22.sp),
        title: Text(title, style: TextStyle(fontSize: 14.sp)),
        onTap: onTap,
      );
    });
  }
}
