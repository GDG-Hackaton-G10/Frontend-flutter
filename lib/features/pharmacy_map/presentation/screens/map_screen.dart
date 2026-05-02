import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prescription_navigator/core/index.dart';

import '../providers/pharmacy_lookup_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.searchQuery, this.medicines = const []});

  final String? searchQuery;
  final List<String> medicines;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allPharmacies = [];
  List<Map<String, dynamic>> _visiblePharmacies = [];
  List<LatLng> _routePoints = [];
  LatLng? _currentUserLocation;
  StreamSubscription<Position>? _positionStream;

  bool _isLoading = false;
  bool _isFilterLoading = false;
  String? _activeQuery;
  List<String> _activeMedicines = const [];
  bool _hasLoadedBackendPharmacies = false;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _activeQuery = _normalizeQuery(widget.searchQuery);
    _activeMedicines = widget.medicines
        .map((medicine) => medicine.trim())
        .where((medicine) => medicine.isNotEmpty)
        .toList();
    _searchController.text = _activeQuery ?? '';
    _isFilterLoading = _activeQuery != null || _activeMedicines.isNotEmpty;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _startLocationTracking();

    if (_activeQuery != null && _activeMedicines.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _filterByMedicine(_activeQuery!);
        }
      });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double _calculateDistance(double targetLat, double targetLng) {
    if (_currentUserLocation == null) {
      return 0.0;
    }
    return Geolocator.distanceBetween(
      _currentUserLocation!.latitude,
      _currentUserLocation!.longitude,
      targetLat,
      targetLng,
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
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

  Future<void> _loadNearbyPharmacies() async {
    if (_currentUserLocation == null || _hasLoadedBackendPharmacies) {
      return;
    }

    final medicines = _activeMedicines.isNotEmpty
        ? _activeMedicines
        : (_activeQuery == null ? const <String>[] : <String>[_activeQuery!]);

    if (medicines.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _isFilterLoading = true;
      });
    }

    try {
      final pharmacies = await ref
          .read(pharmacyLookupServiceProvider)
          .fetchNearbyPharmacies(
            medicines: medicines,
            latitude: _currentUserLocation!.latitude,
            longitude: _currentUserLocation!.longitude,
          );

      if (!mounted) {
        return;
      }

      if (pharmacies.isNotEmpty) {
        setState(() {
          _allPharmacies
            ..clear()
            ..addAll(
              pharmacies.map((pharmacy) {
                return _buildPharmacyEntry(
                  name: pharmacy['name']?.toString() ?? 'Pharmacy',
                  lat: (pharmacy['lat'] as num).toDouble(),
                  lng: (pharmacy['lng'] as num).toDouble(),
                  type: pharmacy['type']?.toString() ?? 'Nearby',
                );
              }),
            );
          _sortPharmacies();
          _visiblePharmacies = List<Map<String, dynamic>>.from(_allPharmacies);
          _hasLoadedBackendPharmacies = true;
        });

        _applyCurrentFilter(moveCamera: true);
        return;
      }
    } catch (error) {
      debugPrint('Nearby pharmacy fetch error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFilterLoading = false;
        });
      }
    }

    if (_allPharmacies.isEmpty) {
      await _loadLocalData();
    }
  }

  void _applyCurrentFilter({bool moveCamera = false}) {
    final query = _activeQuery?.toLowerCase();
    final filtered = query == null
        ? List<Map<String, dynamic>>.from(_allPharmacies)
        : _allPharmacies.where((pharmacy) {
            final name = (pharmacy['name'] ?? '').toString().toLowerCase();
            return name.contains(query);
          }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _visiblePharmacies = filtered;
    });

    if (moveCamera && filtered.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _visiblePharmacies.isEmpty) {
          return;
        }
        final first = _visiblePharmacies.first;
        _mapController.move(LatLng(first['lat'], first['lng']), 15);
      });
    }
  }

  void _filterByMedicine(String query) {
    _activeQuery = _normalizeQuery(query);
    _searchController.text = _activeQuery ?? '';
    _hasLoadedBackendPharmacies = false;

    if (_activeQuery == null) {
      _applyCurrentFilter(moveCamera: true);
      if (mounted) {
        setState(() {
          _isFilterLoading = false;
        });
      }
      return;
    }

    if (_allPharmacies.isEmpty) {
      if (mounted) {
        setState(() {
          _isFilterLoading = true;
        });
      }
      return;
    }

    _applyCurrentFilter(moveCamera: true);
    if (mounted) {
      setState(() {
        _isFilterLoading = false;
      });
    }
  }

  Future<void> _loadLocalData() async {
    try {
      final response = await rootBundle.loadString(
        'lib/features/pharmacy_map/data/pharmacies12345.json',
      );
      final List<dynamic> decoded = json.decode(response);
      final loaded = decoded.map((item) {
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
          ..addAll(loaded);
        _sortPharmacies();
        _visiblePharmacies = List<Map<String, dynamic>>.from(_allPharmacies);
      });

      if (_activeQuery != null) {
        _filterByMedicine(_activeQuery!);
      }
    } catch (e) {
      debugPrint('Asset Error: $e');
      if (mounted) {
        setState(() {
          _isFilterLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPublicData() async {
    if (_isLoading || _currentUserLocation == null) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

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
          for (final e in elements) {
            final double lat = (e['lat'] ?? e['center']['lat']).toDouble();
            final double lng = (e['lon'] ?? e['center']['lon']).toDouble();
            final String name = e['tags']?['name'] ?? 'Public Pharmacy';
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sortPharmacies() {
    _allPharmacies.sort((a, b) => a['distance'].compareTo(b['distance']));
  }

  Future<void> _startLocationTracking() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          if (!mounted) {
            return;
          }

          setState(() {
            _currentUserLocation = LatLng(
              position.latitude,
              position.longitude,
            );
            for (final p in _allPharmacies) {
              p['distance'] = _calculateDistance(p['lat'], p['lng']);
            }
            _sortPharmacies();
          });
          _applyCurrentFilter();

          if ((_activeMedicines.isNotEmpty || _activeQuery != null) &&
              !_hasLoadedBackendPharmacies) {
            _loadNearbyPharmacies();
          }

          if (_allPharmacies.isEmpty) {
            _loadLocalData();
          }
        });
  }

  Future<void> _getRoute(LatLng destination) async {
    if (_currentUserLocation == null) {
      return;
    }

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
      debugPrint('Route Error: $e');
    }
  }

  List<LatLng> _decodePolyline(String str) {
    final polyline = <LatLng>[];
    var index = 0;
    final len = str.length;
    var lat = 0;
    var lng = 0;

    while (index < len) {
      var b = 0;
      var shift = 0;
      var result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: AppTheme.textPrimary,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(9.01, 38.74),
              initialZoom: 13,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd &&
                    _activeMedicines.isEmpty &&
                    _activeQuery == null) {
                  _fetchPublicData();
                }
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
                    color: AppTheme.primary,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (_currentUserLocation != null)
                    Marker(
                      point: _currentUserLocation!,
                      width: 42,
                      height: 42,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.secondary, AppTheme.primary],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ..._visiblePharmacies.map(
                    (p) => Marker(
                      point: LatLng(p['lat'], p['lng']),
                      width: 110,
                      height: 86,
                      child: GestureDetector(
                        onTap: () => _getRoute(LatLng(p['lat'], p['lng'])),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: p['type'] == 'Verified'
                                      ? AppTheme.success
                                      : AppTheme.warning,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${p['name']}\n${_formatDistance(p['distance'])}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_on_rounded,
                              color: p['type'] == 'Verified'
                                  ? AppTheme.success
                                  : AppTheme.warning,
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A0F172A),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.primary, AppTheme.accent],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.explore_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pharmacy Navigator',
                              style: titleStyle,
                            ),
                          ),
                          if (_isLoading || _isFilterLoading)
                            const AppLoadingSpinner(size: AppSpinnerSize.small),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _filterByMedicine,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded),
                          hintText: 'Search pharmacy by medicine name',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _filterByMedicine('');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.18,
            minChildSize: 0.11,
            maxChildSize: 0.62,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      border: Border.all(
                        color: AppTheme.textPrimary.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    0,
                                    12,
                                    16,
                                  ),
                                  itemCount: _visiblePharmacies.length,
                                  itemBuilder: (context, index) {
                                    final item = _visiblePharmacies[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppTheme.textPrimary
                                              .withValues(alpha: 0.08),
                                          width: 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color:
                                                (item['type'] == 'Verified'
                                                        ? AppTheme.success
                                                        : AppTheme.warning)
                                                    .withValues(alpha: 0.16),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.local_pharmacy_rounded,
                                            color: item['type'] == 'Verified'
                                                ? AppTheme.success
                                                : AppTheme.warning,
                                          ),
                                        ),
                                        title: Text(
                                          item['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Distance: ${_formatDistance(item['distance'])}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              'Address: ${item['lat'].toStringAsFixed(4)}, ${item['lng'].toStringAsFixed(4)}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppTheme.primary
                                                        .withValues(alpha: 0.8),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                          Icons.directions_rounded,
                                          color: Colors.black87,
                                        ),
                                        onTap: () => _getRoute(
                                          LatLng(item['lat'], item['lng']),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isFilterLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.24),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 0.94 + (_pulseController.value * 0.12);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.75),
                            width: 1,
                          ),
                        ),
                        child: const AppLoadingSpinner(
                          size: AppSpinnerSize.large,
                          text: 'Scanning Medicine...',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
