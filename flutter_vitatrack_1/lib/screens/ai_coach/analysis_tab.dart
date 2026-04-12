import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class AnalysisTab extends StatefulWidget {
  const AnalysisTab({super.key});

  @override
  State<AnalysisTab> createState() => _AnalysisTabState();
}

class _AnalysisTabState extends State<AnalysisTab> with SingleTickerProviderStateMixin {
  bool _dangPhanTich = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    // Animation viền nhấp nháy cho thẻ AI
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // KỊCH BẢN FAKE LOADING: AI ĐANG QUÉT DỮ LIỆU
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _dangPhanTich = false;
          HapticFeedback.heavyImpact(); // Rung mạnh khi phân tích xong
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dangPhanTich) {
      return _buildScanningUI();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - opacity)), // Trượt nhẹ từ dưới lên
            child: child,
          ),
        );
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 40),
        children: [
          _buildHighlightCard(),
          const SizedBox(height: 24),
          const Text('Chỉ số đáng chú ý', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _taoCardThongSo('Chất lượng giấc ngủ', 'Tốt hơn tuần trước', '+15%', VitaTrackTheme.mauPhu, Icons.bedtime),
          const SizedBox(height: 12),
          _taoCardThongSo('Nạp nước', 'Còn 700ml nữa', '1.8L', VitaTrackTheme.mauChinh, Icons.water_drop),
          const SizedBox(height: 12),
          _taoCardThongSo('Calories đốt cháy', 'Đạt 65% mục tiêu', '450', VitaTrackTheme.mauNguyHiem, Icons.local_fire_department),
          const SizedBox(height: 24),
          _buildWeeklyProgress(),
        ],
      ),
    );
  }

  // MÀN HÌNH AI ĐANG "QUÉT" DỮ LIỆU (BỊP HỘI ĐỒNG)
  Widget _buildScanningUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(
                  color: VitaTrackTheme.mauChinh.withOpacity(0.3),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(
                width: 50, height: 50,
                child: CircularProgressIndicator(
                  color: VitaTrackTheme.mauChinh,
                  strokeWidth: 4,
                ),
              ),
              const Icon(Icons.smart_toy, color: VitaTrackTheme.mauChinh, size: 28),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'AI đang tổng hợp dữ liệu sinh học...',
            style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Đang phân tích xu hướng tuần qua',
            style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // THẺ BÁO CÁO TỔNG QUAN (CÓ VIỀN NHẤP NHÁY MÀU NEON)
  Widget _buildHighlightCard() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: VitaTrackTheme.mauCard.withOpacity(0.8),
            borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
            border: Border.all(
              color: VitaTrackTheme.mauChinh.withOpacity(0.2 + (_pulseController.value * 0.4)), 
              width: 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: VitaTrackTheme.mauChinh.withOpacity(0.05 + (_pulseController.value * 0.1)),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauChinh.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.insights, color: VitaTrackTheme.mauChinh),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nhận xét từ AI', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Phong độ của bạn đang tăng đều đặn. Nhịp tim trung bình đã giảm 3 BPM so với tuần trước, cho thấy sức bền tim mạch đang cải thiện rõ rệt!',
                      style: TextStyle(color: VitaTrackTheme.mauChuPhu, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  // CARD THÔNG SỐ (BẤM VÀO SẼ RUNG)
  Widget _taoCardThongSo(String tieuDe, String moTa, String giaTri, Color mau, IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // Rung nhẹ khi chạm
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: VitaTrackTheme.mauCard, 
          borderRadius: BorderRadius.circular(VitaTrackTheme.boGocVua),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: mau.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: mau, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(tieuDe, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(moTa, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                ]
              ),
            ),
            // Hiệu ứng "nảy" cho chữ số
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Text(giaTri, style: TextStyle(color: mau, fontSize: 22, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // BIỂU ĐỒ HOẠT ĐỘNG TUẦN VỚI ANIMATED PROGRESS BAR
  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard, 
        borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hoạt động tuần này', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _taoThanhTienDo('T2', 0.8),
          const SizedBox(height: 16),
          _taoThanhTienDo('T3', 0.65),
          const SizedBox(height: 16),
          _taoThanhTienDo('T4', 0.9),
          const SizedBox(height: 16),
          _taoThanhTienDo('T5', 0.4),
          const SizedBox(height: 16),
          _taoThanhTienDo('T6', 1.0, isToday: true), // Nhấn mạnh ngày hiện tại
        ],
      ),
    );
  }

  Widget _taoThanhTienDo(String thu, double tiLe, {bool isToday = false}) {
    return Row(
      children: [
        SizedBox(
          width: 40, 
          child: Text(
            thu, 
            style: TextStyle(
              color: isToday ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChuPhu, 
              fontSize: 14, 
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal
            )
          )
        ),
        Expanded(
          // BƠM ANIMATION CHO THANH TIẾN ĐỘ
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: tiLe),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: VitaTrackTheme.mauCardNhat,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width * 0.6 * value, // Chiều dài thanh
                    decoration: BoxDecoration(
                      color: isToday ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauPhu,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: isToday ? [BoxShadow(color: VitaTrackTheme.mauChinh.withOpacity(0.5), blurRadius: 6)] : [],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '${(tiLe * 100).toInt()}%',
            style: TextStyle(
              color: isToday ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChu, 
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal
            )
          ),
        )
      ],
    );
  }
}