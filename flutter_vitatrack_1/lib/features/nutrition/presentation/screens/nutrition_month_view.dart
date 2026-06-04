import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';

class NutritionMonthView extends ConsumerWidget {
  const NutritionMonthView({super.key});

  void _hienThiChiTietNgay(BuildContext context, Map<String, dynamic> day, int caloMucTieu) {
    final calo = day['calo'] as int? ?? 0;
    final protein = (day['protein'] as num?)?.toDouble() ?? 0.0;
    final dateStr = day['date'] as String;
    final parts = dateStr.split('-');
    final dayNum = int.parse(parts[2]);
    final monthNum = int.parse(parts[1]);

    showModalBottomSheet(
      context: context,
      backgroundColor: VitaTrackTheme.mauCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chi tiết ngày $dayNum tháng $monthNum', 
                style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              if (calo == 0)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Text('Ngày này chưa có dữ liệu', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 16)),
                  ),
                )
              else ...[
                _dongChiTiet('Calories tiêu thụ', '$calo kcal', VitaTrackTheme.mauChinh),
                _dongChiTiet('Protein đã nạp', '${protein.toStringAsFixed(1)}g', VitaTrackTheme.mauNguyHiem),
                _dongChiTiet('Trạng thái', 
                  calo >= caloMucTieu * 0.8 ? 'Đạt mục tiêu ✓' : 'Chưa đạt mục tiêu', 
                  calo >= caloMucTieu * 0.8 ? VitaTrackTheme.mauThanhCong : VitaTrackTheme.mauCanhBao
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _dongChiTiet(String nhan, String giaTri, Color mau) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nhan, style: const TextStyle(color: VitaTrackTheme.mauChuPhu)),
          Text(giaTri, style: TextStyle(color: mau, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthDataAsync = ref.watch(monthNutritionProvider);
    final todayData = ref.watch(nutritionProvider);
    final now = DateTime.now();

    return monthDataAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: VitaTrackTheme.mauChinh),
        ),
      ),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text('Không thể tải dữ liệu tháng: $e', style: const TextStyle(color: VitaTrackTheme.mauNguyHiem)),
        ),
      ),
      data: (monthData) {
        if (monthData.isEmpty) {
          return const Center(child: Text('Không có dữ liệu', style: TextStyle(color: VitaTrackTheme.mauChuPhu)));
        }

        int daysLogged = 0;
        int totalCalo = 0;
        int maxCalo = -1;
        String bestDate = '--';
        final caloMucTieu = todayData.caloMucTieu > 0 ? todayData.caloMucTieu : 2000;

        for (final day in monthData) {
          final cal = day['calo'] as int? ?? 0;
          if (cal > 0) {
            daysLogged++;
            totalCalo += cal;
            if (cal > maxCalo) {
              maxCalo = cal;
              final parts = (day['date'] as String).split('-');
              bestDate = '${parts[2]}/${parts[1]}';
            }
          }
        }

        final avgCalo = daysLogged > 0 ? (totalCalo / daysLogged).round() : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dinh dưỡng', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Tháng ${now.month}, ${now.year}', style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Month Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Số ngày ghi', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('$daysLogged ngày', style: const TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tốt nhất', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(bestDate, style: const TextStyle(color: VitaTrackTheme.mauThanhCong, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TB/Ngày', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('$avgCalo kcal', style: const TextStyle(color: VitaTrackTheme.mauPhu, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('Chuỗi ngày ghi nhận', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: monthData.map((day) {
                  final calo = day['calo'] as int? ?? 0;
                  final dateStr = day['date'] as String;
                  final dayNum = int.parse(dateStr.split('-')[2]);
                  
                  Color color;
                  if (calo == 0) {
                    color = VitaTrackTheme.mauCardNhat;
                  } else if (calo >= caloMucTieu * 0.8) {
                    color = VitaTrackTheme.mauThanhCong;
                  } else {
                    color = VitaTrackTheme.mauCanhBao;
                  }
                  
                  return InkWell(
                    onTap: () => _hienThiChiTietNgay(context, day, caloMucTieu),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Text('$dayNum', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500))
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
