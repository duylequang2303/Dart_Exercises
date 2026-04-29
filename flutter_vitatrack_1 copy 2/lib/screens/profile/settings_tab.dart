import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/profile/presentation/providers/profile_provider.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Container(
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Column(
            children: [
              _taoMucCaiDat(Icons.track_changes, VitaTrackTheme.mauChinh, 'Mục tiêu cá nhân', () {}),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.notifications_none, VitaTrackTheme.mauCanhBao, 'Thông báo', () {}),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.palette_outlined, VitaTrackTheme.mauPhu, 'Giao diện', () {}),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.lock_outline, VitaTrackTheme.mauThanhCong, 'Đổi mật khẩu', _hienThiDialogDoiMatKhau),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.language, VitaTrackTheme.mauNguyHiem, 'Ngôn ngữ', () {}),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // NÚT ĐĂNG XUẤT
        Material(
          color: VitaTrackTheme.mauNguyHiem.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
          child: InkWell(
            onTap: () {
              ref.read(profileProvider.notifier).dangXuat();
            },
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

  Widget _taoMucCaiDat(IconData icon, Color mau, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: mau.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: mau, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: VitaTrackTheme.mauChuPhu, size: 20),
      onTap: onTap,
    );
  }

  void _hienThiDialogDoiMatKhau() {
    final mkMoiController = TextEditingController();
    final xacNhanController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: VitaTrackTheme.mauCard,
          title: const Text('Đổi mật khẩu', style: TextStyle(color: VitaTrackTheme.mauChu)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: mkMoiController,
                  obscureText: true,
                  style: const TextStyle(color: VitaTrackTheme.mauChu),
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới',
                    labelStyle: TextStyle(color: VitaTrackTheme.mauChuPhu),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: VitaTrackTheme.mauChuPhu)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VitaTrackTheme.mauChinh)),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                ),
                TextFormField(
                  controller: xacNhanController,
                  obscureText: true,
                  style: const TextStyle(color: VitaTrackTheme.mauChu),
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    labelStyle: TextStyle(color: VitaTrackTheme.mauChuPhu),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: VitaTrackTheme.mauChuPhu)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VitaTrackTheme.mauChinh)),
                  ),
                  validator: (val) {
                    if (val != mkMoiController.text) return 'Mật khẩu không khớp';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final mkMoi = mkMoiController.text;
                  Navigator.pop(context);
                  await ref.read(profileProvider.notifier).doiMatKhau(mkMoi);
                  
                  if (!mounted) return;
                  final error = ref.read(profileProvider).loi;
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: VitaTrackTheme.mauNguyHiem));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công'), backgroundColor: VitaTrackTheme.mauThanhCong));
                  }
                }
              },
              child: const Text('Lưu', style: TextStyle(color: VitaTrackTheme.mauChinh)),
            ),
          ],
        );
      },
    );
  }

  Widget _taoDuongKe() {
    return const Divider(color: VitaTrackTheme.mauCardNhat, height: 1, indent: 60, endIndent: 16);
  }
}