import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../config/theme_config.dart';
import '../services/services.dart';

// Export all widgets for easy import
// export 'recensement_wizard.dart'; // Temporarily disabled due to GeolocationService dependency
// export 'map_widget.dart'; // Temporarily disabled due to GeolocationService dependency
// export 'carte_widgets.dart'; // Temporarily disabled due to compilation errors

class ContribuableCard extends StatelessWidget {
  final ContribuableForm contribuable;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onPayment;
  final bool compact;

  const ContribuableCard({
    super.key,
    required this.contribuable,
    this.onTap,
    this.onCall,
    this.onPayment,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and type
              Row(
                children: [
                  // Avatar or icon
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: _getTypeColor(contribuable.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      _getTypeIcon(contribuable.type),
                      color: _getTypeColor(contribuable.type),
                      size: 20.sp,
                    ),
                  ),
                  
                  SizedBox(width: 12.w),
                  
                  // Name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contribuable.fullName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          contribuable.displayType,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(contribuable.statut).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      contribuable.displayStatus,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: _getStatusColor(contribuable.statut),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (!compact) ...[
                SizedBox(height: 12.h),
                
                // Contact info
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      contribuable.telephone,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                // Activity
                Row(
                  children: [
                    Icon(
                      Icons.work,
                      size: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        contribuable.activite,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8.h),
                
                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        contribuable.zoneId,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Sync status
                if (contribuable.syncStatus != SyncStatus.synchronized) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 16.sp,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        contribuable.displaySyncStatus,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              
              // Action buttons
              if (!compact && (onCall != null || onPayment != null)) ...[
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onCall != null)
                      TextButton.icon(
                        onPressed: onCall,
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Appeler'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    
                    if (onPayment != null) ...[
                      SizedBox(width: 8.w),
                      ElevatedButton.icon(
                        onPressed: onPayment,
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Payer'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(ContribuableType type) {
    switch (type) {
      case ContribuableType.personnePhysique:
        return Colors.blue;
      case ContribuableType.personneMorale:
        return Colors.purple;
      case ContribuableType.commercant:
        return Colors.green;
      case ContribuableType.transporteur:
        return Colors.orange;
      case ContribuableType.artisan:
        return Colors.red;
      case ContribuableType.occupantDomainePublic:
        return Colors.teal;
    }
  }

  IconData _getTypeIcon(ContribuableType type) {
    switch (type) {
      case ContribuableType.personnePhysique:
        return Icons.person;
      case ContribuableType.personneMorale:
        return Icons.business;
      case ContribuableType.commercant:
        return Icons.store;
      case ContribuableType.transporteur:
        return Icons.directions_car;
      case ContribuableType.artisan:
        return Icons.build;
      case ContribuableType.occupantDomainePublic:
        return Icons.location_city;
    }
  }

  Color _getStatusColor(ContribuableStatus status) {
    switch (status) {
      case ContribuableStatus.actif:
        return Colors.green;
      case ContribuableStatus.inactif:
        return Colors.grey;
      case ContribuableStatus.enValidation:
        return Colors.orange;
      case ContribuableStatus.suspendu:
        return Colors.red;
      case ContribuableStatus.archive:
        return Colors.blueGrey;
    }
  }
}

class ContribuableSearchResultCard extends StatelessWidget {
  final ContribuableSearchResult result;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onPayment;

  const ContribuableSearchResultCard({
    super.key,
    required this.result,
    this.onTap,
    this.onCall,
    this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    return ContribuableCard(
      contribuable: result.contribuable,
      onTap: onTap,
      onCall: onCall,
      onPayment: onPayment,
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionDTO transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPrint;
  final bool compact;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onPrint,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with receipt number and amount
              Row(
                children: [
                  // Icon
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppTheme.getStatusColor(transaction.statut.name).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: AppTheme.getStatusColor(transaction.statut.name),
                      size: 20.sp,
                    ),
                  ),
                  
                  SizedBox(width: 12.w),
                  
                  // Receipt number and amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.numeroRecu ?? 'N/A',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${transaction.montant.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.getStatusColor(transaction.statut.name).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      transaction.statut.displayStatus,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.getStatusColor(transaction.statut.name),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (!compact) ...[
                SizedBox(height: 12.h),
                
                // Contribuable info
                if (transaction.contribuableNom != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          transaction.contribuableNom!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                ],
                
                // Payment method and date
                Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(transaction.modePaiement?.label),
                      size: 16.sp,
                      color: AppTheme.getPaymentMethodColor(transaction.modePaiement?.label ?? ''),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _getPaymentMethodLabel(transaction.modePaiement?.label),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Icon(
                      Icons.calendar_today,
                      size: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(transaction.dateCreation ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                // Reference if available
                if (transaction.numeroRecu != null && transaction.numeroRecu!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.receipt,
                        size: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'N°: ${transaction.numeroRecu}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              
              // Action buttons
              if (!compact && (onEdit != null || onDelete != null || onPrint != null)) ...[
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onPrint != null)
                      TextButton.icon(
                        onPressed: onPrint,
                        icon: const Icon(Icons.print, size: 16),
                        label: const Text('Imprimer'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    
                    if (onEdit != null) ...[
                      SizedBox(width: 8.w),
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Modifier'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                    
                    if (onDelete != null) ...[
                      SizedBox(width: 8.w),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Supprimer'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String? method) {
    switch (method) {
      case 'ESPECE':
        return Icons.money;
      case 'MOBILE_MONEY':
        return Icons.phone_android;
      case 'QR_CODE':
        return Icons.qr_code;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodLabel(String? method) {
    switch (method) {
      case 'ESPECE':
        return 'Espèce';
      case 'MOBILE_MONEY':
        return 'Mobile Money';
      case 'QR_CODE':
        return 'QR Code';
      default:
        return method ?? 'Inconnu';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
}

class ProfileBottomSheet extends StatelessWidget {
  const ProfileBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Profile info
          Consumer<AuthService>(
            builder: (context, authService, child) {
              return Column(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      Icons.person,
                      size: 40.sp,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  Text(
                    authService.userDisplayName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  Text(
                    authService.currentUser?.email ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            },
          ),
          
          SizedBox(height: 24.h),
          
          // Menu items
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon Profil'),
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to profile
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to settings
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Aide'),
            onTap: () {
              Navigator.of(context).pop();
              // Navigate to help
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('À propos'),
            onTap: () {
              Navigator.of(context).pop();
              // Show about dialog
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Logout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthService>(context, listen: false).logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionsBottomSheet extends StatelessWidget {
  final VoidCallback onNewContribuable;
  final VoidCallback onNewTransaction;
  final VoidCallback onSearch;

  const QuickActionsBottomSheet({
    super.key,
    required this.onNewContribuable,
    required this.onNewTransaction,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          Text(
            'Actions Rapides',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Action buttons
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 1,
            children: [
              _buildActionItem(
                context,
                'Nouveau Contribuable',
                Icons.person_add,
                Colors.blue,
                onNewContribuable,
              ),
              _buildActionItem(
                context,
                'Nouveau Paiement',
                Icons.payment,
                Colors.green,
                onNewTransaction,
              ),
              _buildActionItem(
                context,
                'Rechercher',
                Icons.search,
                Colors.orange,
                onSearch,
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
