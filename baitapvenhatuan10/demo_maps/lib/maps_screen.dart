import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// Fixed destination: Hồ Hoàn Kiếm, Hà Nội
const LatLng _destination = LatLng(21.0285, 105.8542);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];

  LatLng? _currentPosition;
  bool _isLoadingDirections = false;

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ─── Location ────────────────────────────────────────────────────────────

  Future<void> _initLocation() async {
    // 1. Check / request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Quyền truy cập vị trí bị từ chối.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
        'Quyền truy cập vị trí bị từ chối vĩnh viễn. '
        'Vui lòng bật trong Cài đặt.',
      );
      return;
    }

    // 2. Check location service
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Dịch vụ vị trí bị tắt. Vui lòng bật GPS.');
      return;
    }

    // 3. Get GPS position
    try {
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng latLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _currentPosition = latLng;
        _markers.clear();
        _markers.add(
          Marker(
            point: latLng,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 30,
            ),
          ),
        );
        // Also add destination marker
        _markers.add(
          Marker(
            point: _destination,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      });

      // 4. Move camera to current position
      _mapController.move(latLng, 15);
    } catch (e) {
      _showSnackBar('Không thể lấy vị trí: $e');
    }
  }

  // ─── Directions API ──────────────────────────────────────────────────────

  Future<void> _getDirections() async {
    if (_currentPosition == null) {
      _showSnackBar('Chưa xác định được vị trí hiện tại.');
      return;
    }

    setState(() => _isLoadingDirections = true);

    // OSRM expects coordinates in lng,lat;lng,lat format
    final Uri url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${_currentPosition!.longitude},${_currentPosition!.latitude};'
      '${_destination.longitude},${_destination.latitude}'
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
        _showSnackBar('OSRM API trả về lỗi: $code');
        return;
      }

      final List<dynamic> coords =
          data['routes'][0]['geometry']['coordinates'] as List<dynamic>;

      final List<LatLng> points = coords.map((c) {
        final List<dynamic> point = c as List<dynamic>;
        return LatLng(point[1] as double, point[0] as double);
      }).toList();

      // Fit camera to show the full route
      final LatLngBounds bounds = _boundsFromLatLngList([
        _currentPosition!,
        _destination,
        ...points,
      ]);

      setState(() {
        _polylines
          ..clear()
          ..add(
            Polyline(
              points: points,
              color: Colors.blue,
              strokeWidth: 5,
            ),
          );
      });

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
      setState(() => _isLoadingDirections = false);
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

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(21.0278, 105.8342),
              initialZoom: 13,
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

          // Loading overlay while fetching directions
          if (_isLoadingDirections)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 12),
                      Text('Đang tìm đường...'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // Floating action button – "Tìm đường đi"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoadingDirections ? null : _getDirections,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: _isLoadingDirections
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.directions),
        label: const Text('Tìm đường đi'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
