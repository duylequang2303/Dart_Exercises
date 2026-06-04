import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';


class WeekTab extends ConsumerWidget {
  const WeekTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekDataAsync = ref.watch(weekNutritionProvider);
    final todayData = ref.watch(nutritionProvider);

    return weekDataAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: VitaTrackTheme.mauChinh),
        ),
      ),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text('Không thể tải dữ liệu tuần: $e', style: const TextStyle(color: VitaTrackTheme.mauNguyHiem)),
        ),
      ),
      data: (weekData) {
        if (weekData.isEmpty) {
          return const Center(child: Text('Không có dữ liệu', style: TextStyle(color: VitaTrackTheme.mauChuPhu)));
        }

        int totalCalo = 0;
        int nonZeroDays = 0;
        int maxCal = todayData.caloMucTieu > 0 ? todayData.caloMucTieu : 2000;
        
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;

        for (final day in weekData) {
          final calo = day['calo'] as int? ?? 0;
          totalCalo += calo;
          if (calo > 0) nonZeroDays++;
          if (calo > maxCal) maxCal = calo;

          totalProtein += (day['protein'] as num?)?.toDouble() ?? 0;
          totalCarbs += (day['carbs'] as num?)?.toDouble() ?? 0;
          totalFat += (day['fat'] as num?)?.toDouble() ?? 0;
        }

        final avgCalo = nonZeroDays > 0 ? (totalCalo / nonZeroDays).round() : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dinh dưỡng', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
            const SizedBox(height: 4),
            const Text('Tuần này', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _taoTheThongKeNhanh('Trung bình / ngày', '$avgCalo kcal', VitaTrackTheme.mauChinh)),
                const SizedBox(width: 16),
                Expanded(child: _taoTheThongKeNhanh('Tổng tuần', '$totalCalo kcal', VitaTrackTheme.mauPhu)),
              ],
            ),
            const SizedBox(height: 32),

            const Text('Calories tiêu thụ', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: VitaTrackTheme.mauCard,
                borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weekData.map((day) {
                        final calo = day['calo'] as int? ?? 0;
                        final dateStr = day['date'] as String;
                        final parts = dateStr.split('-');
                        final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                        
                        final thu = _mapWeekday(date.weekday);
                        
                        final now = DateTime.now();
                        final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                        
                        // height range 0..150 max
                        final height = calo == 0 ? 10.0 : (calo / maxCal) * 150.0;
                        
                        return _taoCotGia(height, thu, isToday, calo);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Macro tổng tuần', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: VitaTrackTheme.mauCard,
                borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _macroItem('Protein', totalProtein, VitaTrackTheme.mauNguyHiem),
                  _macroItem('Carbs', totalCarbs, VitaTrackTheme.mauCanhBao),
                  _macroItem('Chất béo', totalFat, VitaTrackTheme.mauPhu),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _mapWeekday(int w) {
    switch (w) {
      case 1: return 'T2';
      case 2: return 'T3';
      case 3: return 'T4';
      case 4: return 'T5';
      case 5: return 'T6';
      case 6: return 'T7';
      case 7: return 'CN';
      default: return '';
    }
  }

  Widget _macroItem(String label, double val, Color color) {
    return Column(
      children: [
        Text('${val.toStringAsFixed(0)}g', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
      ],
    );
  }

  Widget _taoCotGia(double chieuCao, String thu, bool dangChon, int calo) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (calo > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              calo.toString(),
              style: TextStyle(
                color: dangChon ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChuPhu,
                fontSize: 10,
                fontWeight: dangChon ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: chieuCao),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Container(
              width: 28,
              height: value,
              decoration: BoxDecoration(
                color: calo == 0 
                    ? VitaTrackTheme.mauCardNhat 
                    : (dangChon ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauPhu.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          thu,
          style: TextStyle(
            color: dangChon ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChuPhu,
            fontSize: 12,
            fontWeight: dangChon ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _taoTheThongKeNhanh(String tieuDe, String giaTri, Color mauSac) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard,
        borderRadius: BorderRadius.circular(VitaTrackTheme.boGocVua),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tieuDe, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
          const SizedBox(height: 8),
          Text(giaTri, style: TextStyle(color: mauSac, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
