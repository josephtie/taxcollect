import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class RecensementScreen extends StatefulWidget {
  const RecensementScreen({super.key});

  @override
  State<RecensementScreen> createState() => _RecensementScreenState();
}

class _RecensementScreenState extends State<RecensementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Logger _logger = Logger();
  
  bool _isLoading = false;
  List<ContribuableSearchResult> _searchResults = [];
  List<ContribuableForm> _recentContribuables = [];
  RecensementStatistics? _statistics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recensement'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Rechercher'),
            Tab(icon: Icon(Icons.person_add), text: 'Nouveau'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Statistiques'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _scanQRCode,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scanner QR Code',
          ),
          IconButton(
            onPressed: _synchronizeData,
            icon: const Icon(Icons.sync),
            tooltip: 'Synchroniser',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildNewContribuableTab(),
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: EdgeInsets.all(16.h),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom, téléphone, numéro...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _clearSearch();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        
        // Quick filters
        _buildQuickFilters(),
        
        // Search results
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? _buildEmptySearchResult()
                  : _searchResults.isEmpty
                      ? _buildSearchPrompt()
                      : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Tous', () => _filterByType(null)),
          _buildFilterChip('Personne Physique', () => _filterByType(ContribuableType.personnePhysique)),
          _buildFilterChip('Commerçant', () => _filterByType(ContribuableType.commercant)),
          _buildFilterChip('Transporteur', () => _filterByType(ContribuableType.transporteur)),
          _buildFilterChip('Artisan', () => _filterByType(ContribuableType.artisan)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildSearchPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Rechercher un contribuable',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Entrez un nom, numéro de téléphone ou numéro de contribuable',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Essayez avec d’autres termes de recherche',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return RefreshIndicator(
      onRefresh: _performSearch,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return ContribuableSearchResultCard(
            result: result,
            onTap: () => _viewContribuable(result.contribuable),
            onCall: () => _callContribuable(result.contribuable.telephone),
            onPayment: () => _createPayment(result.contribuable),
          );
        },
      ),
    );
  }

  Widget _buildNewContribuableTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          _buildQuickActions(),
          
          SizedBox(height: 24.h),
          
          // Recent contribuables
          _buildRecentContribuables(),
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
                  () => _showRecensementWizard(),
                ),
                _buildActionCard(
                  'Scanner QR Code',
                  Icons.qr_code_scanner,
                  Colors.green,
                  () => _scanQRCode(),
                ),
                _buildActionCard(
                  'Importer',
                  Icons.file_upload,
                  Colors.orange,
                  () => _importContribuables(),
                ),
                _buildActionCard(
                  'Exporter',
                  Icons.file_download,
                  Colors.purple,
                  () => _exportContribuables(),
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

  Widget _buildRecentContribuables() {
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
                  'Contribuables Récents',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _viewAllContribuables(),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            if (_recentContribuables.isEmpty)
              Container(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_outline,
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
                children: _recentContribuables.take(5).map((contribuable) {
                  return ContribuableCard(
                    contribuable: contribuable,
                    onTap: () => _viewContribuable(contribuable),
                    onCall: () => _callContribuable(contribuable.telephone),
                    onPayment: () => _createPayment(contribuable),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          _buildOverviewCards(),
          
          SizedBox(height: 24.h),
          
          // Type distribution
          _buildTypeDistribution(),
          
          SizedBox(height: 24.h),
          
          // Zone distribution
          _buildZoneDistribution(),
          
          SizedBox(height: 24.h),
          
          // Sync status
          _buildSyncStatus(),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aperçu Général',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: 16.h),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Contribuables',
                '${_statistics!.totalContribuables}',
                Icons.people,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Créés Aujourd\'hui',
                '${_statistics!.creesAujourdhui}',
                Icons.person_add,
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
                'En Validation',
                '${_statistics!.enValidation}',
                Icons.pending,
                Colors.orange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Taux Sync',
                '${(_statistics!.tauxSynchronisation * 100).toStringAsFixed(1)}%',
                Icons.sync,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildTypeDistribution() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            ..._statistics!.repartitionParType.entries.map((entry) {
              final percentage = _statistics!.totalContribuables > 0
                  ? (entry.value / _statistics!.totalContribuables * 100)
                  : 0.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key.label),
                        Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTypeColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneDistribution() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par Zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            ..._statistics!.repartitionParZone.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(entry.key)),
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
        ),
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut de Synchronisation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildSyncStatusCard(
                    'Synchronisés',
                    '${_statistics!.totalContribuables - _statistics!.nonSynchronises}',
                    Icons.cloud_done,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSyncStatusCard(
                    'En attente',
                    '${_statistics!.nonSynchronises}',
                    Icons.cloud_off,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            if (_statistics!.derniereSynchronisation != null) ...[
              SizedBox(height: 16.h),
              Text(
                'Dernière synchronisation: ${_formatDateTime(_statistics!.derniereSynchronisation!)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
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

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showRecensementWizard,
      icon: const Icon(Icons.person_add),
      label: const Text('Nouveau'),
    );
  }

  // Helper methods
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Action methods
  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      _clearSearch();
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final recensementService = RecensementService();
      final results = await recensementService.searchContribuables(
        query: _searchController.text.trim(),
        limit: 50,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de recherche: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchResults = [];
    });
  }

  void _filterByType(ContribuableType? type) {
    // Implement type filtering
    _performSearch();
  }

  void _viewContribuable(ContribuableForm contribuable) {
    Navigator.of(context).pushNamed(
      '/contribuable/detail',
      arguments: contribuable,
    );
  }

  void _callContribuable(String telephone) {
    // Implement phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appel du $telephone')),
    );
  }

  void _createPayment(ContribuableForm contribuable) {
    Navigator.of(context).pushNamed(
      '/transaction/new',
      arguments: contribuable,
    );
  }

  void _showRecensementWizard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Recensement Wizard temporairement désactivé'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Fermer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scanQRCode() {
    // Implement QR code scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan QR Code à implémenter')),
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
        _loadData();
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

  void _importContribuables() {
    // Implement import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Importation à implémenter')),
    );
  }

  void _exportContribuables() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportation à implémenter')),
    );
  }

  void _viewAllContribuables() {
    Navigator.of(context).pushNamed('/contribuable/list');
  }

  // Data loading
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadRecentContribuables(),
        _loadStatistics(),
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

  Future<void> _loadRecentContribuables() async {
    try {
      final recensementService = RecensementService();
      final authService = Provider.of<AuthService>(context, listen: false);
      
      _recentContribuables = await recensementService.getContribuablesByAgent(
        authService.currentUser?.id ?? 'unknown',
      );
      
      // Sort by creation date (most recent first)
      _recentContribuables.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    } catch (e) {
      _logger.e('Error loading recent contribuables: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final recensementService = RecensementService();
      _statistics = await recensementService.getRecensementStatistics();
    } catch (e) {
      _logger.e('Error loading statistics: $e');
    }
  }
}
