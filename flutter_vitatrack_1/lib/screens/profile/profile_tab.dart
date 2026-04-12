import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        // THÔNG TIN CƠ THỂ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Thông tin cơ thể', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Chỉnh sửa', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _taoCardThongTin('Chiều cao', '165 cm', null)),
            const SizedBox(width: 16),
            Expanded(child: _taoCardThongTin('Cân nặng', '58 kg', null)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _taoCardThongTin('BMI', '21.3', 'Bình thường')),
            const SizedBox(width: 16),
            Expanded(child: _taoCardThongTin('Tuổi', '25', null)),
          ],
        ),
        const SizedBox(height: 32),

        // MỤC TIÊU
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mục tiêu', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Thay đổi', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Column(
            children: [
              _taoTienDoMucTieu('Cân nặng mục tiêu', '55 kg', 0.6),
              const SizedBox(height: 24),
              _taoTienDoMucTieu('Bước/ngày', '10,000', 0.85),
              const SizedBox(height: 24),
              _taoTienDoMucTieu('Calories/ngày', '2,200 kcal', 0.65),
            ],
          ),
        ),
      ],
    );
  }

  Widget _taoCardThongTin(String tieuDe, String giaTri, String? badgeText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocVua)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tieuDe, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(giaTri, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: VitaTrackTheme.mauThanhCong.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(badgeText, style: const TextStyle(color: VitaTrackTheme.mauThanhCong, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _taoTienDoMucTieu(String tieuDe, String giaTri, double tiLe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tieuDe, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 14)),
            Text(giaTri, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: tiLe,
          backgroundColor: VitaTrackTheme.mauCardNhat,
          color: VitaTrackTheme.mauChinh,
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}