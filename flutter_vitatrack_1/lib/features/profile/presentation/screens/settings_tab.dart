import 'package:flutter/material.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/profile/presentation/providers/profile_provider.dart';

// Provider lưu trạng thái ngôn ngữ và thông báo tạm thời trong session
final _ngonNguProvider = StateProvider<String>((ref) => 'vi');
final _thongBaoProvider = StateProvider<bool>((ref) => true);

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final ngonNgu = ref.watch(_ngonNguProvider);
    final thongBao = ref.watch(_thongBaoProvider);

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Container(
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Column(
            children: [
              _taoMucCaiDat(Icons.track_changes, VitaTrackTheme.mauChinh, 'Mục tiêu cá nhân', _hienThiMucTieuCaNhan),
              _taoDuongKe(),
              // Thông báo với toggle switch
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: VitaTrackTheme.mauCanhBao.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_none, color: VitaTrackTheme.mauCanhBao, size: 20),
                ),
                title: const Text('Thông báo', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 15)),
                trailing: Switch(
                  value: thongBao,
                  onChanged: (val) => ref.read(_thongBaoProvider.notifier).state = val,
                  activeThumbColor: VitaTrackTheme.mauChinh,
                  inactiveTrackColor: VitaTrackTheme.mauCardNhat,
                ),
              ),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.palette_outlined, VitaTrackTheme.mauPhu, 'Giao diện', _hienThiGiaoDien),
              _taoDuongKe(),
              _taoMucCaiDat(Icons.lock_outline, VitaTrackTheme.mauThanhCong, 'Đổi mật khẩu', _hienThiDialogDoiMatKhau),
              _taoDuongKe(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: VitaTrackTheme.mauNguyHiem.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.language, color: VitaTrackTheme.mauNguyHiem, size: 20),
                ),
                title: const Text('Ngôn ngữ', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 15)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ngonNgu == 'vi' ? '🇻🇳 Tiếng Việt' : '🇺🇸 English',
                        style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: VitaTrackTheme.mauChuPhu, size: 20),
                  ],
                ),
                onTap: _hienThiNgonNgu,
              ),
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

  // ─── Mục tiêu cá nhân ─────────────────────────────────────

  void _hienThiMucTieuCaNhan() {
    final profile = ref.read(profileProvider).profile;
    String mucTieuChon = profile?.mucTieu ?? 'Giảm cân';
    final chieuCaoCtrl = TextEditingController(text: profile?.chieuCao?.toString() ?? '');
    final canNangCtrl = TextEditingController(text: profile?.canNang?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: VitaTrackTheme.mauCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: VitaTrackTheme.mauCardNhat, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  const Text('Mục tiêu cá nhân', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Mục tiêu tập luyện', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Giảm cân', 'Tăng cơ', 'Giữ dáng'].map((goal) {
                      final selected = mucTieuChon == goal;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => mucTieuChon = goal),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? VitaTrackTheme.mauChinh.withValues(alpha: 0.15) : VitaTrackTheme.mauCardNhat,
                              borderRadius: BorderRadius.circular(10),
                              border: selected ? Border.all(color: VitaTrackTheme.mauChinh) : null,
                            ),
                            child: Center(child: Text(goal, style: TextStyle(color: selected ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChuPhu, fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal))),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: chieuCaoCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: VitaTrackTheme.mauChu),
                          decoration: const InputDecoration(
                            labelText: 'Chiều cao (cm)',
                            labelStyle: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: VitaTrackTheme.mauChuPhu)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VitaTrackTheme.mauChinh)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: canNangCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: VitaTrackTheme.mauChu),
                          decoration: const InputDecoration(
                            labelText: 'Cân nặng (kg)',
                            labelStyle: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: VitaTrackTheme.mauChuPhu)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: VitaTrackTheme.mauChinh)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VitaTrackTheme.mauChinh,
                        foregroundColor: VitaTrackTheme.mauNen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(sheetCtx);
                        await ref.read(profileProvider.notifier).updateProfile({
                          'mucTieu': mucTieuChon,
                          if (chieuCaoCtrl.text.isNotEmpty) 'chieuCao': double.tryParse(chieuCaoCtrl.text),
                          if (canNangCtrl.text.isNotEmpty) 'canNang': double.tryParse(canNangCtrl.text),
                        });
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật mục tiêu!'), backgroundColor: VitaTrackTheme.mauThanhCong, behavior: SnackBarBehavior.floating));
                      },
                      child: const Text('Lưu thay đổi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // ─── Giao diện ───────────────────────────────────────────

  void _hienThiGiaoDien() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VitaTrackTheme.mauCard,
        title: const Text('Giao diện', style: TextStyle(color: VitaTrackTheme.mauChu)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dark_mode, color: VitaTrackTheme.mauPhu),
              title: const Text('Chế độ tối (Dark Mode)', style: TextStyle(color: VitaTrackTheme.mauChu)),
              trailing: const Icon(Icons.check, color: VitaTrackTheme.mauChinh, size: 18),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang dùng chế độ tối'), backgroundColor: VitaTrackTheme.mauCard, behavior: SnackBarBehavior.floating));
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode, color: VitaTrackTheme.mauCanhBao),
              title: const Text('Chế độ sáng (Light Mode)', style: TextStyle(color: VitaTrackTheme.mauChu)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng sắp ra mắt!'), behavior: SnackBarBehavior.floating));
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng', style: TextStyle(color: VitaTrackTheme.mauChuPhu))),
        ],
      ),
    );
  }

  // ─── Ngôn ngữ ─────────────────────────────────────────────

  void _hienThiNgonNgu() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VitaTrackTheme.mauCard,
        title: const Text('Chọn ngôn ngữ', style: TextStyle(color: VitaTrackTheme.mauChu)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _radioNgonNgu(ctx, 'vi', '🇻🇳 Tiếng Việt'),
            _radioNgonNgu(ctx, 'en', '🇺🇸 English'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng', style: TextStyle(color: VitaTrackTheme.mauChuPhu))),
        ],
      ),
    );
  }

  Widget _radioNgonNgu(BuildContext ctx, String val, String label) {
    final current = ref.read(_ngonNguProvider);
    return RadioListTile<String>(
      value: val,
      groupValue: current,
      activeColor: VitaTrackTheme.mauChinh,
      title: Text(label, style: const TextStyle(color: VitaTrackTheme.mauChu)),
      subtitle: val == 'en' ? const Text('Sắp ra mắt', style: TextStyle(color: VitaTrackTheme.mauCanhBao, fontSize: 11)) : null,
      onChanged: (v) {
        Navigator.pop(ctx);
        if (v == 'en') {
          // Chưa hỗ trợ đầy đủ i18n
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('🇺🇸 English đang phát triển - Sắp ra mắt!'),
            backgroundColor: VitaTrackTheme.mauCanhBao,
            behavior: SnackBarBehavior.floating,
          ));
        } else {
          if (v != null) ref.read(_ngonNguProvider.notifier).state = v;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🇻🇳 Đang dùng Tiếng Việt'), backgroundColor: VitaTrackTheme.mauThanhCong, behavior: SnackBarBehavior.floating));
        }
      },
    );
  }

  // ─── Đổi mật khẩu ────────────────────────────────────────

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
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  await ref.read(profileProvider.notifier).doiMatKhau(mkMoi);
                  
                  if (!mounted) return;
                  final error = ref.read(profileProvider).loi;
                  if (error != null) {
                    messenger.showSnackBar(SnackBar(content: Text(error), backgroundColor: VitaTrackTheme.mauNguyHiem));
                  } else {
                    messenger.showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công'), backgroundColor: VitaTrackTheme.mauThanhCong));
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