import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.searchQuery});

  final String? searchQuery;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Data storage
  List<Map<String, dynamic>> _allPharmacies = [];
  List<Map<String, dynamic>> _visiblePharmacies = [];
  List<LatLng> _routePoints = [];
  LatLng? _currentUserLocation;
  StreamSubscription<Position>? _positionStream;
  bool _isLoading = false;
  String? _activeQuery;

  @override
  void initState() {
    super.initState();
    _activeQuery = _normalizeQuery(widget.searchQuery);
    _startLocationTracking();

    if (_activeQuery != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _filterByMedicine(_activeQuery!);
        }
      });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Prevents battery drain when leaving the screen
    super.dispose();
  }

  // --- LOGIC: DISTANCE CALCULATION ---
  double _calculateDistance(double targetLat, double targetLng) {
    if (_currentUserLocation == null) return 0.0;
    return Geolocator.distanceBetween(
      _currentUserLocation!.latitude,
      _currentUserLocation!.longitude,
      targetLat,
      targetLng,
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return "${(meters / 1000).toStringAsFixed(1)} km";
    return "${meters.toStringAsFixed(0)} m";
  }

  String? _normalizeQuery(String? query) {
    final normalized = query?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  Map<String, dynamic> _buildPharmacyEntry({
    required String name,
    required double lat,
    required double lng,
    required String type,
  }) {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
      'type': type,
      'distance': _calculateDistance(lat, lng),
    };
  }

  void _applyCurrentFilter({bool moveCamera = false}) {
    final query = _activeQuery?.toLowerCase();
    final filteredPharmacies = query == null
        ? List<Map<String, dynamic>>.from(_allPharmacies)
        : _allPharmacies.where((pharmacy) {
            final name = (pharmacy['name'] ?? '').toString().toLowerCase();
            return name.contains(query);
          }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _visiblePharmacies = filteredPharmacies;
    });

    if (moveCamera && filteredPharmacies.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _visiblePharmacies.isEmpty) {
          return;
        }

        final firstPharmacy = _visiblePharmacies.first;
        _mapController.move(
          LatLng(firstPharmacy['lat'], firstPharmacy['lng']),
          15,
        );
      });
    }
  }

  void _filterByMedicine(String query) {
    _activeQuery = _normalizeQuery(query);
    _applyCurrentFilter(moveCamera: true);
  }

  // --- LOGIC: LOADING & SORTING ---
  Future<void> _loadLocalData() async {
    try {
      final String response = await rootBundle.loadString(
        'lib/features/pharmacy_map/data/pharmacies12345.json',
      );
      final List<dynamic> decodedData = json.decode(response);
      final loadedPharmacies = decodedData.map((item) {
        final map = item as Map<String, dynamic>;
        final name = (map['name'] ?? map['Name'] ?? 'Pharmacy').toString();
        final lat = (map['lat'] ?? map['Latitude']) as num;
        final lng = (map['lng'] ?? map['Longitude']) as num;

        return _buildPharmacyEntry(
          name: name,
          lat: lat.toDouble(),
          lng: lng.toDouble(),
          type: 'Verified',
        );
      }).toList();

      setState(() {
        _allPharmacies
          ..clear()
          ..addAll(loadedPharmacies);
        _sortPharmacies();
        _visiblePharmacies = List<Map<String, dynamic>>.from(_allPharmacies);
      });

      if (_activeQuery != null) {
        _filterByMedicine(_activeQuery!);
      }
    } catch (e) {
      debugPrint("Asset Error: $e");
    }
  }

  Future<void> _fetchPublicData() async {
    if (_isLoading || _currentUserLocation == null) return;
    setState(() => _isLoading = true);

    final bounds = _mapController.camera.visibleBounds;
    final query =
        '[out:json];(node["amenity"="pharmacy"](${bounds.southWest.latitude},${bounds.southWest.longitude},${bounds.northEast.latitude},${bounds.northEast.longitude});way["amenity"="pharmacy"](${bounds.southWest.latitude},${bounds.southWest.longitude},${bounds.northEast.latitude},${bounds.northEast.longitude}););out center;';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      );
      if (response.statusCode == 200) {
        final List elements = json.decode(response.body)['elements'] ?? [];
        setState(() {
          for (var e in elements) {
            final double lat = (e['lat'] ?? e['center']['lat']).toDouble();
            final double lng = (e['lon'] ?? e['center']['lon']).toDouble();
            final String name = e['tags']?['name'] ?? "Public Pharmacy";

            if (!_allPharmacies.any((p) => p['name'] == name)) {
              _allPharmacies.add(
                _buildPharmacyEntry(
                  name: name,
                  lat: lat,
                  lng: lng,
                  type: 'Public',
                ),
              );
            }
          }
          _sortPharmacies();
        });

        _applyCurrentFilter();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortPharmacies() {
    _allPharmacies.sort((a, b) => a['distance'].compareTo(b['distance']));
  }

  // --- LOGIC: GPS & ROUTING ---
  Future<void> _startLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _currentUserLocation = LatLng(
                position.latitude,
                position.longitude,
              );
              for (var p in _allPharmacies) {
                p['distance'] = _calculateDistance(p['lat'], p['lng']);
              }
              _sortPharmacies();
            });
            _applyCurrentFilter();
            if (_allPharmacies.isEmpty) _loadLocalData();
          }
        });
  }

  Future<void> _getRoute(LatLng destination) async {
    if (_currentUserLocation == null) return;
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${_currentUserLocation!.longitude},${_currentUserLocation!.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=polyline',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _mapController.move(destination, 15);
        setState(() {
          _routePoints = _decodePolyline(data['routes'][0]['geometry']);
        });
      }
    } catch (e) {
      debugPrint("Route Error: $e");
    }
  }

  List<LatLng> _decodePolyline(String str) {
    List<LatLng> polyline = [];
    int index = 0, len = str.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      shift = 0;
      result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. THE MAP LAYER
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(9.01, 38.74),
              initialZoom: 13,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) _fetchPublicData();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smart_prescription.navigator',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (_currentUserLocation != null)
                    Marker(
                      point: _currentUserLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 35,
                      ),
                    ),
                  ..._visiblePharmacies.map(
                    (p) => Marker(
                      point: LatLng(p['lat'], p['lng']),
                      width: 100,
                      height: 75,
                      child: GestureDetector(
                        onTap: () => _getRoute(LatLng(p['lat'], p['lng'])),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: p['type'] == 'Verified'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                "${p['name']}\n${_formatDistance(p['distance'])}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              color: p['type'] == 'Verified'
                                  ? Colors.green
                                  : Colors.red,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. FLOATING HEADER (Title & Back Button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_searching,
                    color: Color(0xFF1A237E),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Pharmacy Navigator",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),

          // 3. SCROLLABLE DISTANCE LIST
          DraggableScrollableSheet(
            initialChildSize: 0.15,
            minChildSize: 0.1,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: _visiblePharmacies.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  _activeQuery == null
                                      ? 'No pharmacies available right now.'
                                      : 'No pharmacies matched "$_activeQuery".',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _visiblePharmacies.length,
                              itemBuilder: (context, index) {
                                final item = _visiblePharmacies[index];
                                return ListTile(
                                  leading: Icon(
                                    Icons.local_pharmacy,
                                    color: item['type'] == 'Verified'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  title: Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Distance: ${_formatDistance(item['distance'])}",
                                  ),
                                  trailing: const Icon(
                                    Icons.directions,
                                    color: Colors.blueAccent,
                                  ),
                                  onTap: () => _getRoute(
                                    LatLng(item['lat'], item['lng']),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
