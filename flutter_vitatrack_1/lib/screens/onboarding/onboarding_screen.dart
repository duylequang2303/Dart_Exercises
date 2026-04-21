import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../widgets/bottom_nav.dart';
import 'onboarding_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/services/user_profile_service.dart';
import '../../features/auth/presentation/providers/onboarding_status_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state, context),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), 
                onPageChanged: (index) => notifier.setCurrentPage(index),
                children: [
                  _stepChonMucTieu(state, notifier),
                  _stepChonGioiTinh(state, notifier),
                  _stepNhapThongSo(state, notifier),
                  _stepChonCuongDo(state, notifier),
                  _stepHoanThanh(state, notifier),
                ],
              ),
            ),
            _buildFooter(state, notifier, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(OnboardingState state, BuildContext context) {
    double progress = (state.currentPage + 1) / 5;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (state.currentPage > 0 && !state.isCalculating)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: VitaTrackTheme.mauChu, size: 20),
                  onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                )
              else
                const SizedBox(width: 48),
              Text('Bước ${state.currentPage + 1}/5', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontWeight: FontWeight.bold)),
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
  Widget _stepChonMucTieu(OnboardingState state, OnboardingNotifier notifier) {
    return _buildStepLayout(
      title: 'Mục tiêu của bạn?',
      desc: 'Chúng tôi sẽ điều chỉnh lượng calo dựa trên lựa chọn này.',
      content: Column(
        children: [
          _buildSelectCard('Giảm cân', Icons.trending_down, state.goal == 'Giảm cân', () => notifier.setGoal('Giảm cân')),
          const SizedBox(height: 16),
          _buildSelectCard('Giữ dáng', Icons.accessibility_new, state.goal == 'Giữ dáng', () => notifier.setGoal('Giữ dáng')),
          const SizedBox(height: 16),
          _buildSelectCard('Tăng cơ', Icons.fitness_center, state.goal == 'Tăng cơ', () => notifier.setGoal('Tăng cơ')),
        ],
      ),
    );
  }

  // BƯỚC 2: GIỚI TÍNH
  Widget _stepChonGioiTinh(OnboardingState state, OnboardingNotifier notifier) {
    return _buildStepLayout(
      title: 'Giới tính của bạn?',
      desc: 'Yếu tố quan trọng để tính chỉ số chuyển hóa cơ bản (BMR).',
      content: Row(
        children: [
          Expanded(child: _buildGenderCard('Nam', Icons.male, state.gender == 'Nam', () => notifier.setGender('Nam'))),
          const SizedBox(width: 16),
          Expanded(child: _buildGenderCard('Nữ', Icons.female, state.gender == 'Nữ', () => notifier.setGender('Nữ'))),
        ],
      ),
    );
  }

  // BƯỚC 3: CHIỀU CAO & CÂN NẶNG
  Widget _stepNhapThongSo(OnboardingState state, OnboardingNotifier notifier) {
    return _buildStepLayout(
      title: 'Chỉ số cơ thể',
      desc: 'Hãy kéo thanh trượt để chọn chỉ số chính xác nhất.',
      content: Column(
        children: [
          _buildSliderInput('Chiều cao', state.height, 100, 220, 'cm', (val) => notifier.setHeight(val)),
          const SizedBox(height: 32),
          _buildSliderInput('Cân nặng', state.weight, 30, 150, 'kg', (val) => notifier.setWeight(val)),
        ],
      ),
    );
  }

  // BƯỚC 4: BỔ SUNG CƯỜNG ĐỘ VẬN ĐỘNG (ĂN ĐIỂM)
  Widget _stepChonCuongDo(OnboardingState state, OnboardingNotifier notifier) {
    return _buildStepLayout(
      title: 'Bạn vận động thế nào?',
      desc: 'Mức độ hoạt động hàng ngày của bạn.',
      content: Column(
        children: [
          _buildSelectCard('Ít vận động', Icons.chair_alt, state.intensity == 'Ít vận động', () => notifier.setIntensity('Ít vận động')),
          const SizedBox(height: 12),
          _buildSelectCard('Vừa phải', Icons.directions_walk, state.intensity == 'Vừa phải', () => notifier.setIntensity('Vừa phải')),
          const SizedBox(height: 12),
          _buildSelectCard('Năng động', Icons.run_circle_outlined, state.intensity == 'Năng động', () => notifier.setIntensity('Năng động')),
          const SizedBox(height: 12),
          _buildSelectCard('Vận động viên', Icons.workspace_premium, state.intensity == 'Vận động viên', () => notifier.setIntensity('Vận động viên')),
        ],
      ),
    );
  }

  // BƯỚC 5: HOÀN THÀNH VÀ AI PHÂN TÍCH
  Widget _stepHoanThanh(OnboardingState state, OnboardingNotifier notifier) {
    if (state.isCalculating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: VitaTrackTheme.mauChinh),
            const SizedBox(height: 32),
            const Text('AI đang thiết lập kế hoạch...', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Dựa trên mức độ ${state.intensity} của bạn', style: const TextStyle(color: VitaTrackTheme.mauChuPhu)),
          ],
        ),
      );
    }

    return _buildStepLayout(
      title: 'Tất cả đã sẵn sàng!',
      desc: 'Lộ trình cá nhân hóa của bạn đã hoàn tất.',
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.3))),
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

  Widget _buildFooter(OnboardingState state, OnboardingNotifier notifier, BuildContext context) {
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
            shadowColor: VitaTrackTheme.mauChinh.withValues(alpha: 0.4),
          ),
          onPressed: () async {
            HapticFeedback.mediumImpact();
            if (state.currentPage < 4) {
              _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
              
              if (state.currentPage == 3) {
                await notifier.simulateAICalculation();
              }
            } else {
              final user = ref.read(nguoiDungHienTaiProvider);
              if (user != null) {
                final userProfileService = ref.read(userProfileServiceProvider);
                await userProfileService.saveOnboardingData(user.uid, {
                  'mucTieu': state.goal,
                  'gioiTinh': state.gender,
                  'chieuCao': state.height,
                  'canNang': state.weight,
                  'cuongDo': state.intensity,
                });
                ref.invalidate(onboardingStatusProvider(user.uid));
              }
            }
          },
          child: Text(
            state.currentPage == 4 ? 'Bắt đầu hành trình' : 'Tiếp theo',
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
          color: selected ? VitaTrackTheme.mauChinh.withValues(alpha: 0.1) : VitaTrackTheme.mauCard,
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
          color: selected ? VitaTrackTheme.mauChinh.withValues(alpha: 0.1) : VitaTrackTheme.mauCard,
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