import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _trangHienTai = 0;
  bool _dangTinhToan = false;

  // ===== DỮ LIỆU ĐẦU VÀO ĐÃ NÂNG CẤP =====
  String _mucTieu = 'Giảm cân';
  String _gioiTinh = 'Nam';
  double _chieuCao = 170;
  double _canNang = 65;
  String _cuongDo = 'Vừa phải'; // Thêm dữ liệu cường độ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), 
                onPageChanged: (index) => setState(() => _trangHienTai = index),
                children: [
                  _stepChonMucTieu(),
                  _stepChonGioiTinh(),
                  _stepNhapThongSo(),
                  _stepChonCuongDo(), // Bước mới bổ sung
                  _stepHoanThanh(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    double progress = (_trangHienTai + 1) / 5; // Chia làm 5 bước
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_trangHienTai > 0 && !_dangTinhToan)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: VitaTrackTheme.mauChu, size: 20),
                  onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                )
              else
                const SizedBox(width: 48),
              Text('Bước ${_trangHienTai + 1}/5', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BottomNav())),
                child: const Text('Bỏ qua', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Thanh tiến trình mượt mà
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: VitaTrackTheme.mauCard,
              color: VitaTrackTheme.mauChinh,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // BƯỚC 1: MỤC TIÊU
  Widget _stepChonMucTieu() {
    return _buildStepLayout(
      title: 'Mục tiêu của bạn?',
      desc: 'Chúng tôi sẽ điều chỉnh lượng calo dựa trên lựa chọn này.',
      content: Column(
        children: [
          _buildSelectCard('Giảm cân', Icons.trending_down, _mucTieu == 'Giảm cân', () => setState(() => _mucTieu = 'Giảm cân')),
          const SizedBox(height: 16),
          _buildSelectCard('Giữ dáng', Icons.accessibility_new, _mucTieu == 'Giữ dáng', () => setState(() => _mucTieu = 'Giữ dáng')),
          const SizedBox(height: 16),
          _buildSelectCard('Tăng cơ', Icons.fitness_center, _mucTieu == 'Tăng cơ', () => setState(() => _mucTieu = 'Tăng cơ')),
        ],
      ),
    );
  }

  // BƯỚC 2: GIỚI TÍNH
  Widget _stepChonGioiTinh() {
    return _buildStepLayout(
      title: 'Giới tính của bạn?',
      desc: 'Yếu tố quan trọng để tính chỉ số chuyển hóa cơ bản (BMR).',
      content: Row(
        children: [
          Expanded(child: _buildGenderCard('Nam', Icons.male, _gioiTinh == 'Nam', () => setState(() => _gioiTinh = 'Nam'))),
          const SizedBox(width: 16),
          Expanded(child: _buildGenderCard('Nữ', Icons.female, _gioiTinh == 'Nữ', () => setState(() => _gioiTinh = 'Nữ'))),
        ],
      ),
    );
  }

  // BƯỚC 3: CHIỀU CAO & CÂN NẶNG
  Widget _stepNhapThongSo() {
    return _buildStepLayout(
      title: 'Chỉ số cơ thể',
      desc: 'Hãy kéo thanh trượt để chọn chỉ số chính xác nhất.',
      content: Column(
        children: [
          _buildSliderInput('Chiều cao', _chieuCao, 100, 220, 'cm', (val) => setState(() => _chieuCao = val)),
          const SizedBox(height: 32),
          _buildSliderInput('Cân nặng', _canNang, 30, 150, 'kg', (val) => setState(() => _canNang = val)),
        ],
      ),
    );
  }

  // BƯỚC 4: BỔ SUNG CƯỜNG ĐỘ VẬN ĐỘNG (ĂN ĐIỂM)
  Widget _stepChonCuongDo() {
    return _buildStepLayout(
      title: 'Bạn vận động thế nào?',
      desc: 'Mức độ hoạt động hàng ngày của bạn.',
      content: Column(
        children: [
          _buildSelectCard('Ít vận động', Icons.chair_alt, _cuongDo == 'Ít vận động', () => setState(() => _cuongDo = 'Ít vận động')),
          const SizedBox(height: 12),
          _buildSelectCard('Vừa phải', Icons.directions_walk, _cuongDo == 'Vừa phải', () => setState(() => _cuongDo = 'Vừa phải')),
          const SizedBox(height: 12),
          _buildSelectCard('Năng động', Icons.run_circle_outlined, _cuongDo == 'Năng động', () => setState(() => _cuongDo = 'Năng động')),
          const SizedBox(height: 12),
          _buildSelectCard('Vận động viên', Icons.workspace_premium, _cuongDo == 'Vận động viên', () => setState(() => _cuongDo = 'Vận động viên')),
        ],
      ),
    );
  }

  // BƯỚC 5: HOÀN THÀNH VÀ AI PHÂN TÍCH
  Widget _stepHoanThanh() {
    if (_dangTinhToan) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: VitaTrackTheme.mauChinh),
            const SizedBox(height: 32),
            const Text('AI đang thiết lập kế hoạch...', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Dựa trên mức độ $_cuongDo của bạn', style: const TextStyle(color: VitaTrackTheme.mauChuPhu)),
          ],
        ),
      );
    }

    return _buildStepLayout(
      title: 'Tất cả đã sẵn sàng!',
      desc: 'Lộ trình cá nhân hóa của bạn đã hoàn tất.',
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: VitaTrackTheme.mauChinh.withOpacity(0.3))),
        child: Column(
          children: [
            const Text('Mục tiêu năng lượng hàng ngày:', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
            const SizedBox(height: 16),
            const Text('2,150 kcal', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Divider(color: VitaTrackTheme.mauCardNhat),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('Protein', '140g'),
                _miniStat('Carbs', '250g'),
                _miniStat('Chất béo', '70g'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: VitaTrackTheme.mauChinh,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: VitaTrackTheme.mauChinh.withOpacity(0.4),
          ),
          onPressed: () async {
            HapticFeedback.mediumImpact();
            if (_trangHienTai < 4) {
              _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
              
              // Giả lập tính toán AI khi đến bước cuối
              if (_trangHienTai == 3) {
                setState(() => _dangTinhToan = true);
                await Future.delayed(const Duration(seconds: 2));
                setState(() => _dangTinhToan = false);
              }
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BottomNav()));
            }
          },
          child: Text(
            _trangHienTai == 4 ? 'Bắt đầu hành trình' : 'Tiếp theo',
            style: const TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // --- HỖ TRỢ GIAO DIỆN ---

  Widget _buildStepLayout({required String title, required String desc, required Widget content}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(title, style: VitaTrackTheme.tieuDeLon),
          const SizedBox(height: 12),
          Text(desc, style: VitaTrackTheme.vanBanPhu),
          const SizedBox(height: 40),
          content,
        ],
      ),
    );
  }

  Widget _buildSelectCard(String text, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? VitaTrackTheme.mauChinh.withOpacity(0.1) : VitaTrackTheme.mauCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? VitaTrackTheme.mauChinh : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChuPhu),
            const SizedBox(width: 16),
            Text(text, style: TextStyle(color: selected ? VitaTrackTheme.mauChu : VitaTrackTheme.mauChuPhu, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (selected) const Icon(Icons.check_circle, color: VitaTrackTheme.mauChinh, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(String text, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 140,
        decoration: BoxDecoration(
          color: selected ? VitaTrackTheme.mauChinh.withOpacity(0.1) : VitaTrackTheme.mauCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? VitaTrackTheme.mauChinh : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: selected ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChuPhu),
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: selected ? VitaTrackTheme.mauChu : VitaTrackTheme.mauChuPhu, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderInput(String label, double value, double min, double max, String unit, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16)),
            RichText(text: TextSpan(children: [
              TextSpan(text: '${value.toInt()}', style: const TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 24, fontWeight: FontWeight.bold)),
              TextSpan(text: ' $unit', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
            ])),
          ],
        ),
        Slider(
          value: value, min: min, max: max,
          activeColor: VitaTrackTheme.mauChinh,
          inactiveColor: VitaTrackTheme.mauCardNhat,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _miniStat(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
      ],
    );
  }
}