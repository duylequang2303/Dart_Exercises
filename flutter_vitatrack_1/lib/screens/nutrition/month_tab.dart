import 'package:flutter/material.dart';
import '../../core/theme.dart';

class MonthTab extends StatelessWidget {
  const MonthTab({super.key});

  // Hàm này tự tạo ra giao diện chi tiết ngay tại chỗ, không cần file mới
  void _hienThiChiTietNgay(BuildContext context, int ngay) {
    showModalBottomSheet(
      context: context,
      backgroundColor: VitaTrackTheme.mauCard,
      shape: const RoundedRectangleBorder( // Sửa từ Platform thành Border
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chi tiết ngày $ngay tháng 4', 
                style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _dongChiTiet('Calories tiêu thụ', '1,850 kcal', VitaTrackTheme.mauChinh),
              _dongChiTiet('Protein đã nạp', '85g', VitaTrackTheme.mauNguyHiem),
              _dongChiTiet('Trạng thái', 'Hoàn thành mục tiêu', VitaTrackTheme.mauThanhCong),
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dinh dưỡng', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
        const SizedBox(height: 4),
        const Text('Tháng 4, 2026', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        const Text('Chuỗi ngày ghi nhận', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(30, (index) { // Chỉnh lại 30 ngày cho chuẩn tháng 4
              Color color = (index < 10) ? VitaTrackTheme.mauThanhCong : VitaTrackTheme.mauCardNhat;
              return InkWell(
                onTap: () => _hienThiChiTietNgay(context, index + 1),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                  child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white24, fontSize: 10))),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}