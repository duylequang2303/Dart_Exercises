import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_routes_screen.dart';

class RouterFinderScreen extends StatefulWidget {
  const RouterFinderScreen({super.key});

  @override
  State<RouterFinderScreen> createState() => _RouterFinderScreenState();
}

class _RouterFinderScreenState extends State<RouterFinderScreen> {
  // ─── Controllers ─────────────────────────────────────────────────────────
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController   = TextEditingController();

  // ─── Map state ───────────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  final List<Marker>   _markers   = [];
  final List<Polyline> _polylines = [];

  bool _isLoading = false;
  String _selectedMode = 'driving'; // default: car ('driving', 'bicycle', 'foot')

  // ─── Route info (feature 2) ───────────────────────────────────────────────
  String? _routeDistance;
  String? _routeDuration;

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _autoFillStart();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ─── Geocoding & Reverse Geocoding ─────────────────────────────────────────

  Future<LatLng?> _geocodeAddress(String address, String fieldName) async {
    // 1. Check if it's already "lat,lng" coordinates
    final List<String> parts = address.split(',');
    if (parts.length == 2) {
      final double? lat = double.tryParse(parts[0].trim());
      final double? lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) {
        if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          return LatLng(lat, lng);
        }
      }
    }

    // 2. Query Nominatim Geocoding API
    final Uri url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(address)}'
      '&format=json&limit=1'
    );

    try {
      final http.Response response = await http.get(
        url,
        headers: {'User-Agent': 'DemoMapsApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          final double lat = double.parse(data[0]['lat'] as String);
          final double lng = double.parse(data[0]['lon'] as String);
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      debugPrint('Lỗi Geocoding Nominatim: $e');
    }
    _showSnackBar('Không thể tìm thấy địa chỉ cho $fieldName: "$address"');
    return null;
  }

  Future<String> _reverseGeocode(LatLng point) async {
    final Uri url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=${point.latitude}&lon=${point.longitude}'
      '&format=json'
    );
    try {
      final http.Response response = await http.get(
        url,
        headers: {'User-Agent': 'DemoMapsApp/1.0'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['display_name'] != null) {
          return data['display_name'] as String;
        }
      }
    } catch (e) {
      debugPrint('Lỗi Reverse Geocoding Nominatim: $e');
    }
    return '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
  }

  // ─── GPS auto-fill ───────────────────────────────────────────────────────

  Future<void> _autoFillStart() async {
    // Check / request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnackBar('Không thể lấy vị trí: quyền bị từ chối.');
      return;
    }

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Dịch vụ GPS bị tắt. Vui lòng bật trong Cài đặt.');
      return;
    }

    try {
      setState(() => _startController.text = 'Đang định vị vị trí hiện tại...');
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng latLng = LatLng(pos.latitude, pos.longitude);
      
      final String address = await _reverseGeocode(latLng);
      if (mounted) {
        setState(() => _startController.text = address);
      }
    } catch (e) {
      _showSnackBar('Lỗi khi lấy vị trí: $e');
      if (mounted) {
        setState(() => _startController.clear());
      }
    }
  }

  Future<void> _autoFillEnd() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnackBar('Không thể lấy vị trí: quyền bị từ chối.');
      return;
    }

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Dịch vụ GPS bị tắt. Vui lòng bật trong Cài đặt.');
      return;
    }

    try {
      setState(() => _endController.text = 'Đang định vị vị trí hiện tại...');
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng latLng = LatLng(pos.latitude, pos.longitude);
      
      final String address = await _reverseGeocode(latLng);
      if (mounted) {
        setState(() => _endController.text = address);
      }
    } catch (e) {
      _showSnackBar('Lỗi khi lấy vị trí: $e');
      if (mounted) {
        setState(() => _endController.clear());
      }
    }
  }

  // ─── Directions API ──────────────────────────────────────────────────────

  Future<void> _findRoute() async {
    final String startText = _startController.text.trim();
    final String endText = _endController.text.trim();

    if (startText.isEmpty) {
      _showSnackBar('Vui lòng nhập điểm bắt đầu.');
      return;
    }
    if (endText.isEmpty) {
      _showSnackBar('Vui lòng nhập điểm kết thúc.');
      return;
    }

    setState(() {
      _isLoading = true;
      _routeDistance = null;
      _routeDuration = null;
    });

    // Geocode start & end addresses
    final LatLng? origin = await _geocodeAddress(startText, 'Điểm bắt đầu');
    if (origin == null) {
      setState(() => _isLoading = false);
      return;
    }
    final LatLng? destination = await _geocodeAddress(endText, 'Điểm kết thúc');
    if (destination == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Determine OSRM profile based on mode selection
    // car -> driving, motorcycle -> bicycle, foot -> foot
    final String profile = _selectedMode;

    // OSRM expects coordinates in lng,lat;lng,lat format
    final Uri url = Uri.parse(
      'https://router.project-osrm.org/route/v1/$profile/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final http.Response response = await http.get(url);

      if (response.statusCode != 200) {
        _showSnackBar(
          'Lỗi kết nối OSRM API (HTTP ${response.statusCode}).',
        );
        return;
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final String code = data['code'] as String;
      if (code != 'Ok') {
        _showSnackBar('OSRM API lỗi: $code');
        return;
      }

      final List<dynamic> coords =
          data['routes'][0]['geometry']['coordinates'] as List<dynamic>;
      final List<LatLng> points = coords.map((c) {
        final List<dynamic> point = c as List<dynamic>;
        return LatLng(point[1] as double, point[0] as double);
      }).toList();

      // Build bounds to fit both endpoints + route
      final LatLngBounds bounds = _boundsFromLatLngList([
        origin,
        destination,
        ...points,
      ]);

      // ── Extract route info (feature 2) ───────────────────────────────
      final Map<String, dynamic> routeObj =
          data['routes'][0] as Map<String, dynamic>;
      final double distanceMeters = (routeObj['distance'] as num).toDouble();
      final double durationSeconds = (routeObj['duration'] as num).toDouble();

      final String distanceText = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
      
      String durationText;
      final double durationMinutes = durationSeconds / 60;
      if (durationMinutes >= 60) {
        final int hours = (durationMinutes / 60).floor();
        final int mins = (durationMinutes % 60).round();
        durationText = '$hours giờ $mins phút';
      } else {
        durationText = '${durationMinutes.round()} phút';
      }

      // ── Update map state ──────────────────────────────────────────────
      setState(() {
        // Clear previous results
        _markers.clear();
        _polylines.clear();

        // Store route info
        _routeDistance = distanceText;
        _routeDuration = durationText;

        // Origin marker (green)
        _markers.add(
          Marker(
            point: origin,
            width: 45,
            height: 45,
            child: const Icon(
              Icons.trip_origin,
              color: Colors.green,
              size: 30,
            ),
          ),
        );

        // Destination marker (red)
        _markers.add(
          Marker(
            point: destination,
            width: 45,
            height: 45,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        );

        // Blue route polyline
        _polylines.add(
          Polyline(
            points: points,
            color: Colors.blue,
            strokeWidth: 5,
          ),
        );
      });

      // Animate camera to fit route
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    } on http.ClientException catch (e) {
      _showSnackBar('Lỗi mạng: $e');
    } catch (e) {
      _showSnackBar('Có lỗi xảy ra: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Favorites Management ──────────────────────────────────────────────────

  Future<void> _saveToFavorites() async {
    final String startText = _startController.text.trim();
    final String endText = _endController.text.trim();

    if (startText.isEmpty || endText.isEmpty) {
      _showSnackBar('Chưa có thông tin tuyến đường để lưu.');
      return;
    }

    // Geocode to ensure coordinates are correct before saving
    final LatLng? origin = await _geocodeAddress(startText, 'Điểm bắt đầu');
    final LatLng? destination = await _geocodeAddress(endText, 'Điểm kết thúc');

    if (origin == null || destination == null) {
      _showSnackBar('Tọa độ không hợp lệ để lưu.');
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? rawData = prefs.getString('favorite_routes');
      List<Map<String, dynamic>> favs = [];
      if (rawData != null) {
        final List<dynamic> decoded = jsonDecode(rawData) as List<dynamic>;
        favs = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      // Add new favorite item
      final Map<String, dynamic> newItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'startName': startText,
        'endName': endText,
        'startLat': origin.latitude,
        'startLng': origin.longitude,
        'endLat': destination.latitude,
        'endLng': destination.longitude,
        'mode': _selectedMode,
        'distance': _routeDistance ?? '',
        'duration': _routeDuration ?? '',
      };

      favs.add(newItem);
      await prefs.setString('favorite_routes', jsonEncode(favs));
      _showSnackBar('Đã thêm vào danh sách yêu thích!');
    } catch (e) {
      _showSnackBar('Lỗi lưu yêu thích: $e');
    }
  }

  Future<void> _openFavorites() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoriteRoutesScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _startController.text = result['startName'] ?? '';
        _endController.text = result['endName'] ?? '';
        _selectedMode = result['mode'] ?? 'driving';
      });
      // Automatically trigger finding the route
      _findRoute();
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final LatLng p in list) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─── Premium Vehicle Mode Selector Builder ─────────────────────────────────

  Widget _buildVehicleSelector() {
    final List<Map<String, dynamic>> modes = [
      {'id': 'driving', 'name': 'Xe hơi', 'icon': Icons.directions_car},
      {'id': 'bicycle', 'name': 'Xe máy', 'icon': Icons.motorcycle},
      {'id': 'foot', 'name': 'Đi bộ', 'icon': Icons.directions_walk},
    ];

    return Row(
      children: modes.map((m) {
        final bool isSelected = _selectedMode == m['id'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedMode = m['id'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade700 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      m['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm đường đi'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Danh sách yêu thích',
            onPressed: _openFavorites,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Input panel ────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                // Start field
                TextField(
                  controller: _startController,
                  decoration: InputDecoration(
                    labelText: 'Điểm bắt đầu (địa chỉ hoặc toạ độ)',
                    hintText: 'vd: 227 Nguyễn Văn Cừ',
                    prefixIcon: const Icon(
                      Icons.trip_origin,
                      color: Colors.green,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      tooltip: 'Dùng vị trí hiện tại',
                      onPressed: _autoFillStart,
                    ),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // End field
                TextField(
                  controller: _endController,
                  decoration: InputDecoration(
                    labelText: 'Điểm kết thúc (địa chỉ hoặc toạ độ)',
                    hintText: 'vd: Chợ Bến Thành',
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      tooltip: 'Dùng vị trí hiện tại',
                      onPressed: _autoFillEnd,
                    ),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Vehicle Selector
                _buildVehicleSelector(),
                const SizedBox(height: 10),

                // Find-route button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _findRoute,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.directions),
                    label: Text(
                      _isLoading ? 'Đang tìm...' : 'Tìm đường đi',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                // Feature 2 – route info & save button
                if (_routeDistance != null && _routeDuration != null) ...
                  [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.straighten, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'Khoảng cách: $_routeDistance',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'Thời gian: $_routeDuration',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _saveToFavorites,
                          icon: const Icon(Icons.favorite, color: Colors.red, size: 18),
                          label: const Text('Lưu yêu thích'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade700,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Map ─────────────────────────────────────────────────────────
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(21.0278, 105.8342), // Hanoi centre
                initialZoom: 13,
                // Feature 3 – tap map to set destination (reverse geocodes it)
                onTap: (tapPosition, point) async {
                  setState(() {
                    _endController.text = 'Đang tìm địa chỉ...';
                  });
                  final String address = await _reverseGeocode(point);
                  setState(() {
                    _endController.text = address;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.demo_maps',
                ),
                PolylineLayer(
                  polylines: _polylines,
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
