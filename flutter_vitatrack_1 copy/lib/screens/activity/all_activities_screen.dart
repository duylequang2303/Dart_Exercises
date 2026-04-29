import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AllActivitiesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> danhSach;

  const AllActivitiesScreen({super.key, required this.danhSach});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      appBar: AppBar(
        title: const Text('Tất cả hoạt động', style: TextStyle(color: VitaTrackTheme.mauChu)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: VitaTrackTheme.mauChu),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: danhSach.length,
        itemBuilder: (context, index) {
          final item = danhSach[index];
          // Tái sử dụng giao diện card (Copy từ ActivityScreen qua hoặc để đơn giản viết lại ngắn gọn)
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Icon(item['icon'], color: VitaTrackTheme.mauThanhCong),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['ten'], style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
                    Text('${item['thoiGian']} - ${item['calo']} kcal', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Text(item['gio'], style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}