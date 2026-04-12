import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../services/mock_data_service.dart';
import 'live_workout_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _tabHienTai = 0;
  final data = MockDataService.instance;
  bool _dangBamNut = false;

  // Dữ liệu bài tập gợi ý (Card ngang)
  final List<Map<String, dynamic>> _goiYTapLuyen = [
    {"ten": "Chạy bộ buổi sáng", "thoiGian": "32 phút", "calo": 320, "icon": Icons.directions_run, "mau": Color(0xFF1B2E28)},
    {"ten": "Đạp xe chiều", "thoiGian": "45 phút", "calo": 280, "icon": Icons.pedal_bike, "mau": Color(0xFF1A2136)},
    {"ten": "Bơi lội", "thoiGian": "30 phút", "calo": 400, "icon": Icons.pool, "mau": Color(0xFF2E241B)},
  ];

  // Dữ liệu lịch sử (Thẻ chi tiết có nhịp tim)
  final List<Map<String, dynamic>> _ganDay = [
    {"ten": "Chạy bộ", "gio": "07:30", "thoiGian": "32 phút", "calo": 320, "nhipTim": 145, "icon": Icons.directions_run},
    {"ten": "Đi bộ", "gio": "12:15", "thoiGian": "15 phút", "calo": 85, "nhipTim": 95, "icon": Icons.directions_walk},
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: data,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: VitaTrackTheme.mauNen,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildTabBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _tabHienTai == 0 
                              ? _buildTabTongQuan(key: const ValueKey(0)) 
                              : _buildTabBaiTap(key: const ValueKey(1)),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hoạt động', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
              SizedBox(height: 4),
              Text('Hôm nay', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          GestureDetector(
            onTapDown: (_) => setState(() => _dangBamNut = true),
            onTapUp: (_) {
              setState(() => _dangBamNut = false);
              HapticFeedback.mediumImpact(); 
              _hienThiMenuBatDauTap(context); 
            },
            onTapCancel: () => setState(() => _dangBamNut = false),
            child: AnimatedScale(
              scale: _dangBamNut ? 0.90 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauChinh,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _dangBamNut ? [] : [BoxShadow(color: VitaTrackTheme.mauChinh.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.play_arrow_rounded, color: VitaTrackTheme.mauNen, size: 20),
                    SizedBox(width: 6),
                    Text('Bắt đầu', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _hienThiMenuBatDauTap(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: VitaTrackTheme.mauCardNhat, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('Chọn bài tập', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _taoLuaChonTap(parentContext, sheetContext, Icons.directions_run, 'Chạy bộ ngoài trời', VitaTrackTheme.mauChinh),
              _taoLuaChonTap(parentContext, sheetContext, Icons.pedal_bike, 'Đạp xe', VitaTrackTheme.mauThanhCong),
              _taoLuaChonTap(parentContext, sheetContext, Icons.fitness_center, 'Tập kháng lực', VitaTrackTheme.mauNguyHiem),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _taoLuaChonTap(BuildContext parentContext, BuildContext sheetContext, IconData icon, String title, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: VitaTrackTheme.mauChuPhu),
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.pop(sheetContext);
        final result = await Navigator.push(
          parentContext,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => LiveWorkoutScreen(tenBaiTap: title, iconBaiTap: icon),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          ),
        );
        if (result == true && mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text('Đã lưu bài tập $title!'), backgroundColor: VitaTrackTheme.mauThanhCong, behavior: SnackBarBehavior.floating));
        }
      },
    );
  }

  // === TAB 1: TỔNG QUAN ===
  Widget _buildTabTongQuan({Key? key}) {
    final double phanTram = (data.soBuocChan / data.buocChanMucTieu).clamp(0.0, 1.0);
    return Column(
      key: key,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Column(
            children: [
              SizedBox(
                width: 180, height: 180,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: phanTram),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    int soBuocHienThi = (value * data.buocChanMucTieu).toInt();
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(value: value, backgroundColor: VitaTrackTheme.mauCardNhat, color: VitaTrackTheme.mauChinh, strokeWidth: 14, strokeCap: StrokeCap.round),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_walk, color: VitaTrackTheme.mauChinh, size: 28),
                            const SizedBox(height: 8),
                            Text('$soBuocHienThi', style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 36, fontWeight: FontWeight.bold)),
                            Text('/ ${data.buocChanMucTieu} bước', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniStat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, '320', 'kcal'),
                  _miniStat(Icons.straighten, VitaTrackTheme.mauThanhCong, '5.8', 'km'),
                  _miniStat(Icons.timer, VitaTrackTheme.mauCanhBao, '42', 'phút'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildHeartRateCard(),
      ],
    );
  }

  Widget _buildHeartRateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nhịp tim', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${data.nhipTim}', style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 40, fontWeight: FontWeight.bold)),
                  const Padding(padding: EdgeInsets.only(bottom: 6, left: 6), child: Text('BPM', style: TextStyle(color: VitaTrackTheme.mauChuPhu))),
                ],
              ),
              const Text('Bình thường', style: TextStyle(color: VitaTrackTheme.mauThanhCong, fontSize: 13)),
            ],
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: 1.1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, val, child) => Transform.scale(scale: val, child: child),
            child: const Icon(Icons.favorite, color: VitaTrackTheme.mauNguyHiem, size: 56),
          ),
        ],
      ),
    );
  }

  // === TAB 2: BÀI TẬP (ĐÃ ĐẠI TU THEO HÌNH MẪU) ===
  Widget _buildTabBaiTap({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PHẦN 1: BÀI TẬP GỢI Ý (CARD NGANG)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bài tập gợi ý', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Xem tất cả >', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _goiYTapLuyen.length,
            itemBuilder: (context, index) {
              final item = _goiYTapLuyen[index];
              return _buildSuggestedCard(item);
            },
          ),
        ),

        const SizedBox(height: 32),

        // PHẦN 2: HOẠT ĐỘNG GẦN ĐÂY (CHI TIẾT)
        const Text('Hoạt động gần đây', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._ganDay.map((item) => _buildRecentActivityCard(item)).toList(),
      ],
    );
  }

  // Widget vẽ Card Gợi ý (Phong cách Modern Glass)
  Widget _buildSuggestedCard(Map<String, dynamic> item) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard,
        borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
        border: Border.all(color: VitaTrackTheme.mauCardNhat),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: item['mau'], borderRadius: BorderRadius.circular(12)),
            child: Icon(item['icon'], color: VitaTrackTheme.mauChinh, size: 24),
          ),
          const Spacer(),
          Text(item['ten'], style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: VitaTrackTheme.mauChuPhu, size: 14),
              const SizedBox(width: 4),
              Text(item['thoiGian'], style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.local_fire_department_outlined, color: VitaTrackTheme.mauChuPhu, size: 14),
              const SizedBox(width: 4),
              Text('${item['calo']} kcal', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // Widget vẽ Card Hoạt động gần đây (Thanh lịch, đầy đủ thông số)
  Widget _buildRecentActivityCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF1B2E28), shape: BoxShape.circle),
            child: Icon(item['icon'], color: VitaTrackTheme.mauThanhCong, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['ten'], style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(item['gio'], style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _smallInfo(Icons.timer_outlined, item['thoiGian']),
                    const SizedBox(width: 12),
                    _smallInfo(Icons.local_fire_department_outlined, '${item['calo']} kcal'),
                    const SizedBox(width: 12),
                    _smallInfo(Icons.favorite_outline, '${item['nhipTim']}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: VitaTrackTheme.mauChuPhu, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
      ],
    );
  }

  // === CÁC WIDGET PHỤ ===
  Widget _miniStat(IconData icon, Color color, String val, String unit) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(unit, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(child: _tabBtn(0, 'Tổng quan')),
          Expanded(child: _tabBtn(1, 'Bài tập')),
        ],
      ),
    );
  }

  Widget _tabBtn(int index, String title) {
    bool active = _tabHienTai == index;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _tabHienTai = index);
      },
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: active ? VitaTrackTheme.mauChinh : Colors.transparent, borderRadius: BorderRadius.circular(30)),
        child: Center(child: Text(title, style: TextStyle(color: active ? VitaTrackTheme.mauNen : VitaTrackTheme.mauChuPhu, fontWeight: active ? FontWeight.bold : FontWeight.w600))),
      ),
    );
  }
}