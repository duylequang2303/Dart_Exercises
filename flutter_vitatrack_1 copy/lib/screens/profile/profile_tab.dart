import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/profile/presentation/providers/profile_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final profile = state.profile;

    if (state.dangTai && profile == null) {
      return const Center(child: CircularProgressIndicator(color: VitaTrackTheme.mauChinh));
    }

    final chieuCao = profile?.chieuCao?.toString() ?? '--';
    final canNang = profile?.canNang?.toString() ?? '--';
    final bmi = (profile?.chieuCao != null && profile?.canNang != null && profile!.chieuCao! > 0)
        ? (profile.canNang! / ((profile.chieuCao! / 100) * (profile.chieuCao! / 100))).toStringAsFixed(1)
        : '--';
    final tuoi = profile?.tuoi?.toString() ?? '--';
    final mucTieu = profile?.mucTieu ?? 'Chưa xác định';
    final cuongDo = profile?.cuongDo ?? 'Chưa xác định';
    final gioiTinh = profile?.gioiTinh ?? '--';

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        // THÔNG TIN CƠ THỂ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Thông tin cơ thể', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => _hienThiBottomSheetSuaThongTin(context, ref, profile),
              child: const Text('Chỉnh sửa', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _taoCardThongTin('Chiều cao', '$chieuCao cm', null)),
            const SizedBox(width: 16),
            Expanded(child: _taoCardThongTin('Cân nặng', '$canNang kg', null)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _taoCardThongTin('BMI', bmi, _getBMIBadge(bmi))),
            const SizedBox(width: 16),
            Expanded(child: _taoCardThongTin('Tuổi', tuoi, gioiTinh)),
          ],
        ),
        const SizedBox(height: 32),

        // MỤC TIÊU
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mục tiêu', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => _hienThiBottomSheetSuaThongTin(context, ref, profile),
              child: const Text('Thay đổi', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Column(
            children: [
              _taoTienDoMucTieu('Mục tiêu chính', mucTieu, 1.0),
              const SizedBox(height: 24),
              _taoTienDoMucTieu('Cường độ', cuongDo, 1.0),
              const SizedBox(height: 24),
              _taoTienDoMucTieu('Calories/ngày (Ước tính)', '2,200 kcal', 0.65),
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
                  decoration: BoxDecoration(color: VitaTrackTheme.mauThanhCong.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
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

  String? _getBMIBadge(String bmiStr) {
    if (bmiStr == '--') return null;
    final bmi = double.tryParse(bmiStr);
    if (bmi == null) return null;
    if (bmi < 18.5) return 'Gầy';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  void _hienThiBottomSheetSuaThongTin(BuildContext context, WidgetRef ref, dynamic profile) {
    final chieuCaoCtrl = TextEditingController(text: profile?.chieuCao?.toString() ?? '');
    final canNangCtrl = TextEditingController(text: profile?.canNang?.toString() ?? '');
    String mucTieu = profile?.mucTieu ?? 'Giảm mỡ';
    String cuongDo = profile?.cuongDo ?? 'Vừa';

    final listMucTieu = ['Giảm mỡ', 'Tăng cơ', 'Duy trì'];
    final listCuongDo = ['Nhẹ', 'Vừa', 'Cao'];

    if (!listMucTieu.contains(mucTieu)) mucTieu = listMucTieu.first;
    if (!listCuongDo.contains(cuongDo)) cuongDo = listCuongDo.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24, right: 24, top: 24
              ),
              decoration: const BoxDecoration(
                color: VitaTrackTheme.mauCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chỉnh sửa thông tin', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: chieuCaoCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: VitaTrackTheme.mauChu),
                      decoration: const InputDecoration(labelText: 'Chiều cao (cm)', labelStyle: TextStyle(color: VitaTrackTheme.mauChuPhu)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: canNangCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: VitaTrackTheme.mauChu),
                      decoration: const InputDecoration(labelText: 'Cân nặng (kg)', labelStyle: TextStyle(color: VitaTrackTheme.mauChuPhu)),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: mucTieu,
                      dropdownColor: VitaTrackTheme.mauCardNhat,
                      style: const TextStyle(color: VitaTrackTheme.mauChu),
                      decoration: const InputDecoration(labelText: 'Mục tiêu', labelStyle: TextStyle(color: VitaTrackTheme.mauChuPhu)),
                      items: listMucTieu.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setStateSheet(() => mucTieu = v!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: cuongDo,
                      dropdownColor: VitaTrackTheme.mauCardNhat,
                      style: const TextStyle(color: VitaTrackTheme.mauChu),
                      decoration: const InputDecoration(labelText: 'Cường độ vận động', labelStyle: TextStyle(color: VitaTrackTheme.mauChuPhu)),
                      items: listCuongDo.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setStateSheet(() => cuongDo = v!),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: VitaTrackTheme.mauChinh, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          final data = {
                            if (chieuCaoCtrl.text.isNotEmpty) 'chieuCao': double.tryParse(chieuCaoCtrl.text),
                            if (canNangCtrl.text.isNotEmpty) 'canNang': double.tryParse(canNangCtrl.text),
                            'mucTieu': mucTieu,
                            'cuongDo': cuongDo,
                          };
                          await ref.read(profileProvider.notifier).updateProfile(data);
                          
                          if (!context.mounted) return;
                          final loi = ref.read(profileProvider).loi;
                          if (loi != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loi), backgroundColor: VitaTrackTheme.mauNguyHiem));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thông tin thành công'), backgroundColor: VitaTrackTheme.mauThanhCong));
                          }
                        },
                        child: const Text('Lưu thay đổi', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}