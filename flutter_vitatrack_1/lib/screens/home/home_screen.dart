import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../screens/notification/notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chào buổi sáng,',
                        style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Duy', // Tên hiển thị
                        style: TextStyle(
                          color: VitaTrackTheme.mauChu,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: VitaTrackTheme.mauCardNhat,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Stack(
                      children: [
                        _NutThongBao(),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: VitaTrackTheme.mauNguyHiem,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ===== CARD MỤC TIÊU HÔM NAY (CARD LỚN) =====
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauCard,
                  borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
                ),
                child: Column(
                  children: [
                    // Dòng trên: Text và Vòng tròn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mục tiêu hôm nay',
                              style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  '75%',
                                  style: TextStyle(
                                    color: VitaTrackTheme.mauChu,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    '+12%',
                                    style: TextStyle(
                                      color: VitaTrackTheme.mauThanhCong,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // VÒNG TRÒN PROGRESS SẤM SÉT - ĐÃ ĐƯỢC BƠM ANIMATION
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 0.75),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: value,
                                    backgroundColor: VitaTrackTheme.mauCardNhat,
                                    color: VitaTrackTheme.mauChinh,
                                    strokeWidth: 8,
                                    strokeCap: StrokeCap.round,
                                  ),
                                  const Center(
                                    child: Icon(Icons.bolt, color: VitaTrackTheme.mauChinh, size: 32),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Dòng dưới: 3 thông số nhỏ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _taoThongSoNho(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, '1,850', 'kcal'),
                        _taoThongSoNho(Icons.do_not_step, VitaTrackTheme.mauThanhCong, '8,234', 'bước'),
                        _taoThongSoNho(Icons.water_drop, VitaTrackTheme.mauChinh, '1.8', 'lít'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ===== TIÊU ĐỀ HOẠT ĐỘNG =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hoạt động hôm nay',
                    style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Xem tất cả >',
                    style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ===== LƯỚI 4 CARD HOẠT ĐỘNG =====
              Row(
                children: [
                  Expanded(child: _taoCardHoatDong(Icons.local_fire_department, 'Calories', '1,850', '2,200', VitaTrackTheme.mauNguyHiem, 0.8)),
                  const SizedBox(width: 16),
                  Expanded(child: _taoCardHoatDong(Icons.water_drop, 'Nước uống', '1.8L', '2.5L', VitaTrackTheme.mauChinh, 0.7)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _taoCardHoatDong(Icons.do_not_step, 'Số bước', '8,234', '10,000', VitaTrackTheme.mauThanhCong, 0.85)),
                  const SizedBox(width: 16),
                  Expanded(child: _taoCardHoatDong(Icons.nightlight_round, 'Giấc ngủ', '7h 30m', '8h', VitaTrackTheme.mauPhu, 0.9)),
                ],
              ),
              const SizedBox(height: 32),

              // ===== CARD XU HƯỚNG TUẦN NÀY =====
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauCard,
                  borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Xu hướng tuần này',
                          style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: VitaTrackTheme.mauThanhCong, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              '+15%',
                              style: TextStyle(color: VitaTrackTheme.mauThanhCong, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 40), 
                    
                    // Các ngày trong tuần
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _taoNgayTrongTuan('T2', false),
                        _taoNgayTrongTuan('T3', false),
                        _taoNgayTrongTuan('T4', false),
                        _taoNgayTrongTuan('T5', false),
                        _taoNgayTrongTuan('T6', true), // Ngày đang chọn
                        _taoNgayTrongTuan('T7', false),
                        _taoNgayTrongTuan('CN', false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ===== CARD GỢI Ý AI =====
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauCardNhat.withOpacity(0.5), 
                  borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
                  border: Border.all(color: VitaTrackTheme.mauChinh.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: VitaTrackTheme.mauChinh.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt, color: VitaTrackTheme.mauChinh),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gợi ý từ AI Coach',
                            style: TextStyle(
                              color: VitaTrackTheme.mauChu,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Bạn đã đạt 85% mục tiêu bước chân! Chỉ cần thêm 1,766 bước nữa để hoàn thành. Đi bộ 15 phút sau bữa tối sẽ giúp bạn đạt được mục tiêu.',
                            style: TextStyle(color: VitaTrackTheme.mauChuPhu, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
    );
  }

  // === CÁC WIDGET HỖ TRỢ ĐỂ CODE GỌN GÀNG HƠN ===

  Widget _taoThongSoNho(IconData icon, Color mauIcon, String giaTri, String donVi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCardNhat,
        borderRadius: BorderRadius.circular(VitaTrackTheme.boGocVua),
      ),
      child: Column(
        children: [
          Icon(icon, color: mauIcon, size: 20),
          const SizedBox(height: 8),
          Text(
            giaTri,
            style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            donVi,
            style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _taoCardHoatDong(IconData icon, String tieuDe, String giaTri, String mucTieu, Color mauSac, double phanTram) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard,
        borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: mauSac, size: 20),
              const SizedBox(width: 8),
              Text(tieuDe, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            giaTri,
            style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Mục tiêu: $mucTieu',
            style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12),
          ),
          const SizedBox(height: 12),
          // THANH PROGRESS BAR - ĐÃ ĐƯỢC BƠM ANIMATION
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: phanTram),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: VitaTrackTheme.mauCardNhat,
                color: mauSac,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _taoNgayTrongTuan(String tenNgay, bool dangChon) {
    return Text(
      tenNgay,
      style: TextStyle(
        color: dangChon ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChuPhu,
        fontWeight: dangChon ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _NutThongBao extends StatelessWidget {
  const _NutThongBao();
 
  static const int _soThongBao = 3;
 
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => const NotificationScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: VitaTrackTheme.mauCard,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
            if (_soThongBao > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: VitaTrackTheme.mauChinh, 
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _soThongBao > 9 ? '9+' : '$_soThongBao',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}