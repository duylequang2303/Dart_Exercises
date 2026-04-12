import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../services/mock_data_service.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});
  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final List<Map<String, dynamic>> _danhSachMonAn = [
    {"ten": "Phở Bò", "calo": 450, "p": 20, "c": 50, "f": 15},
    {"ten": "Cơm Tấm Sườn", "calo": 600, "p": 25, "c": 70, "f": 20},
    {"ten": "Ức Gà (100g)", "calo": 165, "p": 31, "c": 0, "f": 4},
    {"ten": "Salad Ức Gà", "calo": 320, "p": 25, "c": 15, "f": 10},
    {"ten": "Sữa Tươi (200ml)", "calo": 120, "p": 7, "c": 10, "f": 5},
    {"ten": "Bánh Mì Trứng", "calo": 380, "p": 15, "c": 45, "f": 14},
    {"ten": "Chuối (1 quả)", "calo": 89, "p": 1, "c": 23, "f": 0},
  ];

  void _moGiaLapCamera(BuildContext context) async {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _CameraAiSheet(),
    );
  }

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
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: VitaTrackTheme.mauChu),
              decoration: InputDecoration(
                hintText: "Tìm kiếm món ăn...",
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

          // NÚT CAMERA AI — đây là tính năng ăn điểm nhất
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GestureDetector(
              onTap: () => _moGiaLapCamera(context),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      VitaTrackTheme.mauChinh.withOpacity(0.15),
                      VitaTrackTheme.mauPhu.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VitaTrackTheme.mauChinh.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, color: VitaTrackTheme.mauChinh, size: 22),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chụp ảnh nhận diện AI',
                            style: TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
                        Text('Tự động tính calo từ ảnh món ăn',
                            style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, color: VitaTrackTheme.mauChinh, size: 14),
                  ],
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Gợi ý phổ biến',
                  style: TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _danhSachMonAn.length,
              itemBuilder: (context, index) {
                final mon = _danhSachMonAn[index];
                return _cardMonAn(context, mon);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardMonAn(BuildContext context, Map<String, dynamic> mon) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: VitaTrackTheme.mauChinh.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_rounded, color: VitaTrackTheme.mauChinh, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mon['ten'] as String,
                    style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('P: ${mon['p']}g · C: ${mon['c']}g · F: ${mon['f']}g',
                    style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${mon['calo']}',
                  style: const TextStyle(color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('kcal', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              MockDataService.instance.themMonAn(
                  mon['calo'] as int,
                  (mon['p'] as int).toDouble(),
                  (mon['c'] as int).toDouble(),
                  (mon['f'] as int).toDouble());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Đã thêm ${mon['ten']}!'),
                backgroundColor: VitaTrackTheme.mauThanhCong,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: VitaTrackTheme.mauThanhCong,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// CAMERA AI GIẢ — đây là màn ăn điểm
class _CameraAiSheet extends StatefulWidget {
  const _CameraAiSheet();
  @override
  State<_CameraAiSheet> createState() => _CameraAiSheetState();
}

class _CameraAiSheetState extends State<_CameraAiSheet> {
  int _buoc = 0; // 0=loading, 1=kết quả

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _buoc = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: _buoc == 0 ? _buildLoading() : _buildKetQua(context),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const CircularProgressIndicator(color: VitaTrackTheme.mauChinh, strokeWidth: 3),
        const SizedBox(height: 24),
        const Text('AI đang phân tích món ăn...',
            style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Nhận diện thành phần dinh dưỡng',
            style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildKetQua(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: VitaTrackTheme.mauThanhCong, size: 48),
        const SizedBox(height: 16),
        const Text('Đã nhận diện: Cơm Tấm Sườn',
            style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _macroChip('600 kcal', VitaTrackTheme.mauChinh),
            _macroChip('P: 25g', VitaTrackTheme.mauNguyHiem),
            _macroChip('C: 70g', VitaTrackTheme.mauCanhBao),
            _macroChip('F: 20g', VitaTrackTheme.mauPhu),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VitaTrackTheme.mauChinh,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              MockDataService.instance.themMonAn(600, 25, 70, 20);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Thêm vào nhật ký',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}