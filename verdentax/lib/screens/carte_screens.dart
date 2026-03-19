import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../models/carte_contribuable.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class CarteVerificationResultScreen extends StatelessWidget {
  final CarteVerificationResult result;
  final VoidCallback? onNewScan;
  final VoidCallback? onViewContribuable;
  final VoidCallback? onCreateTransaction;

  const CarteVerificationResultScreen({
    super.key,
    required this.result,
    this.onNewScan,
    this.onViewContribuable,
    this.onCreateTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat de Vérification'),
        backgroundColor: result.isValid ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: onNewScan,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Nouveau scan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            _buildStatusCard(context),
            
            SizedBox(height: 24.h),
            
            if (result.isValid) ...[
              // Contribuable info
              _buildContribuableInfo(context),
              
              SizedBox(height: 24.h),
              
              // Carte info
              _buildCarteInfo(context),
              
              SizedBox(height: 24.h),
              
              // Quick actions
              _buildQuickActions(context),
            ] else ...[
              // Error info
              _buildErrorInfo(context),
            ],
            
            // Verification details
            SizedBox(height: 24.h),
            _buildVerificationDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: result.isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: result.isValid ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            result.isValid ? Icons.verified : Icons.error,
            size: 48.sp,
            color: result.isValid ? Colors.green : Colors.red,
          ),
          
          SizedBox(height: 16.h),
          
          Text(
            result.isValid ? 'CARTE VALIDÉE' : 'CARTE INVALIDE',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: result.isValid ? Colors.green : Colors.red,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            result.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContribuableInfo(BuildContext context) {
    if (!result.isValid || result.contribuable == null) {
      return const SizedBox.shrink();
    }

    final contribuable = result.contribuable!;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Informations Contribuable',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            _buildInfoRow('Nom complet', contribuable.fullName),
            _buildInfoRow('Numéro contribuable', contribuable.numeroContribuable),
            _buildInfoRow('Téléphone', contribuable.telephone),
            _buildInfoRow('Type', contribuable.displayType),
            _buildInfoRow('Activité', contribuable.activite),
            _buildInfoRow('Zone', contribuable.zoneId),
            
            if (contribuable.dateCreation != null)
              _buildInfoRow(
                'Date de création',
                _formatDate(contribuable.dateCreation!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarteInfo(BuildContext context) {
    if (!result.isValid || result.carte == null) {
      return const SizedBox.shrink();
    }

    final carte = result.carte!;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Informations Carte',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            _buildInfoRow('Numéro de carte', carte.numeroCarte),
            _buildInfoRow('Matricule unique', carte.matriculeUnique),
            _buildInfoRow('Type de carte', carte.type.label),
            _buildInfoRow('Niveau de sécurité', carte.securityLevel.label),
            _buildInfoRow('Statut', carte.displayStatus),
            _buildInfoRow('Date d\'émission', _formatDate(carte.dateEmission)),
            _buildInfoRow('Date d\'expiration', _formatDate(carte.dateExpiration)),
            
            if (carte.zoneId != null)
              _buildInfoRow('Zone assignée', carte.zoneId!),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions Rapides',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewContribuable,
                    icon: const Icon(Icons.person),
                    label: const Text('Voir Contribuable'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCreateTransaction,
                    icon: const Icon(Icons.payment),
                    label: const Text('Nouveau Paiement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Détails de l\'Erreur',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            if (result.error != null) ...[
              _buildInfoRow('Type d\'erreur', result.error!.label),
              _buildInfoRow('Code erreur', result.error!.code),
            ],
            
            _buildInfoRow('Message', result.message),
            
            if (result.verificationMetadata != null) ...[
              SizedBox(height: 12.h),
              Text(
                'Métadonnées:',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _formatJson(result.verificationMetadata!),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Détails de Vérification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            _buildInfoRow('Date de vérification', _formatDateTime(result.verifiedAt)),
            
            if (result.verifiedBy != null)
              _buildInfoRow('Vérifié par', result.verifiedBy!),
            
            if (result.payload != null) ...[
              _buildInfoRow('ID Contribuable (QR)', result.payload!.cid),
              _buildInfoRow('ID Unique (QR)', result.payload!.uid),
              _buildInfoRow('Version QR', result.payload!.ver ?? '1.0'),
              
              if (result.payload!.issuedDate != null)
                _buildInfoRow('Émise le', _formatDate(result.payload!.issuedDate!)),
              
              _buildInfoRow('Expire le', result.payload!.displayExpiration),
              
              if (result.payload!.isExpired)
                _buildInfoRow(
                  'Statut expiration',
                  'EXPIRÉE',
                  valueColor: Colors.red,
                )
              else
                _buildInfoRow(
                  'Jours restants',
                  '${result.payload!.daysUntilExpiration} jours',
                  valueColor: result.payload!.daysUntilExpiration <= 30 
                      ? Colors.orange 
                      : Colors.green,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatJson(Map<String, dynamic> json) {
    try {
      final encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}

class CarteManagementScreen extends StatefulWidget {
  const CarteManagementScreen({super.key});

  @override
  State<CarteManagementScreen> createState() => _CarteManagementScreenState();
}

class _CarteManagementScreenState extends State<CarteManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CarteContribuableService _carteService = CarteContribuableService();
  
  bool _isLoading = true;
  CarteStatistics? _statistics;
  List<CarteContribuable> _recentCartes = [];
  List<CarteContribuable> _expiringSoon = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Cartes'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Aperçu'),
            Tab(icon: Icon(Icons.credit_card), text: 'Cartes'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Statistiques'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showQRScanner,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scanner une carte',
          ),
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCartesTab(),
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick stats
            if (_statistics != null) _buildQuickStats(),
            
            SizedBox(height: 24.h),
            
            // Recent cartes
            _buildRecentCartes(),
            
            SizedBox(height: 24.h),
            
            // Expiring soon
            _buildExpiringSoon(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu Rapide',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Cartes',
                    '${_statistics!.totalCartes}',
                    Icons.credit_card,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    'Cartes Actives',
                    '${_statistics!.cartesActives}',
                    Icons.verified,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Expirant Bientôt',
                    '${_statistics!.cartesExpirantDans30Jours}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    'Émises Aujourd\'hui',
                    '${_statistics!.cartesEmisesAujourdhui}',
                    Icons.today,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCartes() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cartes Récentes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            if (_recentCartes.isEmpty)
              Container(
                padding: EdgeInsets.all(32.h),
                child: Center(
                  child: Text(
                    'Aucune carte récente',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: _recentCartes.take(5).map((carte) {
                  return CarteListItem(
                    carte: carte,
                    onTap: () => _showCarteDetails(carte),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiringSoon() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cartes Expirant Bientôt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${_expiringSoon.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            if (_expiringSoon.isEmpty)
              Container(
                padding: EdgeInsets.all(32.h),
                child: Center(
                  child: Text(
                    'Aucune carte n\'expire bientôt',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: _expiringSoon.map((carte) {
                  return CarteListItem(
                    carte: carte,
                    showExpiration: true,
                    onTap: () => _showCarteDetails(carte),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartesTab() {
    // Implementation for cartes list tab
    return const Center(
      child: Text('Liste des cartes - À implémenter'),
    );
  }

  Widget _buildStatisticsTab() {
    // Implementation for statistics tab
    return const Center(
      child: Text('Statistiques détaillées - À implémenter'),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showCreateCarteDialog,
      icon: const Icon(Icons.add),
      label: const Text('Nouvelle Carte'),
    );
  }

  // Action methods
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadStatistics(),
        _loadRecentCartes(),
        _loadExpiringSoon(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStatistics() async {
    _statistics = await _carteService.getStatistics();
  }

  Future<void> _loadRecentCartes() async {
    _recentCartes = await _carteService.searchCartes(limit: 10);
  }

  Future<void> _loadExpiringSoon() async {
    _expiringSoon = await _carteService.getCartesExpiringSoon();
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _showQRScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          onQRCodeScanned: (qrData) async {
            Navigator.of(context).pop();
            await _verifyQRCode(qrData);
          },
        ),
      ),
    );
  }

  Future<void> _verifyQRCode(String qrData) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await _carteService.verifyQRCode(
        qrCodeData: qrData,
        agentId: authService.currentUser?.id,
      );
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CarteVerificationResultScreen(
            result: result,
            onNewScan: _showQRScanner,
            onViewContribuable: () {
              // Navigate to contribuable details
            },
            onCreateTransaction: () {
              // Navigate to transaction creation
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de vérification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreateCarteDialog() {
    // Show dialog to select contribuable and create carte
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Création de carte - À implémenter')),
    );
  }

  void _showCarteDetails(CarteContribuable carte) {
    // Show carte details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Détails carte: ${carte.numeroCarte}')),
    );
  }
}

class CarteListItem extends StatelessWidget {
  final CarteContribuable carte;
  final bool showExpiration;
  final VoidCallback? onTap;

  const CarteListItem({
    super.key,
    required this.carte,
    this.showExpiration = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(carte.status).withOpacity(0.1),
        child: Icon(
          Icons.credit_card,
          color: _getStatusColor(carte.status),
          size: 20.sp,
        ),
      ),
      title: Text(
        carte.numeroCarte,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            carte.matriculeUnique,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          if (showExpiration)
            Text(
              'Expire: ${_formatDate(carte.dateExpiration)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: carte.isNearExpiration ? Colors.orange : Colors.grey.shade600,
                fontWeight: carte.isNearExpiration ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
        ],
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: _getStatusColor(carte.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          carte.displayStatus,
          style: TextStyle(
            fontSize: 10.sp,
            color: _getStatusColor(carte.status),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Color _getStatusColor(CarteStatus status) {
    switch (status) {
      case CarteStatus.active:
        return Colors.green;
      case CarteStatus.expired:
        return Colors.red;
      case CarteStatus.suspended:
        return Colors.orange;
      case CarteStatus.revoked:
        return Colors.purple;
      case CarteStatus.lost:
        return Colors.grey;
      case CarteStatus.damaged:
        return Colors.brown;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}

class QRScannerScreen extends StatelessWidget {
  final Function(String) onQRCodeScanned;

  const QRScannerScreen({
    super.key,
    required this.onQRCodeScanned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRScannerWidget(
        onQRCodeScanned: onQRCodeScanned,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}
