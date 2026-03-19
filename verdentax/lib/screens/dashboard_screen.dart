import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Logger _logger = Logger();
  
  bool _isLoading = true;
  // Statistics
  RecensementStatistics? _recensementStats;
  List<TransactionDTO> _recentTransactions = [];
  List<ContribuableForm> _recentContribuables = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.h,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Tableau de Bord',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: DashboardPatternPainter(),
                        ),
                      ),
                      
                      // User info
                      Positioned(
                        bottom: 20.h,
                        left: 20.w,
                        right: 20.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenue, ${authService.userDisplayName}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 16.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  _getUserRole(authService),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Icon(
                                  connectivityService.isOnline 
                                      ? Icons.wifi 
                                      : Icons.wifi_off,
                                  size: 16.sp,
                                  color: connectivityService.isOnline 
                                      ? Colors.green 
                                      : Colors.orange,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  connectivityService.connectivityStatus,
                                  style: TextStyle(
                                    color: connectivityService.isOnline 
                                        ? Colors.green 
                                        : Colors.orange,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _showProfileMenu,
                  icon: const Icon(Icons.person),
                  tooltip: 'Profil',
                ),
                IconButton(
                  onPressed: _showNotifications,
                  icon: const Icon(Icons.notifications),
                  tooltip: 'Notifications',
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                tabs: const [
                  Tab(icon: Icon(Icons.dashboard), text: 'Aperçu'),
                  Tab(icon: Icon(Icons.people), text: 'Recensement'),
                  Tab(icon: Icon(Icons.receipt_long), text: 'Transactions'),
                ],
              ),
            ),
          ];
        },
        body: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildRecensementTab(),
                  _buildTransactionsTab(),
                ],
              ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick stats
            _buildQuickStats(),
            
            SizedBox(height: 24.h),
            
            // Quick actions
            _buildQuickActions(),
            
            SizedBox(height: 24.h),
            
            // Recent activities
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecensementTab() {
    return RefreshIndicator(
      onRefresh: _loadRecensementData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recensement statistics
            if (_recensementStats != null) ...[
              _buildRecensementStats(),
              SizedBox(height: 24.h),
            ],
            
            // Recent contribuables
            _buildRecentContribuables(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return RefreshIndicator(
      onRefresh: _loadTransactionData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction statistics
            _buildTransactionStats(),
            
            SizedBox(height: 24.h),
            
            // Recent transactions
            _buildRecentTransactions(),
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
                    'Contribuables',
                    '${_recensementStats?.totalContribuables ?? 0}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    'Transactions',
                    '${_recentTransactions.length}',
                    Icons.receipt_long,
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
                    'Hors ligne',
                    '${_recensementStats?.nonSynchronises ?? 0}',
                    Icons.cloud_off,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    'En Validation',
                    '${_recensementStats?.enValidation ?? 0}',
                    Icons.pending,
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

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions Rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.2,
              children: [
                _buildActionCard(
                  'Nouveau Contribuable',
                  Icons.person_add,
                  Colors.blue,
                  () => _navigateToRecensement(),
                ),
                _buildActionCard(
                  'Nouveau Paiement',
                  Icons.payment,
                  Colors.green,
                  () => _navigateToTransaction(),
                ),
                _buildActionCard(
                  'Rechercher',
                  Icons.search,
                  Colors.orange,
                  () => _navigateToSearch(),
                ),
                _buildActionCard(
                  'Synchroniser',
                  Icons.sync,
                  Colors.purple,
                  () => _synchronizeData(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
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

  Widget _buildRecentActivities() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activités Récentes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            if (_recentTransactions.isEmpty && _recentContribuables.isEmpty)
              Container(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Aucune activité récente',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // Recent transactions
                  if (_recentTransactions.isNotEmpty) ...[
                    ..._recentTransactions.take(3).map((transaction) {
                      return _buildActivityItem(
                        icon: Icons.receipt_long,
                        title: 'Paiement reçu',
                        subtitle: '${transaction.montant} FCFA - ${transaction.contribuableNom ?? 'Contribuable'}',
                        time: _formatTime(transaction.dateCreation ?? DateTime.now()),
                        color: Colors.green,
                      );
                    }),
                  ],
                  
                  // Recent contribuables
                  if (_recentContribuables.isNotEmpty) ...[
                    ..._recentContribuables.take(3).map((contribuable) {
                      return _buildActivityItem(
                        icon: Icons.person_add,
                        title: 'Nouveau contribuable',
                        subtitle: '${contribuable.fullName} - ${contribuable.displayType}',
                        time: _formatTime(contribuable.dateCreation),
                        color: Colors.blue,
                      );
                    }),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Text(
        time,
        style: TextStyle(
          fontSize: 11.sp,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildRecensementStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques de Recensement',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Type distribution
            if (_recensementStats!.repartitionParType.isNotEmpty) ...[
              Text(
                'Répartition par Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12.h),
              ..._recensementStats!.repartitionParType.entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(entry.key.label),
                      ),
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            
            SizedBox(height: 16.h),
            
            // Sync status
            Row(
              children: [
                Expanded(
                  child: _buildSyncStatusCard(
                    'Synchronisés',
                    '${(_recensementStats!.totalContribuables - _recensementStats!.nonSynchronises)}',
                    Icons.cloud_done,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSyncStatusCard(
                    'En attente',
                    '${_recensementStats!.nonSynchronises}',
                    Icons.cloud_off,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentContribuables() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contribuables Récents',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            if (_recentContribuables.isEmpty)
              Container(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 48.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Aucun contribuable récent',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _recentContribuables.map((contribuable) {
                  return ContribuableCard(
                    contribuable: contribuable,
                    onTap: () => _viewContribuable(contribuable),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques des Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildTransactionStatCard(
                    'Aujourd\'hui',
                    '${_getTodayTransactionsCount()}',
                    Icons.today,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildTransactionStatCard(
                    'Total',
                    '${_recentTransactions.length}',
                    Icons.receipt_long,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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

  Widget _buildRecentTransactions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions Récentes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            if (_recentTransactions.isEmpty)
              Container(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Aucune transaction récente',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _recentTransactions.map((transaction) {
                  return TransactionCard(
                    transaction: transaction,
                    onTap: () => _viewTransaction(transaction),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showQuickActions,
      icon: const Icon(Icons.add),
      label: const Text('Nouveau'),
    );
  }

  // Helper methods
  String _getUserRole(AuthService authService) {
    if (authService.hasRole(AppConfig.roleAdministrateur)) {
      return 'Administrateur';
    } else if (authService.hasRole(AppConfig.roleSuperviseur)) {
      return 'Superviseur';
    } else if (authService.hasRole(AppConfig.roleAgent)) {
      return 'Agent';
    } else {
      return 'Utilisateur';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }

  int _getTodayTransactionsCount() {
    final today = DateTime.now();
    return _recentTransactions.where((transaction) {
      final creationDate = transaction.dateCreation ?? DateTime.now();
      return creationDate.year == today.year &&
             creationDate.month == today.month &&
             creationDate.day == today.day;
    }).length;
  }

  // Navigation methods
  void _navigateToRecensement() {
    Navigator.of(context).pushNamed('/recensement');
  }

  void _navigateToTransaction() {
    Navigator.of(context).pushNamed('/transaction');
  }

  void _navigateToSearch() {
    Navigator.of(context).pushNamed('/search');
  }

  void _viewContribuable(ContribuableForm contribuable) {
    Navigator.of(context).pushNamed(
      '/contribuable/detail',
      arguments: contribuable,
    );
  }

  void _viewTransaction(TransactionDTO transaction) {
    Navigator.of(context).pushNamed(
      '/transaction/detail',
      arguments: transaction,
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ProfileBottomSheet(),
    );
  }

  void _showNotifications() {
    Navigator.of(context).pushNamed('/notifications');
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickActionsBottomSheet(
        onNewContribuable: _navigateToRecensement,
        onNewTransaction: _navigateToTransaction,
        onSearch: _navigateToSearch,
      ),
    );
  }

  void _synchronizeData() async {
    try {
      final recensementService = RecensementService();
      await recensementService.syncPendingContribuables();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation terminée'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDashboardData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de synchronisation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Data loading methods
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadRecensementData(),
        _loadTransactionData(),
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

  Future<void> _loadRecensementData() async {
    try {
      final recensementService = RecensementService();
      
      // Load statistics
      _recensementStats = await recensementService.getRecensementStatistics();
      
      // Load recent contribuables
      final authService = Provider.of<AuthService>(context, listen: false);
      _recentContribuables = await recensementService.getContribuablesByAgent(
        authService.currentUser?.id ?? 'unknown',
      );
      
      // Sort by creation date (most recent first)
      _recentContribuables.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      
      // Take only the 10 most recent
      _recentContribuables = _recentContribuables.take(10).toList();
    } catch (e) {
      _logger.e('Error loading recensement data: $e');
    }
  }

  Future<void> _loadTransactionData() async {
    try {
      final apiService = ApiService();
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Load recent transactions for current agent
      _recentTransactions = await apiService.getTransactionsByAgent(
        int.tryParse(authService.currentUser?.id ?? '0') ?? 0,
      );
      
      // Sort by creation date (most recent first)
      _recentTransactions.sort((a, b) {
        if (a.dateCreation == null && b.dateCreation == null) return 0;
        if (a.dateCreation == null) return 1;
        if (b.dateCreation == null) return -1;
        return b.dateCreation!.compareTo(a.dateCreation!);
      });
      
      // Take only the 20 most recent
      _recentTransactions = _recentTransactions.take(20).toList();
    } catch (e) {
      _logger.e('Error loading transaction data: $e');
    }
  }
}

// Custom painter for dashboard background pattern
class DashboardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    for (int i = 0; i < 5; i++) {
      final x = (size.width / 5) * i + (size.width / 10);
      final y = size.height * 0.3;
      final radius = 20.0 + (i * 5);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
