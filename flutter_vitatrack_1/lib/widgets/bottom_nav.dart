import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../screens/home/home_screen.dart';
import '../screens/nutrition/nutrition_screen.dart';
import '../screens/activity/activity_screen.dart';
import '../screens/ai_coach/ai_coach_screen.dart';
import '../screens/profile/profile_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _viTriHienTai = 0;

  final List<Widget> _danhSachManHinh = [
    const HomeScreen(),
    const NutritionScreen(),
    const ActivityScreen(),
    const AiCoachScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: IndexedStack(index: _viTriHienTai, children: _danhSachManHinh),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        decoration: const BoxDecoration(
          color: VitaTrackTheme.mauCard,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _taoNutNav(0, Icons.home_filled, 'Trang chủ'),
            _taoNutNav(1, Icons.restaurant_outlined, 'Dinh dưỡng'),
            _taoNutNav(2, Icons.show_chart, 'Hoạt động'),
            _taoNutNav(3, Icons.smart_toy_outlined, 'AI Coach'),
            _taoNutNav(4, Icons.person_outline, 'Cá nhân'),
          ],
        ),
      ),
    );
  }

  Widget _taoNutNav(int index, IconData icon, String label) {
    bool dangChon = _viTriHienTai == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _viTriHienTai = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: dangChon ? VitaTrackTheme.mauChinh : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon,
                color: dangChon ? VitaTrackTheme.mauNen : VitaTrackTheme.mauChuPhu,
                size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: dangChon ? FontWeight.bold : FontWeight.w500,
                color: dangChon ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChuPhu,
              )),
        ],
      ),
    );
  }
}