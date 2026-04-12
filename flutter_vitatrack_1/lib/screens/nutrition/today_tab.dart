import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../services/mock_data_service.dart';

class TodayTab extends StatefulWidget {
  const TodayTab({super.key});

  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  final data = MockDataService.instance;
  bool _dangTaiDuLieu = true;

  @override
  void initState() {
    super.initState();
    // KỊCH BẢN FAKE LOADING
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _dangTaiDuLieu = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Màn hình loading giả
    if (_dangTaiDuLieu) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: VitaTrackTheme.mauChinh,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Đang đồng bộ dữ liệu HealthKit...',
                style: TextStyle(
                  color: VitaTrackTheme.mauChinh.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng đợi trong giây lát',
                style: TextStyle(
                  color: VitaTrackTheme.mauChuPhu,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Load xong -> Fade in
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, opacityValue, child) {
        return Opacity(
          opacity: opacityValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacityValue)),
            child: child,
          ),
        );
      },
      child: ListenableBuilder(
        listenable: data,
        builder: (context, child) {
          return Column(
            children: [
              _buildCaloriesCard(),
              const SizedBox(height: 24),
              _buildWaterTracker(),
              const SizedBox(height: 32),
              _buildMealHistoryHeader(),
              const SizedBox(height: 16),
              _buildMealList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCaloriesCard() {
    final double phanTram = (data.caloDaNap / data.caloMucTieu).clamp(0.0, 1.0);
    final int con = (data.caloMucTieu - data.caloDaNap).clamp(0, data.caloMucTieu);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: VitaTrackTheme.hopCard,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calo hôm nay',
                      style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${data.caloDaNap}',
                          style: const TextStyle(
                              color: VitaTrackTheme.mauChu,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' / ${data.caloMucTieu} kcal',
                          style: const TextStyle(
                              color: VitaTrackTheme.mauChuPhu, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Còn $con kcal',
                      style: const TextStyle(
                          color: VitaTrackTheme.mauThanhCong,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(
                width: 70,
                height: 70,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: phanTram),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: value,
                          backgroundColor: VitaTrackTheme.mauCardNhat,
                          color: VitaTrackTheme.mauChinh,
                          strokeWidth: 7,
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Text(
                            '${(value * 100).toInt()}%',
                            style: const TextStyle(
                                color: VitaTrackTheme.mauChu,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniMacro('Protein', '85g', VitaTrackTheme.mauNguyHiem),
              _miniMacro('Carbs', '210g', VitaTrackTheme.mauCanhBao),
              _miniMacro('Chất béo', '55g', VitaTrackTheme.mauPhu),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMacro(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
      ],
    );
  }

  Widget _buildWaterTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: VitaTrackTheme.hopCard,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: VitaTrackTheme.mauChinh),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nước uống (${(data.soLyNuoc * 0.25).toStringAsFixed(1)}L / 2.5L)',
                  style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  data.botNuoc();
                },
                icon: const Icon(Icons.remove_circle_outline, color: VitaTrackTheme.mauChuPhu),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  data.uongNuoc();
                },
                icon: const Icon(Icons.add_circle, color: VitaTrackTheme.mauChinh, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              10,
              (i) => TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: i < data.soLyNuoc ? scale : 1.0,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: i < data.soLyNuoc
                            ? VitaTrackTheme.mauChinh
                            : VitaTrackTheme.mauCardNhat,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Nhật ký bữa ăn',
            style: TextStyle(
                color: VitaTrackTheme.mauChu,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text('${data.lichSuBuaAn.length} bữa',
            style: const TextStyle(
                color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
      ],
    );
  }

  Widget _buildMealList() {
    if (data.lichSuBuaAn.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('Chưa có bữa ăn nào.\nBấm + để thêm!',
              textAlign: TextAlign.center,
              style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
        ),
      );
    }
    return Column(
      children: data.lichSuBuaAn.map((bua) => _taoCardBuaAn(bua)).toList(),
    );
  }

  // ĐÃ NÂNG CẤP: Thêm UI hiển thị Macros, Nút Sửa/Xóa giả
  Widget _taoCardBuaAn(Map<String, dynamic> bua) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: VitaTrackTheme.hopCard,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Món ăn
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: VitaTrackTheme.mauPhu.withOpacity(0.15),
                shape: BoxShape.circle),
            child: Icon(bua['icon'] as IconData, color: VitaTrackTheme.mauPhu, size: 20),
          ),
          const SizedBox(width: 16),
          
          // Chi tiết món ăn + Thông số Macro
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bua['ten'] as String,
                    style: const TextStyle(
                        color: VitaTrackTheme.mauChu,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(bua['chiTiet'] as String,
                    style: const TextStyle(
                        color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                const SizedBox(height: 8),
                
                // Thanh hiển thị Macro (Giả lập số liệu nhìn cho ngầu)
                Row(
                  children: [
                    _chipMacroGiay('P: 25g', VitaTrackTheme.mauNguyHiem),
                    const SizedBox(width: 8),
                    _chipMacroGiay('C: 40g', VitaTrackTheme.mauCanhBao),
                    const SizedBox(width: 8),
                    _chipMacroGiay('F: 12g', VitaTrackTheme.mauChinh),
                  ],
                ),
              ],
            ),
          ),
          
          // Cột Calo + Nút Menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Nút 3 chấm giả lập Menu Xóa/Sửa
              SizedBox(
                height: 24,
                width: 24,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: VitaTrackTheme.mauChuPhu, size: 20),
                  color: VitaTrackTheme.mauCardNhat,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'delete') {
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Đã xóa món ăn thành công!'),
                          backgroundColor: VitaTrackTheme.mauThanhCong,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: VitaTrackTheme.mauChu, size: 18),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 14)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: VitaTrackTheme.mauNguyHiem, size: 18),
                          SizedBox(width: 8),
                          Text('Xóa món', style: TextStyle(color: VitaTrackTheme.mauNguyHiem, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('${bua['calo']}',
                  style: const TextStyle(
                      color: VitaTrackTheme.mauChinh,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Text('kcal',
                  style: TextStyle(
                      color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // Nút thông số nhỏ gọn trong card Món ăn
  Widget _chipMacroGiay(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}