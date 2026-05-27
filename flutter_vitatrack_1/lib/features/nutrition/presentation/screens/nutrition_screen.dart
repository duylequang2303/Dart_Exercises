import 'package:flutter/material.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'today_tab.dart';
import 'week_tab.dart';
import 'nutrition_month_view.dart';
import 'add_food_screen.dart'; 

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _tabHienTai = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      floatingActionButton: _tabHienTai == 0 ? FloatingActionButton(
        backgroundColor: VitaTrackTheme.mauChinh,
        child: const Icon(Icons.add, color: VitaTrackTheme.mauNen),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFoodScreen()),
          ).then((_) {
            // Khi nạp món mới thành công quay về, làm mới UI để cập nhật biểu đồ
            setState(() {}); 
          });
        },
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauCard,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(child: _taoTabButton(0, 'Hôm nay')),
                    Expanded(child: _taoTabButton(1, 'Tuần')),
                    Expanded(child: _taoTabButton(2, 'Tháng')),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _hienThiNoiDungTab(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hienThiNoiDungTab() {
    switch (_tabHienTai) {
      // ĐÃ XÓA TỪ KHÓA 'const' ở TodayTab() để tiếp nhận dữ liệu động thời gian thực
      case 0: return const TodayTab(); 
      case 1: return const WeekTab();
      case 2: return const NutritionMonthView();
      default: return const TodayTab();
    }
  }

  Widget _taoTabButton(int index, String tieuDe) {
    bool dangChon = _tabHienTai == index;
    return InkWell(
      onTap: () => setState(() => _tabHienTai = index),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: dangChon ? VitaTrackTheme.mauChinh : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            tieuDe,
            style: TextStyle(
              color: dangChon ? VitaTrackTheme.mauNen : VitaTrackTheme.mauChuPhu,
              fontWeight: dangChon ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}