import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ActivityDetailScreen extends StatelessWidget {
  final String tieuDe;
  final String giaTri;
  final String donVi;

  const ActivityDetailScreen({super.key, required this.tieuDe, required this.giaTri, required this.donVi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(tieuDe, style: const TextStyle(color: VitaTrackTheme.mauChu)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: VitaTrackTheme.mauChu),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần hiển thị thông số chính (giống trong hình bạn gửi)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hiện tại', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(giaTri, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Text(donVi, style: const TextStyle(color: VitaTrackTheme.mauChuPhu)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: VitaTrackTheme.mauThanhCong, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Tốt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 32),
            const Text('Biểu đồ hoạt động', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Biểu đồ cột tự vẽ đơn giản
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(0.4, '6h'),
                  _buildBar(0.8, '9h'),
                  _buildBar(0.3, '12h'),
                  _buildBar(0.9, '15h'), // Cao nhất
                  _buildBar(0.6, '18h'),
                  _buildBar(0.2, '21h'), // Thấp nhất
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Thông tin nhịp tim
            _buildStatRow('Nhịp tim cao nhất', '145 BPM', Icons.trending_up, VitaTrackTheme.mauNguyHiem),
            const SizedBox(height: 12),
            _buildStatRow('Nhịp tim thấp nhất', '62 BPM', Icons.trending_down, Colors.blue),
            const SizedBox(height: 12),
            _buildStatRow('Thời gian tập trung', '45 phút', Icons.timer, VitaTrackTheme.mauChinh),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double heightFactor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 140 * heightFactor,
          decoration: BoxDecoration(
            color: VitaTrackTheme.mauChinh,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [VitaTrackTheme.mauChinh, VitaTrackTheme.mauChinh.withOpacity(0.3)],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 10)),
      ],
    );
  }

  Widget _buildStatRow(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(color: VitaTrackTheme.mauChuPhu)),
          const Spacer(),
          Text(value, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}