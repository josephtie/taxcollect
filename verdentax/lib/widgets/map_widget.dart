import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../models/geolocation.dart';
import '../services/services.dart';

class MapWidget extends StatefulWidget {
  final MapConfiguration? initialConfig;
  final Function(LatLng)? onMapTap;
  final Function(Marker)? onMarkerTap;
  final Function(GeoZone)? onZoneTap;
  final bool showControls;
  final bool enableZoneDrawing;

  const MapWidget({
    super.key,
    this.initialConfig,
    this.onMapTap,
    this.onMarkerTap,
    this.onZoneTap,
    this.showControls = true,
    this.enableZoneDrawing = false,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _mapController;
  final GeolocationService _geolocationService = GeolocationService();
  MapConfiguration _mapConfig = MapConfiguration();
  
  bool _isLoading = true;
  bool _isDrawingZone = false;
  final List<LatLng> _drawingPoints = [];
  
  @override
  void initState() {
    super.initState();
    _mapConfig = widget.initialConfig ?? _mapConfig;
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _mapConfig.center ?? const LatLng(5.3600, -4.0083), // Abidjan
            zoom: _mapConfig.zoomLevel,
          ),
          mapType: _getGoogleMapType(_mapConfig.viewType),
          myLocationEnabled: _mapConfig.showMyPosition,
          myLocationButtonEnabled: false, // We'll use custom button
          zoomControlsEnabled: false, // We'll use custom buttons
          markers: _geolocationService.markers,
          polygons: _geolocationService.polygons,
          circles: _geolocationService.circles,
          onTap: _onMapTap,
          onLongPress: _onMapLongPress,
          onMapCreated: _onMapCreated,
        ),
        
        // Loading indicator
        if (_isLoading)
          Container(
            color: Colors.white.withOpacity(0.8),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        
        // Map controls
        if (widget.showControls) _buildMapControls(),
        
        // Zone drawing controls
        if (widget.enableZoneDrawing) _buildZoneDrawingControls(),
        
        // Layer controls
        _buildLayerControls(),
        
        // Zone drawing overlay
        if (_isDrawingZone) _buildZoneDrawingOverlay(),
      ],
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16.w,
      top: 100.h,
      child: Column(
        children: [
          // Zoom in button
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            onPressed: _zoomIn,
            child: const Icon(Icons.add),
          ),
          
          SizedBox(height: 8.h),
          
          // Zoom out button
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            onPressed: _zoomOut,
            child: const Icon(Icons.remove),
          ),
          
          SizedBox(height: 8.h),
          
          // My location button
          FloatingActionButton(
            heroTag: 'my_location',
            mini: true,
            onPressed: _goToMyLocation,
            child: const Icon(Icons.my_location),
          ),
          
          SizedBox(height: 8.h),
          
          // Refresh button
          FloatingActionButton(
            heroTag: 'refresh',
            mini: true,
            onPressed: _refreshMap,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerControls() {
    return Positioned(
      left: 16.w,
      top: 100.h,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contribuables toggle
            _buildLayerToggle(
              'Contribuables',
              Icons.people,
              _mapConfig.showContribuables,
              () => _toggleLayer('contribuables'),
            ),
            
            _buildDivider(),
            
            // Zones toggle
            _buildLayerToggle(
              'Zones',
              Icons.layers,
              _mapConfig.showZones,
              () => _toggleLayer('zones'),
            ),
            
            _buildDivider(),
            
            // Heatmap toggle
            _buildLayerToggle(
              'Carte thermique',
              Icons.whatshot,
              _mapConfig.showHeatmap,
              () => _toggleLayer('heatmap'),
            ),
            
            _buildDivider(),
            
            // Other agents toggle
            _buildLayerToggle(
              'Autres agents',
              Icons.people_outline,
              _mapConfig.showOtherAgents,
              () => _toggleLayer('otherAgents'),
            ),
            
            _buildDivider(),
            
            // Points of interest toggle
            _buildLayerToggle(
              'Points d\'intérêt',
              Icons.place,
              _mapConfig.showPointsOfInterest,
              () => _toggleLayer('pointsOfInterest'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerToggle(String title, IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isActive ? Theme.of(context).primaryColor : Colors.grey,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.h,
      width: 120.w,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildZoneDrawingControls() {
    return Positioned(
      left: 16.w,
      bottom: 100.h,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Start/Stop drawing button
            FloatingActionButton.extended(
              heroTag: 'zone_drawing',
              onPressed: _toggleZoneDrawing,
              icon: Icon(_isDrawingZone ? Icons.stop : Icons.edit),
              label: Text(_isDrawingZone ? 'Terminer' : 'Dessiner zone'),
              backgroundColor: _isDrawingZone ? Colors.red : Theme.of(context).primaryColor,
            ),
            
            if (_isDrawingZone) ...[
              SizedBox(height: 8.h),
              
              // Clear drawing button
              FloatingActionButton(
                heroTag: 'clear_drawing',
                mini: true,
                onPressed: _clearDrawing,
                child: const Icon(Icons.clear),
              ),
              
              SizedBox(height: 8.h),
              
              // Undo last point button
              FloatingActionButton(
                heroTag: 'undo_drawing',
                mini: true,
                onPressed: _undoLastPoint,
                child: const Icon(Icons.undo),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildZoneDrawingOverlay() {
    return Positioned(
      top: 60.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.edit, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Mode dessin de zone activé. Tapez sur la carte pour ajouter des points.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Text(
              '${_drawingPoints.length} points',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  MapType _getGoogleMapType(MapViewType viewType) {
    switch (viewType) {
      case MapViewType.normal:
        return MapType.normal;
      case MapViewType.satellite:
        return MapType.satellite;
      case MapViewType.hybrid:
        return MapType.hybrid;
      case MapViewType.terrain:
        return MapType.terrain;
    }
  }

  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Initialize geolocation service
      await _geolocationService.initialize();
      
      // Listen to configuration changes
      _geolocationService.statsStream.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
      
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'initialisation de la carte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Note: GeolocationService doesn't have _mapController setter
    // This would need to be implemented in the service
    // _geolocationService.setMapController(controller);
    
    // Set initial map configuration
    if (_mapConfig.center != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _mapConfig.center!,
            zoom: _mapConfig.zoomLevel,
          ),
        ),
      );
    }
  }

  void _onMapTap(LatLng position) {
    if (_isDrawingZone) {
      _addDrawingPoint(position);
    } else if (widget.onMapTap != null) {
      widget.onMapTap!(position);
    }
  }

  void _onMapLongPress(LatLng position) {
    if (!_isDrawingZone && widget.enableZoneDrawing) {
      _toggleZoneDrawing();
      _addDrawingPoint(position);
    }
  }

  void _toggleZoneDrawing() {
    setState(() {
      _isDrawingZone = !_isDrawingZone;
      if (!_isDrawingZone && _drawingPoints.isNotEmpty) {
        _finishZoneDrawing();
      }
    });
  }

  void _addDrawingPoint(LatLng point) {
    setState(() {
      _drawingPoints.add(point);
      
      // Add temporary marker for visual feedback
      final marker = Marker(
        markerId: MarkerId('drawing_${_drawingPoints.length - 1}'),
        position: point,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
      
      // Note: GeolocationService doesn't expose _markers directly
      // This would need to be implemented in the service
      // _geolocationService._markers.add(marker);
    });
  }

  void _clearDrawing() {
    setState(() {
      _drawingPoints.clear();
      
      // Remove temporary markers
      // Note: GeolocationService doesn't expose _markers directly
      // This would need to be implemented in the service
      // _geolocationService._markers.removeWhere(
      //   (m) => m.markerId.value.startsWith('drawing_'),
      // );
    });
  }

  void _undoLastPoint() {
    if (_drawingPoints.isNotEmpty) {
      setState(() {
        _drawingPoints.removeLast();
        
        // Remove last temporary marker
        // Note: GeolocationService doesn't expose _markers directly
        // final lastMarkerIndex = _geolocationService._markers.length - 1;
        // if (lastMarkerIndex >= 0) {
        //   _geolocationService._markers.removeAt(lastMarkerIndex);
        // }
      });
    }
  }

  void _finishZoneDrawing() {
    if (_drawingPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une zone doit avoir au moins 3 points'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Remove temporary markers
    // Note: GeolocationService doesn't expose _markers directly
    // This would need to be implemented in the service
    // _geolocationService._markers.removeWhere(
    //   (m) => m.markerId.value.startsWith('drawing_'),
    // );
    
    // Show zone creation dialog
    _showZoneCreationDialog();
  }

  void _showZoneCreationDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    ZoneType selectedType = ZoneType.administrative;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une Zone'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la zone',
                  hintText: 'Entrez le nom',
                ),
              ),
              
              SizedBox(height: 16.h),
              
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Entrez la description (optionnel)',
                ),
                maxLines: 3,
              ),
              
              SizedBox(height: 16.h),
              
              DropdownButtonFormField<ZoneType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type de zone',
                ),
                items: ZoneType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedType = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearDrawing();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le nom de la zone est obligatoire'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                
                await _geolocationService.createZone(
                  name: nameController.text.trim(),
                  type: selectedType,
                  points: _drawingPoints,
                  description: descriptionController.text.trim(),
                );
                
                if (mounted) {
                  Navigator.of(context).pop();
                  _clearDrawing();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Zone créée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la création de la zone: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isDrawingZone = false;
                  });
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _toggleLayer(String layer) async {
    await _geolocationService.toggleLayer(layer);
    setState(() {}); // Rebuild to update UI
  }

  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _goToMyLocation() async {
    try {
      final position = await _geolocationService.getCurrentPositionLatLng();
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 16.0,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'obtenir votre position: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshMap() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Refresh map data
      await _geolocationService.getStatistics();
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carte actualisée'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'actualisation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class MapControlsWidget extends StatelessWidget {
  final GoogleMapController mapController;
  final MapConfiguration mapConfig;
  final Function(MapViewType)? onViewTypeChanged;
  final VoidCallback? onRefresh;
  final VoidCallback? onMyLocation;

  const MapControlsWidget({
    super.key,
    required this.mapController,
    required this.mapConfig,
    this.onViewTypeChanged,
    this.onRefresh,
    this.onMyLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.h,
      right: 16.w,
      child: Column(
        children: [
          // Map type selector
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<MapViewType>(
              icon: const Icon(Icons.layers),
              tooltip: 'Type de carte',
              onSelected: (MapViewType type) {
                if (onViewTypeChanged != null) {
                  onViewTypeChanged!(type);
                }
              },
              itemBuilder: (context) => MapViewType.values.map((type) {
                return PopupMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getMapTypeIcon(type),
                        color: mapConfig.viewType == type 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          // Refresh button
          FloatingActionButton(
            heroTag: 'refresh_map',
            mini: true,
            onPressed: onRefresh,
            child: const Icon(Icons.refresh),
          ),
          
          SizedBox(height: 8.h),
          
          // My location button
          FloatingActionButton(
            heroTag: 'my_location_map',
            mini: true,
            onPressed: onMyLocation,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  IconData _getMapTypeIcon(MapViewType type) {
    switch (type) {
      case MapViewType.normal:
        return Icons.map;
      case MapViewType.satellite:
        return Icons.satellite;
      case MapViewType.hybrid:
        return Icons.layers;
      case MapViewType.terrain:
        return Icons.terrain;
    }
  }
}
