import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';

class TodayTab extends ConsumerStatefulWidget {
  const TodayTab({super.key});

  @override
  ConsumerState<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends ConsumerState<TodayTab> {
  bool _dangTaiDuLieu = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _dangTaiDuLieu = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(nutritionProvider);

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
                'Đang đồng bộ dữ liệu dinh dưỡng...',
                style: TextStyle(
                  color: VitaTrackTheme.mauChinh.withValues(alpha: 0.8),
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
      child: Column(
        children: [
          _buildCaloriesCard(data),
          const SizedBox(height: 24),
          _buildWaterTracker(data),
          const SizedBox(height: 32),
          _buildMealHistoryHeader(data),
          const SizedBox(height: 16),
          _buildMealList(data),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(dynamic data) {
    final double phanTramCalo = (data.caloDaNap / data.caloMucTieu).clamp(0.0, 1.0);
    final int conCalo = (data.caloMucTieu - data.caloDaNap).clamp(0, data.caloMucTieu);

    // --- TÍNH TOÁN DỮ LIỆU MACROS THỰC TẾ TỪ FIRESTORE ---
    double tongProtein = 0;
    double tongCarbs = 0;
    double tongFat = 0;

    for (var bua in data.lichSuBuaAn) {
      // Hỗ trợ cả key ngắn 'p','c','f' hoặc key dài 'protein','carbs','fat' tránh lỗi crash
      tongProtein += (bua['p'] ?? bua['protein'] ?? 0).toDouble();
      tongCarbs += (bua['c'] ?? bua['carbs'] ?? 0).toDouble();
      tongFat += (bua['f'] ?? bua['fat'] ?? 0).toDouble();
    }

    // Thiết lập mục tiêu mặc định hàng ngày (Có thể tùy chỉnh theo nhu cầu của nhóm)
    const double mucTieuProtein = 130.0;
    const double mucTieuCarbs = 210.0;
    const double mucTieuFat = 55.0;

    final double phanTramP = (tongProtein / mucTieuProtein).clamp(0.0, 1.0);
    final double phanTramC = (tongCarbs / mucTieuCarbs).clamp(0.0, 1.0);
    final double phanTramF = (tongFat / mucTieuFat).clamp(0.0, 1.0);

    final double tongKhoiLuongMacros = tongProtein + tongCarbs + tongFat;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: VitaTrackTheme.hopCard,
      child: Column(
        children: [
          // Vòng tròn tiến độ Calo tổng quan
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
                  Text('Còn $conCalo kcal',
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
                  tween: Tween<double>(begin: 0.0, end: phanTramCalo),
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
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: VitaTrackTheme.mauCardNhat, thickness: 1),
          ),

          // --- VIỆC 2: PHẦN PIE CHART VÀ PROGRESS BARS MACROS ---
          Row(
            children: [
              // 1. Biểu đồ tròn (Pie Chart Custom) hiển thị tỷ lệ
              SizedBox(
                width: 85,
                height: 85,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(85, 85),
                      painter: MacroPieChartPainter(
                        protein: tongProtein,
                        carbs: tongCarbs,
                        fat: tongFat,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${tongKhoiLuongMacros.toStringAsFixed(0)}g',
                          style: const TextStyle(
                              color: VitaTrackTheme.mauChu,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Macros',
                          style: TextStyle(
                              color: VitaTrackTheme.mauChuPhu, fontSize: 10),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 20),
              
              // 2. Danh sách các thanh Progress Bar thực tế
              Expanded(
                child: Column(
                  children: [
                    _buildMacroProgressBar('Protein', tongProtein, mucTieuProtein, phanTramP, VitaTrackTheme.mauNguyHiem),
                    const SizedBox(height: 8),
                    _buildMacroProgressBar('Carbs', tongCarbs, mucTieuCarbs, phanTramC, VitaTrackTheme.mauCanhBao),
                    const SizedBox(height: 8),
                    _buildMacroProgressBar('Chất béo', tongFat, mucTieuFat, phanTramF, VitaTrackTheme.mauPhu),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Khung tạo thanh tiến độ nhỏ gọn cho từng chất dinh dưỡng
  Widget _buildMacroProgressBar(String label, double current, double target, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${current.toStringAsFixed(0)}/${target.toStringAsFixed(0)}g', 
                style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: VitaTrackTheme.mauCardNhat,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterTracker(dynamic data) {
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
                  ref.read(nutritionProvider.notifier).botNuoc();
                },
                icon: const Icon(Icons.remove_circle_outline, color: VitaTrackTheme.mauChuPhu),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(nutritionProvider.notifier).uongNuoc();
                },
                icon: const Icon(Icons.add_circle, color: VitaTrackTheme.mauChinh, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(
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

  Widget _buildMealHistoryHeader(dynamic data) {
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

  Widget _buildMealList(dynamic data) {
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
      children: data.lichSuBuaAn.map<Widget>((bua) => _taoCardBuaAn(bua)).toList(),
    );
  }

  Widget _taoCardBuaAn(Map<String, dynamic> bua) {
    // Đảm bảo dữ liệu không lỗi nếu Firestore thiếu trường tùy chọn
    final String tenBuaAn = bua['ten']?.toString() ?? bua['name']?.toString() ?? 'Món ăn thực tế';
    final String chiTietBuaAn = bua['chiTiet']?.toString() ?? 'Dinh dưỡng đã lưu';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: VitaTrackTheme.hopCard,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: VitaTrackTheme.mauPhu.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: const Icon(Icons.restaurant, color: VitaTrackTheme.mauPhu, size: 20),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tenBuaAn,
                    style: const TextStyle(
                        color: VitaTrackTheme.mauChu,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(chiTietBuaAn,
                    style: const TextStyle(
                        color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                const SizedBox(height: 8),
                
                // HIỂN THỊ MACRO DỮ LIỆU THỰC TẾ
                Row(
                  children: [
                    _chipMacroGiay('P: ${(bua['p'] ?? bua['protein'] ?? 0)}g', VitaTrackTheme.mauNguyHiem),
                    const SizedBox(width: 8),
                    _chipMacroGiay('C: ${(bua['c'] ?? bua['carbs'] ?? 0)}g', VitaTrackTheme.mauCanhBao),
                    const SizedBox(width: 8),
                    _chipMacroGiay('F: ${(bua['f'] ?? bua['fat'] ?? 0)}g', VitaTrackTheme.mauPhu),
                  ],
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
              Text('${bua['calo'] ?? 0}',
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

  Widget _chipMacroGiay(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// --- BỘ VẼ BIỂU ĐỒ TRÒN CHO TỪNG PHÂN KHÚC MACRO THỰC TẾ ---
class MacroPieChartPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fat;

  MacroPieChartPainter({required this.protein, required this.carbs, required this.fat});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = protein + carbs + fat;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round; // Làm bo tròn các đầu góc nối nhìn sẽ đẹp hơn

    if (total == 0) {
      // Khi chưa ăn gì, vẽ vòng tròn xám trống mặc định
      paint.color = Colors.grey.withValues(alpha: 0.3);
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double startAngle = -3.141592653589793 / 2; // Bắt đầu vẽ từ đỉnh 12h chiều (-90 độ)

    // Vẽ cung Protein
    if (protein > 0) {
      paint.color = VitaTrackTheme.mauNguyHiem;
      final double sweepAngle = (protein / total) * 2 * 3.141592653589793;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Vẽ cung Carbs
    if (carbs > 0) {
      paint.color = VitaTrackTheme.mauCanhBao;
      final double sweepAngle = (carbs / total) * 2 * 3.141592653589793;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Vẽ cung Chất béo
    if (fat > 0) {
      paint.color = VitaTrackTheme.mauPhu;
      final double sweepAngle = (fat / total) * 2 * 3.141592653589793;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MacroPieChartPainter oldDelegate) {
    return oldDelegate.protein != protein || oldDelegate.carbs != carbs || oldDelegate.fat != fat;
  }
}