import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class DiscoveryMapScreen extends StatefulWidget {
  const DiscoveryMapScreen({super.key});

  @override
  State<DiscoveryMapScreen> createState() => _DiscoveryMapScreenState();
}

class _DiscoveryMapScreenState extends State<DiscoveryMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoading = true;
  
  // Sample material locations (in real app, fetch from Supabase)
  final List<MaterialPin> _materialPins = [
    // VESIT Mumbai vicinity pins
    MaterialPin(
      id: '1',
      location: LatLng(19.0506, 72.8974),
      title: 'Lab A - PCB Components',
      description: '5x Arduino boards, sensors, jumper wires',
      materialType: 'Electronics',
      distance: 0.2,
    ),
    MaterialPin(
      id: '2',
      location: LatLng(19.0515, 72.8966),
      title: 'Electronics Lab B - Copper Wire',
      description: '3kg copper spools for prototyping',
      materialType: 'Metal',
      distance: 0.4,
    ),
    MaterialPin(
      id: '3',
      location: LatLng(19.0498, 72.8980),
      title: 'Workshop - Acrylic Sheets',
      description: 'Clear acrylic sheets, 12"x18" and 18"x24"',
      materialType: 'Acrylic',
      distance: 0.6,
    ),
    MaterialPin(
      id: '4',
      location: LatLng(19.0522, 72.8978),
      title: 'Storage Room A - Aluminum Rods',
      description: '6061 aluminum, assorted lengths',
      materialType: 'Metal',
      distance: 0.7,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Materials'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? LatLng(19.0510, 72.8970),
                initialZoom: 15.0,
                minZoom: 10.0,
                maxZoom: 18.0,
              ),
              children: [
                // OpenStreetMap tiles
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.reclaim.app',
                  maxZoom: 18,
                ),
                
                // Current location marker
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                
                // Material pins
                MarkerLayer(
                  markers: _materialPins.map((pin) => Marker(
                    point: pin.location,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showMaterialDetails(pin),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getMaterialColor(pin.materialType),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getMaterialIcon(pin.materialType),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "zoom_in",
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: "zoom_out",
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      
      // Move map to current location
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 15.0);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
    }
  }

  void _showMaterialDetails(MaterialPin pin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getMaterialColor(pin.materialType),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getMaterialIcon(pin.materialType),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pin.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${pin.distance}km away • ${pin.materialType}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pin.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.directions),
                        label: const Text('Get Directions'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Navigate to request screen
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Request'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Materials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Electronics'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Acrylic'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Metal'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Color _getMaterialColor(String materialType) {
    switch (materialType.toLowerCase()) {
      case 'electronics':
        return Colors.blue;
      case 'acrylic':
        return Colors.purple;
      case 'metal':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getMaterialIcon(String materialType) {
    switch (materialType.toLowerCase()) {
      case 'electronics':
        return Icons.memory;
      case 'acrylic':
        return Icons.crop_square;
      case 'metal':
        return Icons.hardware;
      default:
        return Icons.category;
    }
  }
}

class MaterialPin {
  final String id;
  final LatLng location;
  final String title;
  final String description;
  final String materialType;
  final double distance;

  MaterialPin({
    required this.id,
    required this.location,
    required this.title,
    required this.description,
    required this.materialType,
    required this.distance,
  });
}