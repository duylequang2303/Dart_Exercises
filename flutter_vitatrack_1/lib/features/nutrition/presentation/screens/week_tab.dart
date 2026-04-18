import 'package:flutter/material.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';


class WeekTab extends StatelessWidget {
  const WeekTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dinh dưỡng', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
        const SizedBox(height: 4),
        const Text('Tuần này', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        // Hàng chứa 2 thẻ thông số nhanh
        Row(
          children: [
            Expanded(child: _taoTheThongKeNhanh('Trung bình / ngày', '1845 kcal', VitaTrackTheme.mauChinh)),
            const SizedBox(width: 16),
            Expanded(child: _taoTheThongKeNhanh('Tổng tuần', '12,915 kcal', VitaTrackTheme.mauPhu)),
          ],
        ),
        const SizedBox(height: 32),

        // BIỂU ĐỒ CỘT - ĐÃ BƠM ANIMATION "NẢY LÒ XO"
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
                  children: [
                    _taoCotGia(60, 'T2'),
                    _taoCotGia(85, 'T3'),
                    _taoCotGia(110, 'T4'),
                    _taoCotGia(75, 'T5'),
                    _taoCotGia(130, 'T6', dangChon: true), // Cột ngày hôm nay nổi bật
                    _taoCotGia(90, 'T7'),
                    _taoCotGia(40, 'CN'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Hàm vẽ từng cột đơn lẻ cho biểu đồ - NÂNG CẤP ANIMATION
  Widget _taoCotGia(double chieuCao, String thu, {bool dangChon = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: chieuCao),
          duration: const Duration(milliseconds: 1000), // Mất 1 giây để mọc lên
          curve: Curves.easeOutBack, // Hiệu ứng nảy lò xo siêu mượt
          builder: (context, value, child) {
            return Container(
              width: 28,
              height: value, // Chiều cao nội suy từ 0 đến chieuCao
              decoration: BoxDecoration(
                color: dangChon ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauPhu.withValues(alpha: 0.4),
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

  // Hàm vẽ thẻ thông số (như Trung bình ngày, Tổng tuần)
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
