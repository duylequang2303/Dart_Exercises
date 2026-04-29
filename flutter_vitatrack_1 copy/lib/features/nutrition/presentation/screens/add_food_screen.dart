import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';

import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  static const List<Map<String, dynamic>> _suggestions = [
    {"name": "Phở Bò", "cal": 450, "p": 20, "c": 50, "f": 15},
    {"name": "Cơm Tấm Sườn", "cal": 600, "p": 25, "c": 70, "f": 20},
    {"name": "Ức Gà (100g)", "cal": 165, "p": 31, "c": 0, "f": 4},
    {"name": "Salad Ức Gà", "cal": 320, "p": 25, "c": 15, "f": 10},
    {"name": "Sữa Tươi (200ml)", "cal": 120, "p": 7, "c": 10, "f": 5},
    {"name": "Bánh Mì Trứng", "cal": 380, "p": 15, "c": 45, "f": 14},
    {"name": "Chuối (1 quả)", "cal": 89, "p": 1, "c": 23, "f": 0},
  ];

  String _query = '';

  void _openAiCamera() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AiCameraSheet(),
    );
  }

  List<Map<String, dynamic>> get _filtered => _query.isEmpty
      ? _suggestions
      : _suggestions.where((s) => (s['name'] as String).toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      appBar: AppBar(
        backgroundColor: VitaTrackTheme.mauCard,
        title: const Text('Thêm bữa ăn', style: TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: VitaTrackTheme.mauChu),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: VitaTrackTheme.mauChu),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                hintStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                prefixIcon: const Icon(Icons.search, color: VitaTrackTheme.mauChinh),
                fillColor: VitaTrackTheme.mauCard,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GestureDetector(
              onTap: _openAiCamera,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    VitaTrackTheme.mauChinh.withValues(alpha: 0.15),
                    VitaTrackTheme.mauPhu.withValues(alpha: 0.15),
                  ]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.camera_alt_rounded, color: VitaTrackTheme.mauChinh, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chụp ảnh nhận diện AI', style: TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
                          Text('Tự động tính calo từ ảnh món ăn', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: VitaTrackTheme.mauChinh, size: 14),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildSectionMetric('Ước tính', '600 kcal', VitaTrackTheme.mauChinh)),
                const SizedBox(width: 12),
                Expanded(child: _buildSectionMetric('Protein', '25g', VitaTrackTheme.mauNguyHiem)),
                const SizedBox(width: 12),
                Expanded(child: _buildSectionMetric('Carbs', '70g', VitaTrackTheme.mauCanhBao)),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Gợi ý phổ biến', style: TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final item = _filtered[index];
                return _foodCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.restaurant_rounded, color: VitaTrackTheme.mauChinh, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] as String, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('P: ${item['p']}g · C: ${item['c']}g · F: ${item['f']}g', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item['cal']}', style: const TextStyle(color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('kcal', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(nutritionProvider.notifier).themMonAn(
                item['cal'] as int,
                (item['p'] as num).toDouble(),
                (item['c'] as num).toDouble(),
                (item['f'] as num).toDouble(),
              );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Đã thêm ${item['name']}!'),
                backgroundColor: VitaTrackTheme.mauThanhCong,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: VitaTrackTheme.mauThanhCong, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // Example helper used for consistent metric display if needed elsewhere
  Widget _buildSectionMetric(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
          child: Text(value, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _AiCameraSheet extends ConsumerStatefulWidget {
  const _AiCameraSheet();

  @override
  ConsumerState<_AiCameraSheet> createState() => _AiCameraSheetState();
}

class _AiCameraSheetState extends ConsumerState<_AiCameraSheet> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _step = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(20)),
      child: _step == 0 ? _buildLoading() : _buildResult(context),
    );
  }

  Widget _buildLoading() => Column(mainAxisSize: MainAxisSize.min, children: const [
        SizedBox(height: 12),
        CircularProgressIndicator(color: VitaTrackTheme.mauChinh, strokeWidth: 3),
        SizedBox(height: 18),
        Text('AI đang phân tích món ăn...', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Nhận diện thành phần dinh dưỡng', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
        SizedBox(height: 18),
      ]);

  Widget _buildResult(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check_circle_rounded, color: VitaTrackTheme.mauThanhCong, size: 48),
      const SizedBox(height: 12),
      const Text('Đã nhận diện: Cơm Tấm Sườn', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _macroChip('600 kcal', VitaTrackTheme.mauChinh),
        _macroChip('P: 25g', VitaTrackTheme.mauNguyHiem),
        _macroChip('C: 70g', VitaTrackTheme.mauCanhBao),
        _macroChip('F: 20g', VitaTrackTheme.mauPhu),
      ]),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: VitaTrackTheme.mauChinh, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Use provider to add the detected meal
            ref.read(nutritionProvider.notifier).themMonAn(600, 25, 70, 20);
            Navigator.pop(context);
          },
          child: const Text('Thêm vào nhật ký', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    ]);
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
