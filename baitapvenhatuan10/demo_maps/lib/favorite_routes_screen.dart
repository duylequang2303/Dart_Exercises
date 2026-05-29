import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteRoutesScreen extends StatefulWidget {
  const FavoriteRoutesScreen({super.key});

  @override
  State<FavoriteRoutesScreen> createState() => _FavoriteRoutesScreenState();
}

class _FavoriteRoutesScreenState extends State<FavoriteRoutesScreen> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? rawData = prefs.getString('favorite_routes');
      if (rawData != null) {
        final List<dynamic> decoded = jsonDecode(rawData) as List<dynamic>;
        setState(() {
          _favorites = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải danh sách yêu thích: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFavorite(int index) async {
    final Map<String, dynamic> removedItem = _favorites[index];
    setState(() {
      _favorites.removeAt(index);
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('favorite_routes', jsonEncode(_favorites));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã xóa khỏi danh sách yêu thích'),
            action: SnackBarAction(
              label: 'Hoàn tác',
              onPressed: () async {
                setState(() {
                  _favorites.insert(index, removedItem);
                });
                await prefs.setString('favorite_routes', jsonEncode(_favorites));
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa yêu thích: $e');
    }
  }

  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'foot':
        return Icons.directions_walk;
      case 'bicycle':
        return Icons.directions_bike; // Represents bike/motorcycle
      case 'driving':
      default:
        return Icons.directions_car;
    }
  }

  String _getModeText(String mode) {
    switch (mode) {
      case 'foot':
        return 'Đi bộ';
      case 'bicycle':
        return 'Xe máy';
      case 'driving':
      default:
        return 'Xe hơi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tuyến đường yêu thích'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có tuyến đường yêu thích nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vui lòng tìm đường và lưu lại',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final item = _favorites[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.05),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Return selected favorite route data to main screen
                          Navigator.pop(context, item);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Route endpoints row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.trip_origin, size: 20, color: Colors.green),
                                      Container(
                                        width: 2,
                                        height: 30,
                                        color: Colors.grey.shade300,
                                      ),
                                      const Icon(Icons.location_on, size: 20, color: Colors.red),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['startName'] ?? 'Điểm bắt đầu',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 22),
                                        Text(
                                          item['endName'] ?? 'Điểm kết thúc',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Delete button
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                    onPressed: () => _deleteFavorite(index),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              // Metadata & details row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Mode badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getModeIcon(item['mode'] ?? 'driving'),
                                          size: 16,
                                          color: Colors.blue.shade800,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getModeText(item['mode'] ?? 'driving'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Distance & Duration
                                  Row(
                                    children: [
                                      const Icon(Icons.straighten, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['distance'] ?? '',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['duration'] ?? '',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
