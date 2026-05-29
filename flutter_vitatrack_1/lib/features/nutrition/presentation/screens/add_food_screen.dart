import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';

// Import các provider và entity mới
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/food_search_provider.dart';
import 'package:flutter_vitatrack_1/features/nutrition/domain/entities/food_entity.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
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

  @override
  Widget build(BuildContext context) {
    // Theo dõi danh sách kết quả từ API
    final apiResults = ref.watch(foodSearchProvider);
    final searchNotifier = ref.read(foodSearchProvider.notifier);

    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      appBar: AppBar(
        backgroundColor: VitaTrackTheme.mauCard,
        title: const Text('Thêm bữa ăn',
            style: TextStyle(
                color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: VitaTrackTheme.mauChu),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) {
                setState(() => _query = v);
                // Gọi API tìm kiếm mỗi khi người dùng nhập
                searchNotifier.timKiem(v);
              },
              style: const TextStyle(color: VitaTrackTheme.mauChu),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn (ví dụ: pho, milk...)',
                hintStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                prefixIcon: const Icon(Icons.search, color: VitaTrackTheme.mauChinh),
                fillColor: VitaTrackTheme.mauCard,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),
          ),

          // Nút nhận diện AI
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
                  border: Border.all(
                      color: VitaTrackTheme.mauChinh.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.camera_alt_rounded,
                        color: VitaTrackTheme.mauChinh, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chụp ảnh nhận diện AI',
                              style: TextStyle(
                                  color: VitaTrackTheme.mauChu,
                                  fontWeight: FontWeight.bold)),
                          Text('Tự động tính calo từ ảnh món ăn',
                              style: TextStyle(
                                  color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: VitaTrackTheme.mauChinh, size: 14),
                  ],
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Kết quả tìm kiếm',
                  style: TextStyle(
                      color: VitaTrackTheme.mauChu,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),

          // Danh sách kết quả từ API
          Expanded(
            child: apiResults.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty ? 'Nhập tên món ăn để tìm kiếm' : 'Không tìm thấy kết quả',
                      style: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                    ),
                  )
                : ListView.builder(
                    itemCount: apiResults.length,
                    itemBuilder: (context, index) {
                      final item = apiResults[index];
                      return _foodCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị món ăn đã được sửa để nhận FoodEntity
  Widget _foodCard(FoodEntity item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          // Ảnh từ API hoặc icon mặc định
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: VitaTrackTheme.mauChinh.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              image: item.hinhAnh != null
                  ? DecorationImage(
                      image: NetworkImage(item.hinhAnh!), fit: BoxFit.cover)
                  : null,
            ),
            child: item.hinhAnh == null
                ? const Icon(Icons.restaurant_rounded,
                    color: VitaTrackTheme.mauChinh, size: 20)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.tenMonAn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: VitaTrackTheme.mauChu,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                    'P: ${item.protein}g · C: ${item.carbs}g · F: ${item.fat}g',
                    style: const TextStyle(
                        color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.calo}',
                  style: const TextStyle(
                      color: VitaTrackTheme.mauChinh,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const Text('kcal/100g',
                  style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Lưu vào Firestore thông qua nutritionProvider
              ref.read(nutritionProvider.notifier).themMonAn(
                    item.calo,
                    item.protein,
                    item.carbs,
                    item.fat,
                  );
              
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Đã thêm ${item.tenMonAn}!'),
                backgroundColor: VitaTrackTheme.mauThanhCong,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: VitaTrackTheme.mauThanhCong, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _AiCameraSheet giữ nguyên như logic cũ của bạn
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
      decoration: BoxDecoration(
          color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(20)),
      child: _step == 0 ? _buildLoading() : _buildResult(context),
    );
  }

  Widget _buildLoading() => Column(mainAxisSize: MainAxisSize.min, children: const [
        SizedBox(height: 12),
        CircularProgressIndicator(color: VitaTrackTheme.mauChinh, strokeWidth: 3),
        SizedBox(height: 18),
        Text('AI đang phân tích món ăn...',
            style: TextStyle(
                color: VitaTrackTheme.mauChu,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Nhận diện thành phần dinh dưỡng',
            style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
        SizedBox(height: 18),
      ]);

  Widget _buildResult(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check_circle_rounded,
          color: VitaTrackTheme.mauThanhCong, size: 48),
      const SizedBox(height: 12),
      const Text('Đã nhận diện: Cơm Tấm Sườn',
          style: TextStyle(
              color: VitaTrackTheme.mauChu,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
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
          style: ElevatedButton.styleFrom(
              backgroundColor: VitaTrackTheme.mauChinh,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(nutritionProvider.notifier).themMonAn(600, 25, 70, 20);
            Navigator.pop(context);
          },
          child: const Text('Thêm vào nhật ký',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ),
    ]);
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}