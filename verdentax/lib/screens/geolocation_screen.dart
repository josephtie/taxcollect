import '../config/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/config.dart';
import '../models/models.dart';
import '../models/geolocation.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class GeolocationScreen extends StatefulWidget {
  const GeolocationScreen({super.key});

  @override
  State<GeolocationScreen> createState() => _GeolocationScreenState();
}

class _GeolocationScreenState extends State<GeolocationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  // final GeolocationService _geolocationService = GeolocationService(); // Temporarily disabled
  
  bool _isLoading = true;
  GeolocationStatistics? _statistics;
  List<ZoneAlert> _alerts = [];
  List<GeoZone> _zones = [];
  GpsTrackingMode _trackingMode = GpsTrackingMode.none;
  MapConfiguration _mapConfig = MapConfiguration();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
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
        title: const Text('Géolocalisation'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Carte'),
            Tab(icon: Icon(Icons.layers), text: 'Zones'),
            Tab(icon: Icon(Icons.warning), text: 'Alertes'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Statistiques'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showTrackingModeDialog,
            icon: const Icon(Icons.gps_fixed),
            tooltip: 'Mode de suivi GPS',
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
          _buildMapTab(),
          _buildZonesTab(),
          _buildAlertsTab(),
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildMapTab() {
    return Column(
      children: [
        // GPS Status Bar
        _buildGpsStatusBar(),
        
        // Map
        Expanded(
          child: Container(
            child: Center(
              child: Text('MapWidget temporairement désactivé'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGpsStatusBar() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // GPS Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _getTrackingModeColor(_trackingMode),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTrackingModeIcon(_trackingMode),
                  color: Colors.white,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  _trackingMode.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Current position
          // if (_geolocationService.currentPosition != null) ...[
          //   Icon(
          //     Icons.location_on,
          //     size: 16.sp,
          //     color: Theme.of(context).primaryColor,
          //   ),
          //   SizedBox(width: 4.w),
          //   Text(
          //     'Précision: ${_geolocationService.currentPosition!.accuracy.toStringAsFixed(1)}m',
          //     style: TextStyle(
          //       fontSize: 12.sp,
          //       color: Colors.grey.shade700,
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  Widget _buildZonesTab() {
    return Column(
      children: [
        // Zone management toolbar
        _buildZoneToolbar(),
        
        // Zones list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _zones.isEmpty
                  ? _buildEmptyZones()
                  : _buildZonesList(),
        ),
      ],
    );
  }

  Widget _buildZoneToolbar() {
    return Container(
      padding: EdgeInsets.all(16.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une zone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              onChanged: _searchZones,
            ),
          ),
          
          SizedBox(width: 12.w),
          
          ElevatedButton.icon(
            onPressed: _createNewZone,
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyZones() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_outlined,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Aucune zone définie',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Créez votre première zone pour commencer',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _createNewZone,
            icon: const Icon(Icons.add),
            label: const Text('Créer une zone'),
          ),
        ],
      ),
    );
  }

  Widget _buildZonesList() {
    return RefreshIndicator(
      onRefresh: _refreshZones,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        itemCount: _zones.length,
        itemBuilder: (context, index) {
          final zone = _zones[index];
          return ZoneCard(
            zone: zone,
            onTap: () => _showZoneDetails(zone),
            onEdit: () => _editZone(zone),
            onDelete: () => _deleteZone(zone),
          );
        },
      ),
    );
  }

  Widget _buildAlertsTab() {
    return Column(
      children: [
        // Alert filters
        _buildAlertFilters(),
        
        // Alerts list
        Expanded(
          child: _alerts.isEmpty
              ? _buildEmptyAlerts()
              : _buildAlertsList(),
        ),
      ],
    );
  }

  Widget _buildAlertFilters() {
    return Container(
      padding: EdgeInsets.all(16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildAlertFilterChip('Toutes', null),
            SizedBox(width: 8.w),
            _buildAlertFilterChip('Non reconnues', false),
            SizedBox(width: 8.w),
            _buildAlertFilterChip('Critiques', AlertSeverity.critical),
            SizedBox(width: 8.w),
            _buildAlertFilterChip('Hautes', AlertSeverity.high),
            SizedBox(width: 8.w),
            _buildAlertFilterChip('Moyennes', AlertSeverity.medium),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertFilterChip(String label, dynamic filter) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        _filterAlerts(filter);
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  Widget _buildEmptyAlerts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Aucune alerte',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Les alertes apparaîtront ici',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          return AlertCard(
            alert: alert,
            onTap: () => _showAlertDetails(alert),
            onAcknowledge: () => _acknowledgeAlert(alert),
          );
        },
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
          _buildStatisticsOverview(),
          
          SizedBox(height: 24.h),
          
          // Agent positions chart
          _buildAgentPositionsChart(),
          
          SizedBox(height: 24.h),
          
          // Zone density chart
          _buildZoneDensityChart(),
          
          SizedBox(height: 24.h),
          
          // Recent alerts
          _buildRecentAlertsSection(),
        ],
      ),
    );
  }

  Widget _buildStatisticsOverview() {
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
                'Agents Actifs',
                '${_statistics!.activeAgents}',
                Icons.people,
                AppTheme.goldColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Positions Aujourd\'hui',
                '${_statistics!.todayPositions}',
                Icons.location_on,
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
                'Couverture Zones',
                '${(_statistics!.zoneCoverage * 100).toStringAsFixed(1)}%',
                Icons.layers,
                Colors.orange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Alertes Actives',
                '${_statistics!.activeAlerts}',
                Icons.warning,
                Colors.red,
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

  Widget _buildAgentPositionsChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Positions par Agent',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Simple bar chart representation
            ..._statistics!.agentPositions.entries.map((entry) {
              final maxPositions = _statistics!.agentPositions.values
                  .reduce((a, b) => a > b ? a : b);
              final percentage = maxPositions > 0 ? entry.value / maxPositions : 0.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneDensityChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Densité par Zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            ..._statistics!.zoneDensity.entries.map((entry) {
              final zone = _zones.firstWhere(
                (z) => z.id == entry.key,
                orElse: () => GeoZone(
                  id: entry.key,
                  name: entry.key,
                  type: ZoneType.administrative,
                  points: [],
                  agentId: '',
                  color: '#1976D2',
                  createdAt: DateTime.now(),
                ),
              );
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        zone.name,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(2)} pos/km²',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsSection() {
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
                  'Alertes Récentes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _tabController.animateTo(2); // Switch to alerts tab
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            if (_statistics!.recentAlerts.isEmpty)
              Container(
                padding: EdgeInsets.all(32.h),
                child: const Center(
                  child: Text('Aucune alerte récente'),
                ),
              )
            else
              Column(
                children: _statistics!.recentAlerts.take(5).map((alert) {
                  return AlertCard(
                    alert: alert,
                    compact: true,
                    onTap: () => _showAlertDetails(alert),
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
      onPressed: () {
        _tabController.animateTo(0); // Switch to map tab
      },
      icon: const Icon(Icons.map),
      label: const Text('Carte'),
    );
  }

  // Helper methods
  Color _getTrackingModeColor(GpsTrackingMode mode) {
    switch (mode) {
      case GpsTrackingMode.none:
        return Colors.grey;
      case GpsTrackingMode.passive:
        return AppTheme.goldColor;
      case GpsTrackingMode.active:
        return Colors.orange;
      case GpsTrackingMode.continuous:
        return Colors.red;
    }
  }

  IconData _getTrackingModeIcon(GpsTrackingMode mode) {
    switch (mode) {
      case GpsTrackingMode.none:
        return Icons.gps_off;
      case GpsTrackingMode.passive:
        return Icons.gps_fixed;
      case GpsTrackingMode.active:
        return Icons.gps_not_fixed;
      case GpsTrackingMode.continuous:
        return Icons.gps_not_fixed;
    }
  }

  // Action methods
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadStatistics(),
        _loadAlerts(),
        _loadZones(),
        _loadTrackingMode(),
        _loadMapConfiguration(),
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
    // _statistics = await _geolocationService.getStatistics(); // Temporarily disabled
  }

  Future<void> _loadAlerts() async {
    // _alerts = _geolocationService.alerts; // Temporarily disabled
  }

  Future<void> _loadZones() async {
    // _zones = _geolocationService.zones; // Temporarily disabled
  }

  Future<void> _loadTrackingMode() async {
    // _trackingMode = _geolocationService.trackingMode; // Temporarily disabled
  }

  Future<void> _loadMapConfiguration() async {
    // _mapConfig = _geolocationService.mapConfig; // Temporarily disabled
  }

  Future<void> _refreshData() async {
    await _initializeData();
  }

  Future<void> _refreshZones() async {
    await _loadZones();
  }

  Future<void> _refreshAlerts() async {
    await _loadAlerts();
  }

  void _searchZones(String query) {
    // Implement zone search
  }

  void _filterAlerts(dynamic filter) {
    // Implement alert filtering
  }

  void _createNewZone() {
    _tabController.animateTo(0); // Switch to map tab
    // Enable zone drawing mode
  }

  void _showTrackingModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mode de Suivi GPS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GpsTrackingMode.values.map((mode) {
            return RadioListTile<GpsTrackingMode>(
              title: Text(mode.label),
              subtitle: Text(_getTrackingModeDescription(mode)),
              value: mode,
              groupValue: _trackingMode,
              onChanged: (value) async {
                if (value != null) {
                  Navigator.of(context).pop();
                  // await _geolocationService.setTrackingMode(value); // Temporarily disabled
                  setState(() {
                    _trackingMode = value;
                  });
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getTrackingModeDescription(GpsTrackingMode mode) {
    switch (mode) {
      case GpsTrackingMode.none:
        return 'Aucun suivi GPS';
      case GpsTrackingMode.passive:
        return 'Économie d\'énergie, mise à jour toutes les 5 minutes';
      case GpsTrackingMode.active:
        return 'Suivi régulier, mise à jour toutes les 30 secondes';
      case GpsTrackingMode.continuous:
        return 'Suivi constant, mise à jour toutes les 10 secondes';
    }
  }

  void _showMapActionDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actions sur la Position'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Ajouter un contribuable'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to contribuable creation with position
              },
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Ajouter un point d\'intérêt'),
              onTap: () {
                Navigator.of(context).pop();
                // Add point of interest
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Informations sur la position'),
              onTap: () {
                Navigator.of(context).pop();
                _showPositionInfo(position);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPositionInfo(LatLng position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations de Position'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${position.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${position.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 16),
            const Text('Cette position peut être utilisée pour:'),
            const Text('• Créer un nouveau contribuable'),
            const Text('• Ajouter un point d\'intérêt'),
            const Text('• Définir une zone de collecte'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showMarkerDetails(Marker marker) {
    // Show marker details dialog
  }

  void _showZoneDetails(GeoZone zone) {
    // Show zone details dialog
  }

  void _editZone(GeoZone zone) {
    // Edit zone dialog
  }

  void _deleteZone(GeoZone zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la Zone'),
        content: Text('Êtes-vous sûr de vouloir supprimer la zone "${zone.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // await _geolocationService.deleteZone(zone.id); // Temporarily disabled
                setState(() {
                  _zones.removeWhere((z) => z.id == zone.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Zone supprimée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de la suppression: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertDetails(ZoneAlert alert) {
    // Show alert details dialog
  }

  Future<void> _acknowledgeAlert(ZoneAlert alert) async {
    // Implement alert acknowledgment
  }
}

// Additional widgets for the geolocation screen
class ZoneCard extends StatelessWidget {
  final GeoZone zone;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ZoneCard({
    super.key,
    required this.zone,
    this.onTap,
    this.onEdit,
    this.onDelete,
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
              Row(
                children: [
                  // Zone icon
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: _parseColor(zone.color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getZoneTypeIcon(zone.type),
                      color: _parseColor(zone.color),
                      size: 20.sp,
                    ),
                  ),
                  
                  SizedBox(width: 12.w),
                  
                  // Zone info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          zone.type.label,
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
                      color: zone.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      zone.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: zone.isActive ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (zone.description.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  zone.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              
              // Action buttons
              if (onEdit != null || onDelete != null) ...[
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
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

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return const Color(0xFF1976D2);
    } catch (e) {
      return const Color(0xFF1976D2);
    }
  }

  IconData _getZoneTypeIcon(ZoneType type) {
    switch (type) {
      case ZoneType.administrative:
        return Icons.account_balance;
      case ZoneType.commercial:
        return Icons.store;
      case ZoneType.residential:
        return Icons.home;
      case ZoneType.industrial:
        return Icons.factory;
      case ZoneType.mixed:
        return Icons.layers;
    }
  }
}

class AlertCard extends StatelessWidget {
  final ZoneAlert alert;
  final VoidCallback? onTap;
  final VoidCallback? onAcknowledge;
  final bool compact;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onAcknowledge,
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
              Row(
                children: [
                  // Alert icon
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: _getSeverityColor(alert.severity).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      _getAlertTypeIcon(alert.type),
                      color: _getSeverityColor(alert.severity),
                      size: 20.sp,
                    ),
                  ),
                  
                  SizedBox(width: 12.w),
                  
                  // Alert info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.type.label,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!compact) ...[
                          SizedBox(height: 2.h),
                          Text(
                            alert.message,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status indicator
                  if (!alert.isAcknowledged)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(alert.severity).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Nouvelle',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _getSeverityColor(alert.severity),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              
              if (!compact) ...[
                SizedBox(height: 8.h),
                
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDateTime(alert.timestamp),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    if (onAcknowledge != null && !alert.isAcknowledged)
                      TextButton.icon(
                        onPressed: onAcknowledge,
                        icon: const Icon(Icons.check, size: 14),
                        label: const Text('Reconnaître'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return AppTheme.goldColor;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.purple;
    }
  }

  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.zoneExit:
        return Icons.exit_to_app;
      case AlertType.zoneEntry:
        return Icons.login;
      case AlertType.signalLoss:
        return Icons.signal_wifi_off;
      case AlertType.timeout:
        return Icons.timer_off;
      case AlertType.lowBattery:
        return Icons.battery_alert;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
