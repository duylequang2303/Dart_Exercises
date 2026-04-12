import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PlanTab extends StatelessWidget {
  const PlanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kế hoạch hôm nay', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _taoMucChecklist('Uống 2L nước', true),
              const SizedBox(height: 16),
              _taoMucChecklist('Đi bộ 10,000 bước', false),
              const SizedBox(height: 16),
              _taoMucChecklist('Tập yoga 20 phút', true),
              const SizedBox(height: 16),
              _taoMucChecklist('Ngủ trước 23h', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mục tiêu tuần', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _taoTienDo('Giảm 0.5kg', '60%', 0.6, VitaTrackTheme.mauChinh),
              const SizedBox(height: 20),
              _taoTienDo('Tập 5 ngày/tuần', '80%', 0.8, VitaTrackTheme.mauThanhCong),
            ],
          ),
        ),
      ],
    );
  }

  Widget _taoMucChecklist(String text, bool isChecked) {
    return Row(
      children: [
        Icon(isChecked ? Icons.check_circle : Icons.radio_button_unchecked, color: isChecked ? VitaTrackTheme.mauThanhCong : VitaTrackTheme.mauChuPhu, size: 24),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: isChecked ? VitaTrackTheme.mauChuPhu : VitaTrackTheme.mauChu, decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none)),
      ],
    );
  }

  Widget _taoTienDo(String tieuDe, String phanTram, double tiLe, Color mauSac) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(tieuDe, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 12)),
          Text(phanTram, style: TextStyle(color: mauSac, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: tiLe, backgroundColor: VitaTrackTheme.mauCardNhat, color: mauSac, minHeight: 8, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }
}