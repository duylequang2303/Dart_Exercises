import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class AchievementTab extends StatefulWidget {
  const AchievementTab({super.key});

  @override
  State<AchievementTab> createState() => _AchievementTabState();
}

class _AchievementTabState extends State<AchievementTab> {
  // Dữ liệu giả lập
  final int _xpHienTai = 1250;
  final int _xpMucTieu = 1500;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. CARD LEVEL & KINH NGHIỆM TƯƠNG TÁC
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: VitaTrackTheme.mauCard,
            borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
            border: Border.all(color: VitaTrackTheme.mauChinh.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: VitaTrackTheme.mauChinh.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)
            ]
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Cấp độ', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 16)),
                  const SizedBox(width: 8),
                  const Text('12', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 40, fontWeight: FontWeight.bold, height: 1)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: VitaTrackTheme.mauThanhCong.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Hạng Bạc', style: TextStyle(color: VitaTrackTheme.mauThanhCong, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_xpHienTai XP', style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
                  Text('$_xpMucTieu XP', style: const TextStyle(color: VitaTrackTheme.mauChuPhu)),
                ],
              ),
              const SizedBox(height: 8),
              
              // THANH KINH NGHIỆM (XP) CÓ ANIMATION CHẠY MƯỢT TỪ 0
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: _xpHienTai / _xpMucTieu),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(color: VitaTrackTheme.mauCardNhat, borderRadius: BorderRadius.circular(6)),
                      ),
                      Container(
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.75 * value, // Chiều rộng linh động
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [VitaTrackTheme.mauPhu, VitaTrackTheme.mauChinh]),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [BoxShadow(color: VitaTrackTheme.mauChinh.withOpacity(0.5), blurRadius: 8)],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Chỉ còn 250 XP nữa để thăng hạng Vàng!', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 2. KHU VỰC HUY HIỆU (BADGES)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Huy hiệu của bạn', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Đã mở 3/8', style: TextStyle(color: VitaTrackTheme.mauChinh.withOpacity(0.8), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        
        // Lưới huy hiệu tương tác
        Wrap(
          spacing: 16,
          runSpacing: 24,
          alignment: WrapAlignment.start,
          children: [
            _taoHuyHieuTuongTac(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, '7 Ngày\nLiên tục', true),
            _taoHuyHieuTuongTac(Icons.directions_walk, VitaTrackTheme.mauChinh, 'Chuyên gia\n10K Bước', true),
            _taoHuyHieuTuongTac(Icons.water_drop, VitaTrackTheme.mauThanhCong, 'Biển cả\n2 Lít', true),
            _taoHuyHieuTuongTac(Icons.pedal_bike, VitaTrackTheme.mauPhu, 'Cua-rơ\n100 km', false),
            _taoHuyHieuTuongTac(Icons.bedtime, VitaTrackTheme.mauCanhBao, 'Ngủ sớm\n1 Tuần', false),
            _taoHuyHieuTuongTac(Icons.fitness_center, VitaTrackTheme.mauChuPhu, 'Tạ thủ\n100 kg', false),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // WIDGET HUY HIỆU CÓ ĐỘ NẢY (BOUNCE) & HIỆU ỨNG KHI BẤM
  Widget _taoHuyHieuTuongTac(IconData icon, Color mauSac, String tieuDe, bool daMoKhoa) {
    return GestureDetector(
      onTap: () {
        if (daMoKhoa) {
          HapticFeedback.heavyImpact(); // Rung mạnh khi khoe huy hiệu
          _hienThiPopupKhoeThanhTich(context, icon, mauSac, tieuDe);
        } else {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Huy hiệu chưa được mở khóa. Cố lên nhé!'),
              backgroundColor: VitaTrackTheme.mauCardNhat,
              duration: const Duration(seconds: 2),
            )
          );
        }
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack, // Hiệu ứng mọc lên nảy nảy
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 100, // Chiều rộng cố định cho mỗi huy hiệu
              child: Column(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: daMoKhoa ? mauSac.withOpacity(0.15) : VitaTrackTheme.mauCard,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: daMoKhoa ? mauSac.withOpacity(0.5) : VitaTrackTheme.mauCardNhat, 
                        width: 2
                      ),
                      boxShadow: daMoKhoa ? [BoxShadow(color: mauSac.withOpacity(0.3), blurRadius: 12)] : [],
                    ),
                    child: Icon(icon, color: daMoKhoa ? mauSac : VitaTrackTheme.mauChuPhu.withOpacity(0.3), size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tieuDe, 
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      color: daMoKhoa ? VitaTrackTheme.mauChu : VitaTrackTheme.mauChuPhu.withOpacity(0.5), 
                      fontSize: 12, 
                      fontWeight: daMoKhoa ? FontWeight.bold : FontWeight.normal,
                      height: 1.3
                    )
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  // BOTTOM SHEET KHOE THÀNH TÍCH MƯỢT MÀ
  void _hienThiPopupKhoeThanhTich(BuildContext context, IconData icon, Color mauSac, String tieuDe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: VitaTrackTheme.mauCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: mauSac.withOpacity(0.2), shape: BoxShape.circle, boxShadow: [BoxShadow(color: mauSac.withOpacity(0.4), blurRadius: 20)]),
                  child: Icon(icon, color: mauSac, size: 64),
                ),
                const SizedBox(height: 24),
                Text(tieuDe.replaceAll('\n', ' '), style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Bạn đã đạt được huy hiệu này! Tuyệt vời!', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mauSac,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tuyệt quá', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    );
  }
}