import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Container(
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Column(
            children: [
              _taoMucCaiDat(Icons.track_changes, VitaTrackTheme.mauChinh, 'Mục tiêu cá nhân'),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.notifications_none, VitaTrackTheme.mauCanhBao ?? Colors.orange, 'Thông báo'),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.palette_outlined, VitaTrackTheme.mauPhu, 'Giao diện'),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.lock_outline, VitaTrackTheme.mauThanhCong, 'Quyền riêng tư'),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.language, VitaTrackTheme.mauNguyHiem, 'Ngôn ngữ'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // NÚT ĐĂNG XUẤT
        Material(
          color: VitaTrackTheme.mauNguyHiem.withOpacity(0.15),
          borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
          child: InkWell(
            onTap: () { print("Đăng xuất"); },
            borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: VitaTrackTheme.mauNguyHiem),
                  SizedBox(width: 12),
                  Text('Đăng xuất', style: TextStyle(color: VitaTrackTheme.mauNguyHiem, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _taoMucCaiDat(IconData icon, Color mau, String title) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: mau.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: mau, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: VitaTrackTheme.mauChuPhu, size: 20),
      onTap: () {},
    );
  }

  Widget _taoDuongKe() {
    return const Divider(color: VitaTrackTheme.mauCardNhat, height: 1, indent: 60, endIndent: 16);
  }
}