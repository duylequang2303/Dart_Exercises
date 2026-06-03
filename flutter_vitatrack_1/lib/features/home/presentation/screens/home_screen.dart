import 'package:flutter/material.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/notification/presentation/screens/notification_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/health/presentation/providers/health_provider.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:flutter_vitatrack_1/features/home/presentation/widgets/ai_assistant_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(healthProvider);
    final authState = ref.watch(authProvider);
    final nutrition = ref.watch(nutritionProvider);
    
    final tenHienThi = authState.nguoiDung?.tenHienThi ?? 'Bạn';
    final calo = nutrition.caloDaNap;
    final litNuoc = (nutrition.soLyNuoc * 0.25).toStringAsFixed(1); // Giả sử 1 ly = 250ml
    
    final stepProgress = (health.steps / 10000.0).clamp(0.0, 1.0);
    final sleepHours = health.sleepHours == 0.0 ? 7.5 : health.sleepHours;
    final sleepH = sleepHours.truncate();
    final sleepM = ((sleepHours - sleepH) * 60).round();
    final sleepText = '${sleepH}h ${sleepM}m';

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
                      Text(
                        tenHienThi, // Tên hiển thị từ AuthProvider
                        style: const TextStyle(
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
              
              // ===== TRỢ LÝ AI =====
              const AiAssistantWidget(),

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
                        _taoThongSoNho(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, '$calo', 'kcal'),
                        _taoThongSoNho(Icons.do_not_step, VitaTrackTheme.mauThanhCong, '${health.steps}', 'bước'),
                        _taoThongSoNho(Icons.water_drop, VitaTrackTheme.mauChinh, litNuoc, 'lít'),
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
                  Expanded(child: _taoCardHoatDong(Icons.local_fire_department, 'Calories', '$calo', '${authState.nguoiDung?.caloMucTieu ?? 2000}', VitaTrackTheme.mauNguyHiem, (calo/(authState.nguoiDung?.caloMucTieu ?? 2000)).clamp(0.0, 1.0))),
                  const SizedBox(width: 16),
                  Expanded(child: _taoCardHoatDong(Icons.water_drop, 'Nước uống', '${litNuoc}L', '${(authState.nguoiDung?.nuocMucTieu ?? 8) * 0.25}L', VitaTrackTheme.mauChinh, (double.parse(litNuoc)/((authState.nguoiDung?.nuocMucTieu ?? 8) * 0.25)).clamp(0.0, 1.0))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _taoCardHoatDong(Icons.do_not_step, 'Số bước', '${health.steps}', '10000', VitaTrackTheme.mauThanhCong, stepProgress)),
                  const SizedBox(width: 16),
                  Expanded(child: _taoCardHoatDong(Icons.nightlight_round, 'Giấc ngủ', sleepText, '8h', VitaTrackTheme.mauPhu, (sleepHours / 8.0).clamp(0.0, 1.0))),
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
                    Builder(builder: (context) {
                      final today = DateTime.now().weekday; // 1=T2, 2=T3, ... 7=CN
                      final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (i) => _taoNgayTrongTuan(days[i], today == i + 1)),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ===== CARD GỢI Ý AI =====
              Builder(
                builder: (context) {
                  final steps = health.steps;
                  final calories = nutrition.caloDaNap;
                  final waterCups = nutrition.soLyNuoc;
                  
                  String dynamicAiSuggestion = '';
                  if (steps < 3000) {
                    dynamicAiSuggestion = 'Bạn mới đi được $steps bước hôm nay. Hãy đứng dậy đi bộ nhẹ nhàng 10 phút để nạp lại năng lượng nhé!';
                  } else if (steps < 10000) {
                    final thieu = 10000 - steps;
                    dynamicAiSuggestion = 'Bạn đã đi được $steps bước rồi, còn thiếu $thieu bước nữa để đạt mục tiêu 10,000 bước. Cố lên nhé!';
                  } else {
                    dynamicAiSuggestion = 'Tuyệt vời! Bạn đã đi được $steps bước, vượt mục tiêu sức khỏe hàng ngày rồi. Tiếp tục duy trì nhé!';
                  }
                  
                  if (calories > 2200) {
                    dynamicAiSuggestion += ' Hôm nay bạn đã nạp $calories kcal (khá nhiều), hãy ưu tiên ăn nhẹ và uống nhiều nước.';
                  } else if (calories < 1200 && calories > 0) {
                    dynamicAiSuggestion += ' Lượng calo nạp vào hơi ít ($calories kcal), hãy nhớ ăn uống đầy đủ dưỡng chất nhé.';
                  }
                  
                  if (waterCups < 4) {
                    dynamicAiSuggestion += ' Bạn mới uống $waterCups ly nước. Hãy uống thêm một ly nước 250ml ngay nào.';
                  } else {
                    dynamicAiSuggestion += ' Chỉ số nước uống rất tốt ($waterCups ly). Hãy giữ vững thói quen này nhé.';
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: VitaTrackTheme.mauCardNhat.withValues(alpha: 0.5), 
                      borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
                      border: Border.all(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: VitaTrackTheme.mauChinh.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bolt, color: VitaTrackTheme.mauChinh),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gợi ý từ AI Coach',
                                style: TextStyle(
                                  color: VitaTrackTheme.mauChu,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dynamicAiSuggestion,
                                style: const TextStyle(color: VitaTrackTheme.mauChuPhu, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
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
            pageBuilder: (_, _, _) => const NotificationScreen(),
            transitionsBuilder: (_, animation, _, child) {
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