import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/widgets/bottom_nav.dart';
import '../providers/onboarding_provider.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_vitatrack_1/core/services/user_profile_service.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/onboarding_status_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _heightController = TextEditingController(text: '170');
    _weightController = TextEditingController(text: '65');
    _ageController = TextEditingController(text: '25');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                  _stepNhapTuoi(state, notifier),
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
    double progress = (state.currentPage + 1) / 6;
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
              Text('Bước ${state.currentPage + 1}/6', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () async {
                  final user = ref.read(nguoiDungHienTaiProvider);
                  if (user != null) {
                    final userProfileService = ref.read(userProfileServiceProvider);
                    await userProfileService.saveOnboardingData(user.uid, {
                      'mucTieu': 'Giữ dáng',
                      'gioiTinh': 'Nam',
                      'chieuCao': 170.0,
                      'canNang': 65.0,
                      'tuoi': 25,
                      'cuongDo': 'Vừa phải',
                    });
                    ref.invalidate(onboardingStatusProvider(user.uid));
                  }
                  if (context.mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BottomNav()));
                  }
                },
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
      desc: 'Hãy nhập chiều cao và cân nặng để chúng tôi tính toán chính xác.',
      content: Column(
        children: [
          _buildNumberInput('Chiều cao', _heightController, 'cm'),
          const SizedBox(height: 32),
          _buildNumberInput('Cân nặng', _weightController, 'kg'),
        ],
      ),
    );
  }

  // BƯỚC 3.5: NHẬP TUỔI
  Widget _stepNhapTuoi(OnboardingState state, OnboardingNotifier notifier) {
    return _buildStepLayout(
      title: 'Độ tuổi của bạn?',
      desc: 'Yếu tố quan trọng để tính toán BMR chính xác.',
      content: _buildNumberInput('Tuổi', _ageController, 'tuổi'),
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
            Text(
              '${_formatNumber(state.caloriesGoal)} kcal',
              style: const TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Divider(color: VitaTrackTheme.mauCardNhat),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('Protein', '${state.proteinGoal}g'),
                _miniStat('Carbs', '${state.carbsGoal}g'),
                _miniStat('Chất béo', '${state.fatGoal}g'),
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

            // Thực hiện validate mạnh trước khi qua trang tiếp theo
            if (state.currentPage == 2) {
              final hText = _heightController.text.trim();
              final wText = _weightController.text.trim();
              
              if (hText.isEmpty || wText.isEmpty) {
                _showError('Vui lòng không để trống chiều cao và cân nặng');
                return;
              }
              final h = double.tryParse(hText);
              final w = double.tryParse(wText);
              
              if (h == null || w == null) {
                _showError('Vui lòng nhập giá trị số hợp lệ');
                return;
              }
              if (h < 0 || w < 0) {
                _showError('Giá trị không được là số âm');
                return;
              }
              if (h < 100 || h > 250) {
                _showError('Chiều cao phải từ 100 cm đến 250 cm');
                return;
              }
              if (w < 20 || w > 300) {
                _showError('Cân nặng phải từ 20 kg đến 300 kg');
                return;
              }
              notifier.setHeight(h);
              notifier.setWeight(w);
            } else if (state.currentPage == 3) {
              final aText = _ageController.text.trim();
              if (aText.isEmpty) {
                _showError('Vui lòng không để trống tuổi');
                return;
              }
              final a = int.tryParse(aText);
              if (a == null) {
                _showError('Vui lòng nhập tuổi là một số hợp lệ');
                return;
              }
              if (a < 0) {
                _showError('Tuổi không được là số âm');
                return;
              }
              if (a < 13 || a > 100) {
                _showError('Tuổi phải từ 13 đến 100');
                return;
              }
              notifier.setAge(a);
            }

            if (state.currentPage < 5) {
              _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
              
              if (state.currentPage == 4) {
                await notifier.calculateAndShowResult();
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
                  'tuoi': state.age,
                  'cuongDo': state.intensity,
                  'caloriesGoal': state.caloriesGoal,
                  'proteinGoal': state.proteinGoal,
                  'carbsGoal': state.carbsGoal,
                  'fatGoal': state.fatGoal,
                });
                ref.invalidate(onboardingStatusProvider(user.uid));
                if (context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BottomNav()));
                }
              }
            }
          },
          child: Text(
            state.currentPage == 5 ? 'Bắt đầu hành trình' : 'Tiếp theo',
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

  Widget _buildNumberInput(String label, TextEditingController controller, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            suffixText: unit,
            suffixStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 16),
            filled: true,
            fillColor: VitaTrackTheme.mauCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return n.toString();
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